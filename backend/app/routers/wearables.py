"""Wearable / phone health-data ingest (FR-240–243).

The Flutter app reads from Apple HealthKit (iOS) / Android Health Connect and
POSTs batches here; this backend just stores connections + the time-series. A
high heart rate raises a clinician alert, closing the same loop as manual vitals.
"""
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import (
    AlertSeverity,
    AlertType,
    WearableMetric,
    WearableProvider,
    WearableStatus,
)
from app.models import Alert, User, WearableConnection, WearableReading

router = APIRouter(prefix="/api/wearables", tags=["wearables"])

# Resting-HR ceiling that warrants a clinician warning (post-cardiac-surgery).
_HR_ALERT_THRESHOLD = 120


def _now() -> datetime:
    return datetime.now(timezone.utc)


# --------------------------------------------------------------------------
# Connections
# --------------------------------------------------------------------------
class ConnectIn(BaseModel):
    provider: WearableProvider


@router.get("/connections")
def list_connections(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(WearableConnection).filter(WearableConnection.user_id == user.id).all()
    return [{"provider": c.provider.value, "status": c.status.value,
             "last_sync_at": c.last_sync_at.isoformat() if c.last_sync_at else None} for c in rows]


@router.post("/connect")
def connect(payload: ConnectIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = db.query(WearableConnection).filter(
        WearableConnection.user_id == user.id, WearableConnection.provider == payload.provider).first()
    if not c:
        c = WearableConnection(user_id=user.id, provider=payload.provider)
        db.add(c)
    c.status = WearableStatus.connected
    c.last_sync_at = _now()
    db.commit()
    return {"provider": c.provider.value, "status": c.status.value}


@router.post("/disconnect")
def disconnect(payload: ConnectIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = db.query(WearableConnection).filter(
        WearableConnection.user_id == user.id, WearableConnection.provider == payload.provider).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Not connected.")
    c.status = WearableStatus.disconnected
    db.commit()
    return {"provider": c.provider.value, "status": c.status.value}


# --------------------------------------------------------------------------
# Readings ingest (batch) + query
# --------------------------------------------------------------------------
class ReadingIn(BaseModel):
    metric: WearableMetric
    value: float
    unit: str | None = None
    recorded_at: datetime | None = None


class BatchIn(BaseModel):
    provider: WearableProvider | None = None
    readings: list[ReadingIn]


@router.post("/readings")
def ingest(payload: BatchIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Bulk-ingest readings synced from the phone. Returns count stored + any alert raised."""
    now = _now()
    source = payload.provider.value if payload.provider else "wearable"
    stored = 0
    max_hr = 0.0
    for r in payload.readings:
        db.add(WearableReading(
            user_id=user.id, metric=r.metric, value=r.value, unit=r.unit,
            source=source, recorded_at=r.recorded_at or now,
        ))
        stored += 1
        if r.metric == WearableMetric.heart_rate:
            max_hr = max(max_hr, r.value)

    # Keep the connection's last_sync fresh.
    if payload.provider:
        conn = db.query(WearableConnection).filter(
            WearableConnection.user_id == user.id, WearableConnection.provider == payload.provider).first()
        if conn:
            conn.last_sync_at = now

    alert_raised = False
    if max_hr >= _HR_ALERT_THRESHOLD:
        # Avoid duplicate open HR alerts.
        existing = db.query(Alert).filter(
            Alert.patient_id == user.id, Alert.type == AlertType.abnormal_vital, Alert.resolved_at.is_(None)).first()
        if not existing:
            db.add(Alert(patient_id=user.id, type=AlertType.abnormal_vital,
                         severity=AlertSeverity.warning, triggered_at=now))
            alert_raised = True

    db.commit()
    return {"stored": stored, "alert_raised": alert_raised}


@router.get("/readings")
def list_readings(metric: str, days: int = 7, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        m = WearableMetric(metric)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid metric.")
    since = _now() - timedelta(days=days)
    rows = (
        db.query(WearableReading)
        .filter(WearableReading.user_id == user.id, WearableReading.metric == m, WearableReading.recorded_at >= since)
        .order_by(WearableReading.recorded_at.desc())
        .all()
    )
    return [{"value": r.value, "unit": r.unit, "recorded_at": r.recorded_at.isoformat(), "source": r.source} for r in rows]


@router.get("/summary")
def summary(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Latest value per metric — powers the Home wearable tile (FR-023)."""
    out = {}
    for m in WearableMetric:
        last = (
            db.query(WearableReading)
            .filter(WearableReading.user_id == user.id, WearableReading.metric == m)
            .order_by(WearableReading.recorded_at.desc())
            .first()
        )
        if last:
            out[m.value] = {"value": last.value, "unit": last.unit,
                            "recorded_at": last.recorded_at.isoformat()}
    return out
