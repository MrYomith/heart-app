"""Lifestyle, habits & recovery-planning features.

  FR-045 / FR-141  Activity logging + weekly 150-min goal
  FR-046           Smoking / alcohol cessation streaks
  FR-067 / FR-142  Journal entries (decision-making + gratitude)
  FR-140           Daily habits dashboard + streaks
  FR-123           Return-to-work plan
  FR-120           Rehab-centre enrolment
  FR-164           Recovery prediction (rule-based on-track %)
"""
from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import CessationType, HabitType, JobType, JournalType, PhaseKey
from app.models import (
    ActivityLog,
    CessationTracking,
    HabitLog,
    JournalEntry,
    RehabEnrollment,
    ReturnToWorkPlan,
    User,
)

router = APIRouter(prefix="/api", tags=["wellbeing"])


def _today() -> date:
    return datetime.now(timezone.utc).date()


# --------------------------------------------------------------------------
# FR-045 / FR-141 — Activity logging + weekly 150-minute goal
# --------------------------------------------------------------------------
class ActivityIn(BaseModel):
    steps: int | None = None
    active_minutes: int | None = None
    walk_duration_sec: int | None = None


@router.post("/activity")
def log_activity(payload: ActivityIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    today = _today()
    row = db.query(ActivityLog).filter(ActivityLog.user_id == user.id, ActivityLog.log_date == today).first()
    if not row:
        row = ActivityLog(user_id=user.id, log_date=today)
        db.add(row)
    if payload.steps is not None:
        row.steps = payload.steps
    if payload.active_minutes is not None:
        row.active_minutes = payload.active_minutes
    if payload.walk_duration_sec is not None:
        row.walk_duration_sec = (row.walk_duration_sec or 0) + payload.walk_duration_sec
    db.commit()
    db.refresh(row)
    return {"log_date": row.log_date.isoformat(), "steps": row.steps,
            "active_minutes": row.active_minutes, "walk_duration_sec": row.walk_duration_sec}


@router.get("/activity/weekly-goal")
def weekly_goal(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """WHO 150 active-minutes/week goal (FR-141)."""
    week_start = _today() - timedelta(days=6)
    rows = db.query(ActivityLog).filter(ActivityLog.user_id == user.id, ActivityLog.log_date >= week_start).all()
    total = sum(r.active_minutes or 0 for r in rows)
    goal = 150
    return {"active_minutes": total, "goal_minutes": goal,
            "percent": min(100, round(total / goal * 100)) if goal else 0,
            "days_logged": len(rows)}


# --------------------------------------------------------------------------
# FR-046 — Cessation streaks
# --------------------------------------------------------------------------
class CessationIn(BaseModel):
    type: CessationType
    start_date: date | None = None
    goal: str | None = None


@router.post("/cessation")
def set_cessation(payload: CessationIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(CessationTracking).filter(
        CessationTracking.user_id == user.id, CessationTracking.type == payload.type).first()
    if not row:
        row = CessationTracking(user_id=user.id, type=payload.type)
        db.add(row)
    row.start_date = payload.start_date or _today()
    row.goal = payload.goal
    db.commit()
    db.refresh(row)
    return _cessation_out(row)


@router.get("/cessation")
def list_cessation(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(CessationTracking).filter(CessationTracking.user_id == user.id).all()
    return [_cessation_out(r) for r in rows]


def _cessation_out(r: CessationTracking) -> dict:
    streak = (_today() - r.start_date).days if r.start_date else 0
    return {"type": r.type.value, "start_date": r.start_date.isoformat() if r.start_date else None,
            "current_streak_days": max(0, streak), "goal": r.goal}


# --------------------------------------------------------------------------
# FR-067 / FR-142 — Journal (decision-making + gratitude)
# --------------------------------------------------------------------------
class JournalIn(BaseModel):
    type: JournalType
    body: str
    shared_with_care_team: bool = False


@router.post("/journal")
def add_journal(payload: JournalIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = JournalEntry(user_id=user.id, type=payload.type, body=payload.body,
                       shared_with_care_team=payload.shared_with_care_team,
                       is_private=not payload.shared_with_care_team, entry_date=_today())
    db.add(row)
    db.commit()
    db.refresh(row)
    return _journal_out(row)


@router.get("/journal")
def list_journal(type: str | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = db.query(JournalEntry).filter(JournalEntry.user_id == user.id)
    if type:
        try:
            q = q.filter(JournalEntry.type == JournalType(type))
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid journal type.")
    rows = q.order_by(JournalEntry.entry_date.desc().nullslast(), JournalEntry.created_at.desc()).all()
    return [_journal_out(r) for r in rows]


def _journal_out(r: JournalEntry) -> dict:
    return {"id": str(r.id), "type": r.type.value, "body": r.body,
            "shared_with_care_team": r.shared_with_care_team,
            "entry_date": r.entry_date.isoformat() if r.entry_date else None}


# --------------------------------------------------------------------------
# FR-140 — Daily habits + streaks
# --------------------------------------------------------------------------
class HabitIn(BaseModel):
    habit: HabitType
    done: bool = True


@router.post("/habits")
def log_habit(payload: HabitIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    today = _today()
    row = db.query(HabitLog).filter(HabitLog.user_id == user.id, HabitLog.habit == payload.habit,
                                    HabitLog.log_date == today).first()
    if not row:
        row = HabitLog(user_id=user.id, habit=payload.habit, log_date=today)
        db.add(row)
    row.done = payload.done
    db.commit()
    return {"habit": payload.habit.value, "done": row.done, "log_date": today.isoformat()}


@router.get("/habits/today")
def habits_today(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    today = _today()
    done = {h.habit for h in db.query(HabitLog).filter(HabitLog.user_id == user.id, HabitLog.log_date == today, HabitLog.done.is_(True))}
    return [{"habit": h.value, "done": h in done} for h in HabitType]


@router.get("/habits/streak")
def habit_streak(habit: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        h = HabitType(habit)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid habit.")
    done_dates = {r.log_date for r in db.query(HabitLog).filter(
        HabitLog.user_id == user.id, HabitLog.habit == h, HabitLog.done.is_(True))}
    streak, d = 0, _today()
    while d in done_dates:
        streak += 1
        d -= timedelta(days=1)
    return {"habit": h.value, "streak_days": streak}


# --------------------------------------------------------------------------
# FR-123 — Return-to-work plan
# --------------------------------------------------------------------------
# Typical recovery-to-work timelines after cardiac surgery (weeks).
_RTW_WEEKS = {JobType.desk: 6, JobType.light_physical: 8, JobType.heavy_physical: 12}


class RTWIn(BaseModel):
    job_type: JobType


@router.post("/return-to-work")
def set_rtw(payload: RTWIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    weeks = _RTW_WEEKS[payload.job_type]
    base = user.surgery_date or _today()
    target = base + timedelta(weeks=weeks)
    plan = {
        "guidance": f"Most patients with a {payload.job_type.value.replace('_', ' ')} job return to work around {weeks} weeks after surgery.",
        "milestones": [
            {"week": 2, "note": "Light daily activity, short walks."},
            {"week": weeks // 2, "note": "Build stamina; discuss phased return with your employer."},
            {"week": weeks, "note": "Typical return-to-work point — confirm with your surgeon."},
        ],
    }
    row = db.query(ReturnToWorkPlan).filter(ReturnToWorkPlan.user_id == user.id).first()
    if not row:
        row = ReturnToWorkPlan(user_id=user.id)
        db.add(row)
    row.job_type = payload.job_type
    row.target_date = target
    row.plan = plan
    db.commit()
    return {"job_type": payload.job_type.value, "target_date": target.isoformat(), "plan": plan}


@router.get("/return-to-work")
def get_rtw(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(ReturnToWorkPlan).filter(ReturnToWorkPlan.user_id == user.id).first()
    if not row:
        return {"job_type": None, "target_date": None, "plan": None}
    return {"job_type": row.job_type.value if row.job_type else None,
            "target_date": row.target_date.isoformat() if row.target_date else None, "plan": row.plan}


# --------------------------------------------------------------------------
# FR-120 — Rehab-centre enrolment
# --------------------------------------------------------------------------
@router.get("/rehab")
def get_rehab(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(RehabEnrollment).filter(RehabEnrollment.user_id == user.id).first()
    if not row:
        return {"enrolled": False}
    return {"enrolled": True, "program_overview": row.program_overview,
            "start_date": row.start_date.isoformat() if row.start_date else None,
            "what_to_bring": row.what_to_bring}


# --------------------------------------------------------------------------
# FR-164 — Recovery prediction (rule-based on-track %)
# --------------------------------------------------------------------------
_EXPECTED_BY_PHASE = {
    PhaseKey.diagnosis: 5, PhaseKey.preop: 20, PhaseKey.surgery: 40,
    PhaseKey.inpatient: 60, PhaseKey.rehab: 80, PhaseKey.thriving: 100,
}


@router.get("/recovery/prediction")
def recovery_prediction(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Compares actual journey progress against the expected curve for the
    patient's current stage. Rule-based now; ML later (FR-164)."""
    phase = user.current_phase or PhaseKey.diagnosis
    expected = _EXPECTED_BY_PHASE.get(phase, 5)
    actual = user.journey_progress or 0.0
    on_track = round(min(100, (actual / expected * 100) if expected else 100), 1)
    status_label = "ahead" if actual >= expected else ("on_track" if on_track >= 85 else "behind")
    return {"current_phase": phase.value, "actual_progress": actual,
            "expected_progress": expected, "on_track_pct": on_track, "status": status_label}
