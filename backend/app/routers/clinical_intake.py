"""Patient-reported clinical intake that feeds the alert/referral loop.

  FR-202  Symptom escalation     — one-tap red-flag report -> Alert
  FR-201  Recovery check-in      — daily 5-question check-in (-> Alert if concerning)
  FR-124  PHQ-9 / PCL-5 screening — scheduled mental-health screen -> Referral + Alert
"""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import (
    AlertSeverity,
    AlertType,
    ReferralStatus,
    ScoreType,
    Severity,
    SymptomType,
)
from app.models import (
    Alert,
    ClinicalScore,
    RecoveryCheckin,
    Referral,
    SymptomReport,
    User,
)

router = APIRouter(prefix="/api", tags=["clinical-intake"])


def _now() -> datetime:
    return datetime.now(timezone.utc)


# --------------------------------------------------------------------------
# FR-202 — Symptom escalation
# --------------------------------------------------------------------------
# Symptoms that warrant an immediate (critical) clinician alert vs a warning.
_CRITICAL_SYMPTOMS = {SymptomType.fever, SymptomType.breathlessness, SymptomType.wound_oozing}


# Catalog is admin-editable, so accept any symptom key; map to the enum when
# possible, otherwise store the generic 'symptom_report' and keep the label in note.
class SymptomIn(BaseModel):
    symptom: str
    note: str | None = None


class SymptomOut(BaseModel):
    id: str
    symptom: str
    note: str | None
    reported_at: str
    alert_severity: str


@router.post("/symptoms", response_model=SymptomOut)
def report_symptom(payload: SymptomIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = _now()
    try:
        kind = SymptomType(payload.symptom)
    except ValueError:
        kind = SymptomType.increased_pain  # safe default; real label kept in note
    rep = SymptomReport(user_id=user.id, symptom=kind, note=payload.note, reported_at=now)
    db.add(rep)
    db.flush()
    severity = AlertSeverity.critical if kind in _CRITICAL_SYMPTOMS else AlertSeverity.warning
    db.add(Alert(
        patient_id=user.id, type=AlertType.symptom_report, severity=severity,
        triggered_at=now, source_ref=rep.id,
    ))
    db.commit()
    db.refresh(rep)
    return SymptomOut(
        id=str(rep.id), symptom=rep.symptom.value, note=rep.note,
        reported_at=rep.reported_at.isoformat(), alert_severity=severity.value,
    )


@router.get("/symptoms", response_model=list[SymptomOut])
def list_symptoms(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(SymptomReport).filter(SymptomReport.user_id == user.id).order_by(SymptomReport.reported_at.desc()).all()
    return [SymptomOut(id=str(r.id), symptom=r.symptom.value, note=r.note,
                       reported_at=r.reported_at.isoformat(), alert_severity="") for r in rows]


# --------------------------------------------------------------------------
# FR-201 — Smart recovery check-in
# --------------------------------------------------------------------------
class RecoveryCheckinIn(BaseModel):
    feeling: str | None = None
    wound_issues: bool = False
    pain_level: int | None = None
    sleep_quality: str | None = None
    concerns: str | None = None


class RecoveryCheckinOut(BaseModel):
    id: str
    feeling: str | None
    wound_issues: bool
    pain_level: int | None
    sleep_quality: str | None
    concerns: str | None
    submitted_at: str
    raised_alert: bool


@router.post("/recovery-checkin", response_model=RecoveryCheckinOut)
def submit_checkin(payload: RecoveryCheckinIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = _now()
    chk = RecoveryCheckin(
        user_id=user.id, feeling=payload.feeling, wound_issues=payload.wound_issues,
        pain_level=payload.pain_level, sleep_quality=payload.sleep_quality,
        concerns=payload.concerns, submitted_at=now,
    )
    db.add(chk)
    db.flush()
    # A reported wound issue or severe pain raises a clinician alert.
    raised = False
    if payload.wound_issues:
        db.add(Alert(patient_id=user.id, type=AlertType.wound_concern, severity=AlertSeverity.warning,
                     triggered_at=now, source_ref=chk.id))
        raised = True
    if payload.pain_level is not None and payload.pain_level >= 7:
        db.add(Alert(patient_id=user.id, type=AlertType.pain_high, severity=AlertSeverity.critical,
                     triggered_at=now, source_ref=chk.id))
        raised = True
    db.commit()
    db.refresh(chk)
    return RecoveryCheckinOut(
        id=str(chk.id), feeling=chk.feeling, wound_issues=chk.wound_issues, pain_level=chk.pain_level,
        sleep_quality=chk.sleep_quality, concerns=chk.concerns, submitted_at=chk.submitted_at.isoformat(),
        raised_alert=raised,
    )


@router.get("/recovery-checkin", response_model=list[RecoveryCheckinOut])
def list_checkins(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(RecoveryCheckin).filter(RecoveryCheckin.user_id == user.id).order_by(RecoveryCheckin.submitted_at.desc()).limit(30).all()
    return [RecoveryCheckinOut(id=str(r.id), feeling=r.feeling, wound_issues=r.wound_issues, pain_level=r.pain_level,
                               sleep_quality=r.sleep_quality, concerns=r.concerns,
                               submitted_at=r.submitted_at.isoformat(), raised_alert=False) for r in rows]


# --------------------------------------------------------------------------
# FR-124 — PHQ-9 / PCL-5 screening (-> referral to Psychokardiologie)
# --------------------------------------------------------------------------
def _phq9_severity(score: int) -> Severity:
    if score >= 15:
        return Severity.severe
    if score >= 10:
        return Severity.moderate
    if score >= 5:
        return Severity.mild
    return Severity.minimal


def _pcl5_severity(score: int) -> Severity:
    if score >= 50:
        return Severity.severe
    if score >= 33:           # ≥33 = probable PTSD
        return Severity.moderate
    if score >= 20:
        return Severity.mild
    return Severity.minimal


class ScreeningIn(BaseModel):
    score_type: ScoreType           # phq9 | pcl5
    score: int
    answers: dict | None = None
    scheduled_week: int | None = None


class ScreeningOut(BaseModel):
    id: str
    score_type: str
    score: int
    severity: str
    referral_created: bool
    administered_at: str


@router.post("/screening", response_model=ScreeningOut)
def submit_screening(payload: ScreeningIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = _now()
    severity = _phq9_severity(payload.score) if payload.score_type == ScoreType.phq9 else _pcl5_severity(payload.score)
    cs = ClinicalScore(
        user_id=user.id, score_type=payload.score_type, score=payload.score,
        answers=payload.answers, severity=severity, administered_at=now,
        scheduled_week=payload.scheduled_week,
    )
    db.add(cs)
    db.flush()

    # Moderate or worse → refer to Psychokardiologie + raise an alert.
    referral_created = False
    if severity in (Severity.moderate, Severity.severe):
        db.add(Referral(
            patient_id=user.id, referred_to_role="psychokardiologist",
            trigger_score_id=cs.id, status=ReferralStatus.pending, created_at=now,
        ))
        db.add(Alert(
            patient_id=user.id, type=AlertType.mood_low_3day,
            severity=AlertSeverity.critical if severity == Severity.severe else AlertSeverity.warning,
            triggered_at=now, source_ref=cs.id,
        ))
        referral_created = True

    db.commit()
    db.refresh(cs)
    return ScreeningOut(
        id=str(cs.id), score_type=cs.score_type.value, score=cs.score,
        severity=severity.value, referral_created=referral_created,
        administered_at=cs.administered_at.isoformat(),
    )


@router.get("/screening", response_model=list[ScreeningOut])
def list_screenings(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(ClinicalScore)
        .filter(ClinicalScore.user_id == user.id, ClinicalScore.score_type.in_([ScoreType.phq9, ScoreType.pcl5]))
        .order_by(ClinicalScore.administered_at.desc())
        .all()
    )
    return [ScreeningOut(id=str(r.id), score_type=r.score_type.value, score=r.score,
                         severity=r.severity.value if r.severity else "minimal",
                         referral_created=False, administered_at=r.administered_at.isoformat()) for r in rows]
