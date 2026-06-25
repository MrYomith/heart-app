"""Breathing exercise sessions for the authenticated patient (FR-063, FR-101)."""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import BreathingSessionType
from app.models import BreathingSession, User
from app.schemas.breathing import BreathingLog, BreathingTodayOut

router = APIRouter(prefix="/api/breathing", tags=["breathing"])

DAILY_TARGET = 3  # ERAS prehab: 3 spirometry sessions/day


@router.post("", response_model=BreathingTodayOut, status_code=201)
def log_session(payload: BreathingLog, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        stype = BreathingSessionType(payload.session_type)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown session type: {payload.session_type}")
    now = datetime.now(timezone.utc)
    db.add(BreathingSession(user_id=user.id, session_type=stype, completed_at=now, count=payload.count))
    db.commit()
    return _today(db, user, now)


@router.get("/today", response_model=BreathingTodayOut)
def today(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return _today(db, user, datetime.now(timezone.utc))


def _today(db: Session, user: User, now: datetime) -> BreathingTodayOut:
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    count = (
        db.query(BreathingSession)
        .filter(BreathingSession.user_id == user.id, BreathingSession.completed_at >= start)
        .count()
    )
    return BreathingTodayOut(today_count=count, target=DAILY_TARGET)
