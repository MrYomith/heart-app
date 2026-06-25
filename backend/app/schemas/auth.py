"""Auth request/response schemas."""
from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    name: str = Field(min_length=1)
    email: EmailStr
    password: str
    consent_accepted: bool = Field(description="GDPR consent must be ticked (FR-001)")


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserPublic(BaseModel):
    id: str
    email: str
    name: str
    role: str
    onboarding_complete: bool
    current_phase: str | None = None
    journey_progress: float = 0.0
    surgery_type: str | None = None
    surgery_date: str | None = None
    # Full clinical profile (set by the clinician) — drives personalised journey screens.
    discharge_date: str | None = None
    surgeon_name: str | None = None
    diagnosis: str | None = None
    nyha_class: str | None = None
    hospital_name: str | None = None
    surgeon_message: str | None = None

    @classmethod
    def from_user(cls, u) -> "UserPublic":
        """Build explicitly so str-enums and dates serialize to plain values."""
        hosp = getattr(u, "hospital", None)
        return cls(
            id=str(u.id),
            email=u.email,
            name=u.name,
            role=u.role.value if u.role else "patient",
            onboarding_complete=u.onboarding_complete,
            current_phase=u.current_phase.value if u.current_phase else None,
            journey_progress=u.journey_progress or 0.0,
            surgery_type=u.surgery_type.value if u.surgery_type else None,
            surgery_date=u.surgery_date.isoformat() if u.surgery_date else None,
            discharge_date=u.discharge_date.isoformat() if u.discharge_date else None,
            surgeon_name=u.surgeon_name,
            diagnosis=u.diagnosis,
            nyha_class=u.nyha_class.value if u.nyha_class else None,
            hospital_name=hosp.name if hosp else None,
            surgeon_message=hosp.surgeon_message if hosp else None,
        )


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPublic
