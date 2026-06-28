"""Patient settings: notification preferences, language, and GDPR data rights.

Powers the "Support" section of the app's More screen:
  - Notifications: quiet hours + muted categories (FR-304). Critical alerts can
    never be muted.
  - Language: switch locale en/de (FR-300). The UI translation itself is a separate
    content task; this persists the choice.
  - Privacy & data: GDPR access (export) and erasure (deletion) (FR-305, NFR-042/043).
    Export is generated inline (no external storage needed); deletion soft-deletes
    the account and logs the request for the audit trail.
"""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.enums import DataRequestStatus, DataRequestType, NotificationCategory
from app.models import (
    Appointment,
    ClinicalScore,
    ConsentLog,
    DataRequest,
    JournalEntry,
    Medication,
    NotificationPreference,
    Task,
    User,
    Vital,
)

router = APIRouter(prefix="/api/settings", tags=["settings"])

# Critical safety alerts are never mutable (PRD: safety alerts always delivered).
_UNMUTABLE = {NotificationCategory.critical.value, NotificationCategory.alert.value}
_VALID_CATEGORIES = {c.value for c in NotificationCategory}
_VALID_LOCALES = {"en", "de"}


# --------------------------------------------------------------------------
# Notification preferences
# --------------------------------------------------------------------------
class NotificationPrefsIn(BaseModel):
    muted_categories: list[str] = Field(default_factory=list)
    quiet_hours_start: str = "22:00"
    quiet_hours_end: str = "07:00"


class NotificationPrefsOut(BaseModel):
    muted_categories: list[str]
    quiet_hours_start: str
    quiet_hours_end: str
    unmutable_categories: list[str]


def _get_or_create_prefs(user: User, db: Session) -> NotificationPreference:
    prefs = db.query(NotificationPreference).filter(NotificationPreference.user_id == user.id).first()
    if prefs is None:
        prefs = NotificationPreference(user_id=user.id, muted_categories=[])
        db.add(prefs)
        db.commit()
        db.refresh(prefs)
    return prefs


@router.get("/notifications", response_model=NotificationPrefsOut)
def get_notification_prefs(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    prefs = _get_or_create_prefs(user, db)
    return NotificationPrefsOut(
        muted_categories=prefs.muted_categories or [],
        quiet_hours_start=prefs.quiet_hours_start,
        quiet_hours_end=prefs.quiet_hours_end,
        unmutable_categories=sorted(_UNMUTABLE),
    )


@router.put("/notifications", response_model=NotificationPrefsOut)
def update_notification_prefs(
    payload: NotificationPrefsIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    invalid = [c for c in payload.muted_categories if c not in _VALID_CATEGORIES]
    if invalid:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown notification categories: {invalid}")
    # Silently drop attempts to mute safety-critical categories.
    muted = [c for c in payload.muted_categories if c not in _UNMUTABLE]

    prefs = _get_or_create_prefs(user, db)
    prefs.muted_categories = muted
    prefs.quiet_hours_start = payload.quiet_hours_start
    prefs.quiet_hours_end = payload.quiet_hours_end
    db.commit()
    db.refresh(prefs)
    return NotificationPrefsOut(
        muted_categories=prefs.muted_categories or [],
        quiet_hours_start=prefs.quiet_hours_start,
        quiet_hours_end=prefs.quiet_hours_end,
        unmutable_categories=sorted(_UNMUTABLE),
    )


# --------------------------------------------------------------------------
# Language / locale
# --------------------------------------------------------------------------
class LocaleIn(BaseModel):
    locale: str


@router.patch("/locale")
def set_locale(payload: LocaleIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    loc = payload.locale.lower().strip()
    if loc not in _VALID_LOCALES:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Locale must be 'en' or 'de'.")
    user.locale = loc
    db.commit()
    return {"locale": loc}


# --------------------------------------------------------------------------
# GDPR data rights
# --------------------------------------------------------------------------
def _serialise(rows) -> list[dict]:
    out = []
    for r in rows:
        d = {}
        for col in r.__table__.columns:
            val = getattr(r, col.name)
            d[col.name] = val.isoformat() if isinstance(val, datetime) else (str(val) if val is not None and not isinstance(val, (int, float, bool, str, list, dict)) else val)
        out.append(d)
    return out


@router.post("/data-export")
def export_my_data(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """GDPR right of access — returns the patient's data inline as JSON and logs
    the request. (No external storage required.)"""
    now = datetime.now(timezone.utc)
    req = DataRequest(
        user_id=user.id, type=DataRequestType.export,
        status=DataRequestStatus.complete, requested_at=now, completed_at=now,
    )
    db.add(req)
    db.commit()

    def for_user(model):
        return db.query(model).filter(model.user_id == user.id).all()

    return {
        "generated_at": now.isoformat(),
        "profile": _serialise([user])[0],
        "vitals": _serialise(for_user(Vital)),
        "tasks": _serialise(for_user(Task)),
        "medications": _serialise(for_user(Medication)),
        "journal_entries": _serialise(for_user(JournalEntry)),
        "clinical_scores": _serialise(for_user(ClinicalScore)),
        "appointments": _serialise(for_user(Appointment)),
        "consent_log": _serialise(for_user(ConsentLog)),
    }


class DeletionIn(BaseModel):
    confirm: bool = False


@router.post("/data-deletion")
def request_deletion(
    payload: DeletionIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """GDPR right to erasure — logs the request and soft-deletes the account.
    Audit/consent logs are retained (append-only) as legally required."""
    if not payload.confirm:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Deletion must be explicitly confirmed.")
    now = datetime.now(timezone.utc)
    db.add(DataRequest(
        user_id=user.id, type=DataRequestType.deletion,
        status=DataRequestStatus.complete, requested_at=now, completed_at=now,
    ))
    user.deleted_at = now
    user.is_active = False
    db.commit()
    return {"status": "deleted", "message": "Your account has been scheduled for deletion."}


@router.get("/data-requests")
def list_data_requests(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(DataRequest)
        .filter(DataRequest.user_id == user.id)
        .order_by(DataRequest.requested_at.desc().nullslast())
        .all()
    )
    return [
        {"id": str(r.id), "type": r.type.value, "status": r.status.value,
         "requested_at": r.requested_at.isoformat() if r.requested_at else None,
         "completed_at": r.completed_at.isoformat() if r.completed_at else None}
        for r in rows
    ]
