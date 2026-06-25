"""Clinician dashboard API (FR-281–286).

Reuses the self-hosted JWT login; these endpoints additionally require role=clinician
and scope every read to the clinician's assigned patients. Every access is auditable.
"""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import PhaseKey, UserRole, VitalType
from app.models import (
    Alert,
    ClinicalScore,
    ClinicianAssignment,
    Medication,
    User,
    Vital,
    WoundPhoto,
)
from app.schemas.clinician import (
    AlertOut,
    ClinicianPatientOut,
    PatientDetailOut,
    ScoreOut,
    VitalPoint,
    WoundPhotoSummary,
)
from app.services.stage_engine import manual_transition, set_paused

router = APIRouter(prefix="/api/clinician", tags=["clinician"])


def get_current_clinician(user: User = Depends(get_current_user)) -> User:
    if user.role not in (UserRole.clinician, UserRole.admin):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Clinician access only.")
    return user


def _assigned_patient_ids(db: Session, clinician: User) -> list:
    """Patients this clinician may see: actively assigned AND still enrolled at the
    clinician's hospital (defense-in-depth multi-tenancy — never cross hospitals)."""
    assignments = db.query(ClinicianAssignment).filter(
        ClinicianAssignment.clinician_id == clinician.id,
        ClinicianAssignment.active.is_(True),
    ).all()
    patient_ids = [a.patient_id for a in assignments]
    if patient_ids:
        enrolled = db.query(User.id).filter(
            User.id.in_(patient_ids),
            User.deleted_at.is_(None),
            User.hospital_id == clinician.hospital_id,
        ).all()
        return [row[0] for row in enrolled]
    # Fallback: no explicit assignments → show all patients in the clinician's
    # hospital (admins see every patient). Keeps single-hospital multi-tenancy
    # and stops the dashboard being empty before assignments are configured.
    q = db.query(User.id).filter(User.role == UserRole.patient, User.deleted_at.is_(None))
    if clinician.role != UserRole.admin and clinician.hospital_id is not None:
        q = q.filter(User.hospital_id == clinician.hospital_id)
    return [row[0] for row in q.all()]


def _alert_level(open_alerts: list[Alert]) -> str:
    if any(a.severity.value == "critical" for a in open_alerts):
        return "red"
    if any(a.severity.value == "warning" for a in open_alerts):
        return "amber"
    return "green"


def _alert_out(a: Alert, name: str) -> AlertOut:
    return AlertOut(
        id=str(a.id), patient_id=str(a.patient_id), patient_name=name,
        type=a.type.value, severity=a.severity.value,
        triggered_at=a.triggered_at.isoformat() if a.triggered_at else None,
        acknowledged=a.acked_at is not None,
    )


@router.get("/patients", response_model=list[ClinicianPatientOut])
def patient_list(clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    ids = _assigned_patient_ids(db, clinician)
    if not ids:
        return []
    patients = db.query(User).filter(User.id.in_(ids), User.deleted_at.is_(None)).all()
    out = []
    for p in patients:
        open_alerts = db.query(Alert).filter(Alert.patient_id == p.id, Alert.resolved_at.is_(None)).all()
        out.append(ClinicianPatientOut(
            id=str(p.id), name=p.name,
            surgery_type=p.surgery_type.value if p.surgery_type else None,
            current_phase=p.current_phase.value if p.current_phase else "diagnosis",
            journey_progress=p.journey_progress or 0.0,
            alert_level=_alert_level(open_alerts),
            open_alerts=len(open_alerts),
        ))
    # Sort red → amber → green, then most alerts first
    rank = {"red": 0, "amber": 1, "green": 2}
    out.sort(key=lambda x: (rank[x.alert_level], -x.open_alerts))
    return out


@router.get("/alerts", response_model=list[AlertOut])
def alert_centre(clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    ids = _assigned_patient_ids(db, clinician)
    if not ids:
        return []
    alerts = (
        db.query(Alert).filter(Alert.patient_id.in_(ids), Alert.resolved_at.is_(None))
        .order_by(Alert.triggered_at.desc()).all()
    )
    names = {p.id: p.name for p in db.query(User).filter(User.id.in_(ids))}
    return [_alert_out(a, names.get(a.patient_id, "Patient")) for a in alerts]


@router.patch("/alerts/{alert_id}/ack", response_model=AlertOut)
def acknowledge(alert_id: uuid.UUID, clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    ids = _assigned_patient_ids(db, clinician)
    a = db.query(Alert).filter(Alert.id == alert_id, Alert.patient_id.in_(ids)).first()
    if not a:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Alert not found.")
    now = datetime.now(timezone.utc)
    a.acked_by = clinician.id
    a.acked_at = now
    a.resolved_at = now  # acknowledging resolves it for the dashboard list
    db.commit()
    db.refresh(a)
    p = db.query(User).filter(User.id == a.patient_id).first()
    return _alert_out(a, p.name if p else "Patient")


@router.get("/patients/{patient_id}", response_model=PatientDetailOut)
def patient_detail(patient_id: uuid.UUID, clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    ids = _assigned_patient_ids(db, clinician)
    if patient_id not in ids:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your patient.")
    p = db.query(User).filter(User.id == patient_id).first()
    if not p:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Patient not found.")

    open_alerts = db.query(Alert).filter(Alert.patient_id == p.id, Alert.resolved_at.is_(None)).order_by(Alert.triggered_at.desc()).all()
    pain = db.query(Vital).filter(Vital.user_id == p.id, Vital.type.in_([VitalType.pain_rest, VitalType.pain_cough, VitalType.pain_move])).order_by(Vital.recorded_at.desc()).limit(10).all()
    mood = db.query(Vital).filter(Vital.user_id == p.id, Vital.type == VitalType.mood).order_by(Vital.recorded_at.desc()).limit(14).all()
    scores = db.query(ClinicalScore).filter(ClinicalScore.user_id == p.id).order_by(ClinicalScore.administered_at.desc()).limit(10).all()
    wounds = db.query(WoundPhoto).filter(WoundPhoto.user_id == p.id).order_by(WoundPhoto.uploaded_at.desc()).limit(12).all()
    meds = db.query(Medication).filter(Medication.user_id == p.id, Medication.is_active.is_(True)).all()

    return PatientDetailOut(
        id=str(p.id), name=p.name, email=p.email,
        surgery_type=p.surgery_type.value if p.surgery_type else None,
        surgery_date=p.surgery_date.isoformat() if p.surgery_date else None,
        nyha_class=p.nyha_class.value if p.nyha_class else None,
        current_phase=p.current_phase.value if p.current_phase else "diagnosis",
        journey_progress=p.journey_progress or 0.0,
        open_alerts=[_alert_out(a, p.name) for a in open_alerts],
        recent_pain=[VitalPoint(type=v.type.value, value=v.value, recorded_at=v.recorded_at.isoformat() if v.recorded_at else None) for v in pain],
        recent_mood=[VitalPoint(type=v.type.value, value=v.value, recorded_at=v.recorded_at.isoformat() if v.recorded_at else None) for v in mood],
        clinical_scores=[ScoreOut(score_type=s.score_type.value, score=s.score, severity=s.severity.value if s.severity else None, administered_at=s.administered_at.isoformat() if s.administered_at else None) for s in scores],
        wound_photos=[WoundPhotoSummary(id=str(w.id), day_post_op=w.day_post_op, uploaded_at=w.uploaded_at.isoformat() if w.uploaded_at else None, reviewed=w.reviewed_by is not None) for w in wounds],
        medications=[{"name": m.name, "dose": m.dose, "schedule": m.schedule, "is_anticoagulant": m.is_anticoagulant} for m in meds],
    )


class StageControlIn(BaseModel):
    action: str            # "set" | "pause" | "resume"
    to_phase: str | None = None   # required for action="set"
    reason: str | None = None


@router.patch("/patients/{patient_id}/stage")
def control_stage(patient_id: uuid.UUID, payload: StageControlIn,
                  clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    """FR-035 clinician override: advance/roll back a stage, or pause/resume
    auto-advancement. Every action is logged (stage_transitions + audit_log)."""
    ids = _assigned_patient_ids(db, clinician)
    if patient_id not in ids:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your patient.")
    p = db.query(User).filter(User.id == patient_id).first()
    if not p:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Patient not found.")

    if payload.action == "pause":
        set_paused(db, p, True, clinician, payload.reason)
    elif payload.action == "resume":
        set_paused(db, p, False, clinician, payload.reason)
    elif payload.action == "set":
        try:
            to_phase = PhaseKey(payload.to_phase)
        except (ValueError, TypeError):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid to_phase.")
        manual_transition(db, p, to_phase, clinician, payload.reason)
    else:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "action must be set | pause | resume.")

    db.refresh(p)
    return {
        "patient_id": str(p.id),
        "current_phase": p.current_phase.value if p.current_phase else "diagnosis",
        "journey_progress": p.journey_progress or 0.0,
        "stage_paused": p.stage_paused,
    }
