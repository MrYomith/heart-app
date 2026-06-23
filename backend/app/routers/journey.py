from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.journey import JourneyPhase
from app.models.user import User
from app.schemas.journey import JourneyPhaseOut

router = APIRouter(prefix="/api/journey", tags=["journey"])


@router.get("/user/{user_id}", response_model=List[JourneyPhaseOut])
def get_journey_phases(user_id: int, db: Session = Depends(get_db)):
    phases = (
        db.query(JourneyPhase)
        .filter(JourneyPhase.user_id == user_id)
        .order_by(JourneyPhase.order)
        .all()
    )
    return phases


@router.get("/user/{user_id}/current")
def get_current_phase(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    phase = (
        db.query(JourneyPhase)
        .filter(JourneyPhase.user_id == user_id, JourneyPhase.status == "active")
        .first()
    )
    return {
        "current_phase": user.current_phase,
        "journey_progress": user.journey_progress,
        "phase_detail": phase,
    }


@router.patch("/user/{user_id}/advance")
def advance_phase(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    phase_order = ["diagnosis", "preop", "surgery", "inpatient", "rehab", "thriving"]
    current_idx = phase_order.index(user.current_phase) if user.current_phase in phase_order else 0

    if current_idx >= len(phase_order) - 1:
        return {"message": "Already at final phase", "current_phase": user.current_phase}

    # Mark current as completed
    current = db.query(JourneyPhase).filter(
        JourneyPhase.user_id == user_id,
        JourneyPhase.phase_key == user.current_phase
    ).first()
    if current:
        current.status = "completed"

    # Advance to next
    next_key = phase_order[current_idx + 1]
    nxt = db.query(JourneyPhase).filter(
        JourneyPhase.user_id == user_id,
        JourneyPhase.phase_key == next_key
    ).first()
    if nxt:
        nxt.status = "active"

    user.current_phase = next_key
    user.journey_progress = round(((current_idx + 1) / (len(phase_order) - 1)) * 100, 1)

    db.commit()
    return {"current_phase": user.current_phase, "journey_progress": user.journey_progress}
