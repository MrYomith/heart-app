"""Medication manager for the authenticated patient (FR-043, FR-122)."""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import MedicationLogStatus
from app.models import Medication, MedicationLog, User
from app.schemas.medication import MedicationOut

router = APIRouter(prefix="/api/medications", tags=["medications"])


def _start_of_today_utc() -> datetime:
    now = datetime.now(timezone.utc)
    return now.replace(hour=0, minute=0, second=0, microsecond=0)


@router.get("", response_model=list[MedicationOut])
def list_medications(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    meds = db.query(Medication).filter(Medication.user_id == user.id, Medication.is_active.is_(True)).all()
    today = _start_of_today_utc()
    taken_ids = {
        log.medication_id
        for log in db.query(MedicationLog).filter(
            MedicationLog.user_id == user.id,
            MedicationLog.status == MedicationLogStatus.taken,
            MedicationLog.taken_at >= today,
        )
    }
    return [MedicationOut.from_row(m, taken_today=m.id in taken_ids) for m in meds]


@router.post("/{med_id}/taken", response_model=MedicationOut)
def mark_taken(med_id: uuid.UUID, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    med = db.query(Medication).filter(Medication.id == med_id, Medication.user_id == user.id).first()
    if not med:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Medication not found.")
    now = datetime.now(timezone.utc)
    today = _start_of_today_utc()
    already = (
        db.query(MedicationLog)
        .filter(
            MedicationLog.medication_id == med.id,
            MedicationLog.status == MedicationLogStatus.taken,
            MedicationLog.taken_at >= today,
        )
        .first()
    )
    if not already:
        db.add(MedicationLog(medication_id=med.id, user_id=user.id, taken_at=now, status=MedicationLogStatus.taken))
        db.commit()
    return MedicationOut.from_row(med, taken_today=True)
