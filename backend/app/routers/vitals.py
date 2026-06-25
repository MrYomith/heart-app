"""Vitals logging for the authenticated patient (FR-041 mood, FR-100 pain, FR-243 manual).

Logs a reading and runs simple clinical-threshold checks (e.g. 3 low-mood days → alert).
"""
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import AlertSeverity, AlertType, VitalSource, VitalType
from app.models import Alert, User, Vital
from app.schemas.vitals import VitalCreate, VitalLogResult, VitalOut

router = APIRouter(prefix="/api/vitals", tags=["vitals"])

MOOD_LOW = 2  # on a 1–5 scale (1 very low … 5 very good)
PAIN_HIGH = 7  # 0–10 NRS; ≥7 escalates to the nurse (FR-100)
_PAIN_TYPES = {VitalType.pain_rest, VitalType.pain_cough, VitalType.pain_move}


def _check_pain_escalation(db: Session, user_id, value: float, now: datetime) -> bool:
    """FR-100: a pain score ≥7 alerts the assigned nurse (within seconds)."""
    if value < PAIN_HIGH:
        return False
    existing = (
        db.query(Alert)
        .filter(
            Alert.patient_id == user_id,
            Alert.type == AlertType.pain_high,
            Alert.resolved_at.is_(None),
            Alert.triggered_at >= now - timedelta(hours=1),
        )
        .first()
    )
    if existing:
        return False
    db.add(Alert(
        patient_id=user_id,
        type=AlertType.pain_high,
        severity=AlertSeverity.critical,
        triggered_at=now,
    ))
    return True


def _check_mood_escalation(db: Session, user_id, now: datetime) -> bool:
    """FR-105: 3 consecutive days of low mood → warn the care team."""
    since = now - timedelta(days=3)
    rows = (
        db.query(Vital)
        .filter(Vital.user_id == user_id, Vital.type == VitalType.mood, Vital.recorded_at >= since)
        .all()
    )
    low_days = {v.recorded_at.date() for v in rows if v.value <= MOOD_LOW}
    if len(low_days) < 3:
        return False
    # de-dupe: skip if an unresolved mood alert already exists in the last day
    existing = (
        db.query(Alert)
        .filter(
            Alert.patient_id == user_id,
            Alert.type == AlertType.mood_low_3day,
            Alert.resolved_at.is_(None),
            Alert.triggered_at >= now - timedelta(days=1),
        )
        .first()
    )
    if existing:
        return False
    db.add(Alert(
        patient_id=user_id,
        type=AlertType.mood_low_3day,
        severity=AlertSeverity.warning,
        triggered_at=now,
    ))
    return True


@router.post("", response_model=VitalLogResult, status_code=201)
def log_vital(payload: VitalCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        vtype = VitalType(payload.type)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown vital type: {payload.type}")

    now = datetime.now(timezone.utc)
    recorded = now
    if payload.recorded_at:
        try:
            recorded = datetime.fromisoformat(payload.recorded_at)
        except ValueError:
            pass

    vital = Vital(user_id=user.id, type=vtype, value=payload.value, recorded_at=recorded, source=VitalSource.manual)
    db.add(vital)
    db.flush()

    alert_raised = False
    message = None
    if vtype == VitalType.mood:
        alert_raised = _check_mood_escalation(db, user.id, now)
        if alert_raised:
            message = "We've let your care team know you've had a few tough days. You're not alone. 🤍"
    elif vtype in _PAIN_TYPES:
        if _check_pain_escalation(db, user.id, payload.value, now):
            alert_raised = True
            message = "Your nurse has been alerted about your pain and will check on you shortly."

    db.commit()
    db.refresh(vital)
    return VitalLogResult(vital=VitalOut.from_row(vital), alert_raised=alert_raised, message=message)


@router.get("/latest")
def latest_vitals(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Latest value per vital type — powers the patient's clinical metric cards.

    Single query (newest-first) and keep the first row seen per type, instead of
    one query per VitalType (which was ~14 sequential round-trips to Neon)."""
    rows = (
        db.query(Vital)
        .filter(Vital.user_id == user.id)
        .order_by(Vital.recorded_at.desc())
        .all()
    )
    out: dict[str, dict] = {}
    for v in rows:
        key = v.type.value
        if key not in out:
            out[key] = {"value": v.value, "recorded_at": v.recorded_at.isoformat() if v.recorded_at else None}
    return out


@router.get("", response_model=list[VitalOut])
def list_vitals(type: str, days: int = 30, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        vtype = VitalType(type)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown vital type: {type}")
    since = datetime.now(timezone.utc) - timedelta(days=days)
    rows = (
        db.query(Vital)
        .filter(Vital.user_id == user.id, Vital.type == vtype, Vital.recorded_at >= since)
        .order_by(Vital.recorded_at)
        .all()
    )
    return [VitalOut.from_row(v) for v in rows]
