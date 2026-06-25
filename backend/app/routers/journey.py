"""Six-stage journey for the authenticated patient (FR-022, FR-035)."""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import ActivatedBy, PhaseKey, PhaseStatus, TransitionTrigger
from app.models import JourneyPhase, StageTransition, User
from app.schemas.journey import JourneyPhaseOut
from app.services.stage_engine import apply_auto_transitions

router = APIRouter(prefix="/api/journey", tags=["journey"])

_ORDER = ["diagnosis", "preop", "surgery", "inpatient", "rehab", "thriving"]


@router.get("", response_model=list[JourneyPhaseOut])
def get_phases(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Keep the patient's stage current with the date rules (FR-035) on each read.
    apply_auto_transitions(db, user)
    rows = (
        db.query(JourneyPhase)
        .filter(JourneyPhase.user_id == user.id)
        .order_by(JourneyPhase.sort_order)
        .all()
    )
    return [JourneyPhaseOut.from_row(p) for p in rows]


@router.patch("/advance")
def advance(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    cur = user.current_phase.value if user.current_phase else "diagnosis"
    idx = _ORDER.index(cur) if cur in _ORDER else 0
    if idx >= len(_ORDER) - 1:
        return {"current_phase": cur, "journey_progress": user.journey_progress}

    next_key = _ORDER[idx + 1]
    current_row = db.query(JourneyPhase).filter(
        JourneyPhase.user_id == user.id, JourneyPhase.phase_key == PhaseKey(cur)
    ).first()
    if current_row:
        current_row.status = PhaseStatus.completed
    next_row = db.query(JourneyPhase).filter(
        JourneyPhase.user_id == user.id, JourneyPhase.phase_key == PhaseKey(next_key)
    ).first()
    if next_row:
        next_row.status = PhaseStatus.active
        next_row.activated_at = now
        next_row.activated_by = ActivatedBy.auto

    user.current_phase = PhaseKey(next_key)
    user.journey_progress = round(((idx + 1) / (len(_ORDER) - 1)) * 100, 1)

    db.add(StageTransition(
        user_id=user.id, from_phase=PhaseKey(cur), to_phase=PhaseKey(next_key),
        trigger=TransitionTrigger.auto_date, created_at=now,
    ))
    db.commit()
    return {"current_phase": user.current_phase.value, "journey_progress": user.journey_progress}
