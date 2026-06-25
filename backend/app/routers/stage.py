"""Stage trackers: ERAS pre-op checklist (FR-060) + mobilisation (FR-102)."""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import ErasItem
from app.models import ErasProgress, MobilisationMilestoneLog, User
from app.schemas.stage import ErasItemOut, ErasSummaryOut, ErasUpdate, MobilisationOut

eras_router = APIRouter(prefix="/api/eras", tags=["eras"])
mobilisation_router = APIRouter(prefix="/api/mobilisation", tags=["mobilisation"])

ERAS_LABELS = {
    "smoking": "Smoking Cessation",
    "nutrition": "Nutrition",
    "exercise": "Exercise Training",
    "breathing": "Breathing Exercises",
    "medications": "Medications Review",
    "skin_prep": "Skin Preparation",
    "education": "Education",
}
MOBI_LABELS = {
    "sitting": "Sit on edge of bed",
    "standing": "Stand & walk in room",
    "first_walk": "Walk in the corridor",
    "session": "Physio session",
}


@eras_router.get("", response_model=ErasSummaryOut)
def get_eras(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(ErasProgress).filter(ErasProgress.user_id == user.id).all()
    items = [
        ErasItemOut(item_key=r.item_key.value, label=ERAS_LABELS.get(r.item_key.value, r.item_key.value),
                    progress=r.progress, target=r.target or 100)
        for r in sorted(rows, key=lambda x: x.item_key.value)
    ]
    overall = round(sum(i.progress for i in items) / len(items)) if items else 0
    return ErasSummaryOut(items=items, overall=overall)


@eras_router.patch("/{item_key}", response_model=ErasSummaryOut)
def update_eras(item_key: str, payload: ErasUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        key = ErasItem(item_key)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown ERAS item.")
    row = db.query(ErasProgress).filter(ErasProgress.user_id == user.id, ErasProgress.item_key == key).first()
    if not row:
        row = ErasProgress(user_id=user.id, item_key=key, target=100)
        db.add(row)
    row.progress = max(0, min(100, payload.progress))
    db.commit()
    return get_eras(user, db)


@mobilisation_router.get("", response_model=list[MobilisationOut])
def get_mobilisation(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(MobilisationMilestoneLog).filter(MobilisationMilestoneLog.user_id == user.id).all()
    order = {"sitting": 0, "standing": 1, "first_walk": 2, "session": 3}
    rows = sorted(rows, key=lambda r: order.get(r.milestone.value, 9))
    return [MobilisationOut(id=str(r.id), milestone=r.milestone.value, label=MOBI_LABELS.get(r.milestone.value, r.milestone.value), achieved=r.achieved) for r in rows]


@mobilisation_router.patch("/{mid}/achieve", response_model=MobilisationOut)
def achieve(mid: uuid.UUID, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(MobilisationMilestoneLog).filter(MobilisationMilestoneLog.id == mid, MobilisationMilestoneLog.user_id == user.id).first()
    if not row:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Milestone not found.")
    row.achieved = True
    row.achieved_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(row)
    return MobilisationOut(id=str(row.id), milestone=row.milestone.value, label=MOBI_LABELS.get(row.milestone.value, row.milestone.value), achieved=row.achieved)
