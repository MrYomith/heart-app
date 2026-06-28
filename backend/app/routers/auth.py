"""Self-hosted authentication: register, login, current user, account deletion.

Swappable for Firebase later without touching other routers.
"""
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.core.config import (
    CONSENT_VERSION,
    LOCKOUT_MINUTES,
    MAX_FAILED_LOGINS,
)
from app.core.security import (
    create_access_token,
    hash_password,
    password_is_strong,
    verify_password,
)
from app.database import get_db
from app.enums import ConsentType
from app.models import ConsentLog, User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, UserPublic

router = APIRouter(prefix="/auth", tags=["auth"])


def _as_aware(dt: datetime | None) -> datetime | None:
    """Coerce a stored timestamp to UTC-aware. PostgreSQL TIMESTAMPTZ already returns
    aware datetimes; SQLite (dev fallback) returns naive ones — treat those as UTC so
    the lockout comparison never mixes naive and aware datetimes."""
    if dt is not None and dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    if not payload.consent_accepted:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "GDPR consent is required to create an account.")
    if not password_is_strong(payload.password):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "Password must be at least 12 characters and include uppercase, lowercase, a digit, and a special character.",
        )

    email = payload.email.lower().strip()
    if db.query(User).filter(User.email == email).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "An account with this email already exists.")

    now = datetime.now(timezone.utc)
    user = User(
        email=email,
        name=payload.name.strip(),
        password_hash=hash_password(payload.password),
        last_login_at=now,
    )
    db.add(user)
    db.flush()  # assign user.id

    # GDPR consent log (NFR-041)
    db.add(
        ConsentLog(
            user_id=user.id,
            consent_type=ConsentType.terms,
            consent_version=CONSENT_VERSION,
            accepted_at=now,
            created_at=now,
        )
    )
    db.commit()
    db.refresh(user)

    return TokenResponse(access_token=create_access_token(user.id), user=UserPublic.from_user(user))


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    email = payload.email.lower().strip()
    user = db.query(User).filter(User.email == email, User.deleted_at.is_(None)).first()

    # Account lockout (FR-002)
    locked_until = _as_aware(user.locked_until) if user else None
    if locked_until and locked_until > now:
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            "Account temporarily locked due to failed login attempts. Try again later.",
        )

    # Generic failure message — no email enumeration (FR-002)
    if user is None or not user.password_hash or not verify_password(payload.password, user.password_hash):
        if user is not None:
            user.failed_login_count = (user.failed_login_count or 0) + 1
            if user.failed_login_count >= MAX_FAILED_LOGINS:
                user.locked_until = now + timedelta(minutes=LOCKOUT_MINUTES)
                user.failed_login_count = 0
            db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Incorrect email or password.")

    # Success — reset counters, stamp login
    user.failed_login_count = 0
    user.locked_until = None
    user.last_login_at = now
    db.commit()
    db.refresh(user)

    return TokenResponse(access_token=create_access_token(user.id), user=UserPublic.from_user(user))


@router.get("/me", response_model=UserPublic)
def me(current_user: User = Depends(get_current_user)):
    return UserPublic.from_user(current_user)


@router.delete("/account", status_code=204)
def delete_account(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """GDPR right to erasure (FR-005): soft-delete + deactivate; anonymise email."""
    now = datetime.now(timezone.utc)
    current_user.deleted_at = now
    current_user.is_active = False
    current_user.email = f"deleted+{current_user.id}@miohart.invalid"
    current_user.password_hash = None
    db.commit()
