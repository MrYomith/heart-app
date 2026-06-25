"""Clinician/admin editing of a patient's clinical data & plan (Step 3 / FR-283).

Turns the seeded template data into a real, hospital-owned plan: the clinician
sets the surgery/discharge dates, prescribes & edits medications, and schedules
appointments. Everything is scoped to the clinician's assigned patients and
written to the audit log. Changing the surgery/discharge date automatically
re-drives the journey stage engine (FR-035) on the patient's next sync.
"""
import uuid
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.enums import AppointmentType, NyhaClass, PhaseKey, SurgeryType, VitalSource, VitalType
from app.models import Appointment, AuditLog, Medication, User, Vital
from app.routers.clinician import _assigned_patient_ids, get_current_clinician

router = APIRouter(prefix="/api/clinician", tags=["clinician-manage"])


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _require_patient(db: Session, clinician: User, patient_id: uuid.UUID) -> User:
    if patient_id not in _assigned_patient_ids(db, clinician):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not your patient.")
    p = db.query(User).filter(User.id == patient_id).first()
    if not p:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Patient not found.")
    return p


def _audit(db: Session, clinician: User, patient_id: uuid.UUID, action: str, meta: dict) -> None:
    db.add(AuditLog(
        actor_id=clinician.id, actor_role="clinician", action=action,
        entity_type="patient_data", entity_id=patient_id, patient_id=patient_id,
        audit_metadata=meta, ip_hash=None, created_at=_now(),
    ))


# --------------------------------------------------------------------------
# Patient clinical profile (surgery type/date, discharge date, NYHA, etc.)
# --------------------------------------------------------------------------
class ProfileIn(BaseModel):
    surgery_type: SurgeryType | None = None
    surgery_date: date | None = None
    discharge_date: date | None = None
    nyha_class: NyhaClass | None = None
    surgeon_name: str | None = None
    diagnosis: str | None = None


@router.patch("/patients/{patient_id}/profile")
def update_profile(patient_id: uuid.UUID, payload: ProfileIn,
                   clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    p = _require_patient(db, clinician, patient_id)
    changed = {}
    for field in ("surgery_type", "surgery_date", "discharge_date", "nyha_class", "surgeon_name", "diagnosis"):
        val = getattr(payload, field)
        if val is not None:
            setattr(p, field, val)
            changed[field] = val.isoformat() if isinstance(val, date) else getattr(val, "value", val)
    if changed:
        _audit(db, clinician, patient_id, "edit_profile", changed)
        db.commit()
    return {"id": str(p.id), "updated": list(changed.keys()),
            "surgery_date": p.surgery_date.isoformat() if p.surgery_date else None,
            "discharge_date": p.discharge_date.isoformat() if p.discharge_date else None}


# --------------------------------------------------------------------------
# Medications — prescribe / edit / discontinue
# --------------------------------------------------------------------------
class MedicationIn(BaseModel):
    name: str
    dose: str | None = None
    schedule: str | None = None
    times: str | None = None
    is_anticoagulant: bool = False
    purpose_de: str | None = None
    phase: PhaseKey | None = None


def _med_out(m: Medication) -> dict:
    return {"id": str(m.id), "name": m.name, "dose": m.dose, "schedule": m.schedule,
            "times": m.times, "is_anticoagulant": m.is_anticoagulant, "purpose_de": m.purpose_de,
            "is_active": m.is_active}


@router.get("/patients/{patient_id}/medications")
def list_meds(patient_id: uuid.UUID, clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    rows = db.query(Medication).filter(Medication.user_id == patient_id).all()
    return [_med_out(m) for m in rows]


@router.post("/patients/{patient_id}/medications")
def add_med(patient_id: uuid.UUID, payload: MedicationIn,
            clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    m = Medication(user_id=patient_id, name=payload.name, dose=payload.dose, schedule=payload.schedule,
                   times=payload.times, is_anticoagulant=payload.is_anticoagulant,
                   purpose_de=payload.purpose_de, phase=payload.phase, is_active=True)
    db.add(m)
    _audit(db, clinician, patient_id, "prescribe_medication", {"name": payload.name, "dose": payload.dose})
    db.commit()
    db.refresh(m)
    return _med_out(m)


@router.patch("/patients/{patient_id}/medications/{med_id}")
def edit_med(patient_id: uuid.UUID, med_id: uuid.UUID, payload: MedicationIn,
             clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    m = db.query(Medication).filter(Medication.id == med_id, Medication.user_id == patient_id).first()
    if not m:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Medication not found.")
    m.name = payload.name; m.dose = payload.dose; m.schedule = payload.schedule
    m.times = payload.times; m.is_anticoagulant = payload.is_anticoagulant
    m.purpose_de = payload.purpose_de; m.phase = payload.phase
    _audit(db, clinician, patient_id, "edit_medication", {"id": str(med_id), "name": payload.name})
    db.commit()
    db.refresh(m)
    return _med_out(m)


@router.delete("/patients/{patient_id}/medications/{med_id}", status_code=204)
def stop_med(patient_id: uuid.UUID, med_id: uuid.UUID,
             clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    m = db.query(Medication).filter(Medication.id == med_id, Medication.user_id == patient_id).first()
    if not m:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Medication not found.")
    m.is_active = False  # discontinue (kept for history)
    _audit(db, clinician, patient_id, "discontinue_medication", {"id": str(med_id), "name": m.name})
    db.commit()


# --------------------------------------------------------------------------
# Appointments — schedule / edit / cancel
# --------------------------------------------------------------------------
class AppointmentIn(BaseModel):
    title: str
    subtitle: str | None = None
    date: str            # ISO date string
    time: str | None = None
    location: str | None = None
    appointment_type: AppointmentType = AppointmentType.followup


def _appt_out(a: Appointment) -> dict:
    return {"id": str(a.id), "title": a.title, "subtitle": a.subtitle, "date": a.date,
            "time": a.time, "location": a.location,
            "appointment_type": a.appointment_type.value if a.appointment_type else None,
            "is_confirmed": a.is_confirmed}


@router.get("/patients/{patient_id}/appointments")
def list_appts(patient_id: uuid.UUID, clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    rows = db.query(Appointment).filter(Appointment.user_id == patient_id).order_by(Appointment.date).all()
    return [_appt_out(a) for a in rows]


@router.post("/patients/{patient_id}/appointments")
def add_appt(patient_id: uuid.UUID, payload: AppointmentIn,
             clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    p = _require_patient(db, clinician, patient_id)
    a = Appointment(user_id=patient_id, title=payload.title, subtitle=payload.subtitle,
                    date=payload.date, time=payload.time,
                    location=payload.location or (p.hospital.name if getattr(p, "hospital", None) else None),
                    appointment_type=payload.appointment_type, hospital_id=p.hospital_id, is_confirmed=True)
    db.add(a)
    _audit(db, clinician, patient_id, "schedule_appointment", {"title": payload.title, "date": payload.date})
    db.commit()
    db.refresh(a)
    return _appt_out(a)


@router.patch("/patients/{patient_id}/appointments/{appt_id}")
def edit_appt(patient_id: uuid.UUID, appt_id: uuid.UUID, payload: AppointmentIn,
              clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    a = db.query(Appointment).filter(Appointment.id == appt_id, Appointment.user_id == patient_id).first()
    if not a:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Appointment not found.")
    a.title = payload.title; a.subtitle = payload.subtitle; a.date = payload.date
    a.time = payload.time; a.location = payload.location; a.appointment_type = payload.appointment_type
    _audit(db, clinician, patient_id, "edit_appointment", {"id": str(appt_id), "title": payload.title})
    db.commit()
    db.refresh(a)
    return _appt_out(a)


@router.delete("/patients/{patient_id}/appointments/{appt_id}", status_code=204)
def cancel_appt(patient_id: uuid.UUID, appt_id: uuid.UUID,
                clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    a = db.query(Appointment).filter(Appointment.id == appt_id, Appointment.user_id == patient_id).first()
    if not a:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Appointment not found.")
    db.delete(a)
    _audit(db, clinician, patient_id, "cancel_appointment", {"id": str(appt_id)})
    db.commit()


# --------------------------------------------------------------------------
# Clinical readings (BP, LDL, HbA1c, weight, BMI, resting HR) — clinician-entered
# lab/observation values that power the patient's long-term metric cards.
# --------------------------------------------------------------------------
class ReadingIn(BaseModel):
    type: VitalType
    value: float


@router.post("/patients/{patient_id}/readings")
def record_reading(patient_id: uuid.UUID, payload: ReadingIn,
                   clinician: User = Depends(get_current_clinician), db: Session = Depends(get_db)):
    _require_patient(db, clinician, patient_id)
    v = Vital(user_id=patient_id, type=payload.type, value=payload.value,
              recorded_at=_now(), source=VitalSource.manual)
    db.add(v)
    _audit(db, clinician, patient_id, "record_reading", {"type": payload.type.value, "value": payload.value})
    db.commit()
    return {"type": payload.type.value, "value": payload.value}
