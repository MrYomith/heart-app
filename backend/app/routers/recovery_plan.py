"""Calendar & Recovery Plan support (FR-162/163).

  /api/recovery/guide        — post-op Day 1–7 recovery guide
  /api/physiotherapy/plan    — 7-session progressive physio plan, dates derived
                               from the patient's discharge/surgery date

Read-only structured data — the programmes are standardised; dates personalise
to the patient. Recovery prediction lives in wellbeing.py (/api/recovery/prediction).
"""
from datetime import date, timedelta

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import User

router = APIRouter(prefix="/api", tags=["recovery-plan"])

# Post-op recovery guide — Day 1–7 in hospital (FR-162).
_GUIDE = [
    ("Day 1", "Monitoring & pain management", "Close monitoring in ICU/recovery; your pain is kept controlled."),
    ("Day 2", "Sitting up & breathing exercises", "Sit out of bed and start incentive spirometry."),
    ("Day 3", "Walking with support", "First assisted walks; wound dressing reviewed."),
    ("Day 4", "Increasing activity", "Longer walks, gentle daily-living activities."),
    ("Day 5–7", "Preparing for discharge", "Build independence and plan your home recovery."),
]

# Physiotherapy 7-session progressive programme (FR-163).
_PHYSIO = [
    (1, "Lower limb & breathing"),
    (2, "Mobility & posture"),
    (3, "Walking endurance"),
    (4, "Strength & flexibility"),
    (5, "Cardio & breathing"),
    (6, "Stamina & balance"),
    (7, "Functional training"),
]
# Day offsets from the rehab start (discharge) for each session.
_PHYSIO_OFFSETS = [2, 4, 7, 11, 14, 21, 24]


@router.get("/recovery/guide")
def recovery_guide(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return [{"day": d, "title": t, "detail": detail} for (d, t, detail) in _GUIDE]


@router.get("/physiotherapy/plan")
def physiotherapy_plan(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    base = user.discharge_date or (user.surgery_date + timedelta(days=7) if user.surgery_date else date.today())
    today = date.today()
    out = []
    for (n, focus), off in zip(_PHYSIO, _PHYSIO_OFFSETS):
        d = base + timedelta(days=off)
        out.append({
            "session": n, "focus": focus,
            "date": d.isoformat(),
            "status": "completed" if d < today else ("today" if d == today else "upcoming"),
        })
    return out
