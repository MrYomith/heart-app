"""Onboarding + enrollment request/response schemas."""
from pydantic import BaseModel, Field


class OnboardingSave(BaseModel):
    """Partial save for resume (FR-010)."""
    current_step: int
    step_data: dict | None = None


class OnboardingProgressOut(BaseModel):
    current_step: int
    step_data: dict | None = None
    completed: bool


class OnboardingComplete(BaseModel):
    """Final submission of the wizard. All fields optional except where noted."""
    date_of_birth: str | None = None  # ISO yyyy-mm-dd
    surgery_type: str | None = None   # cabg|valve|tavi|aortic|combined|none
    surgery_date: str | None = None   # ISO yyyy-mm-dd, or null = not scheduled
    nyha_class: str | None = None     # I|II|III|IV
    diagnosis: str | None = None
    conditions: list[str] = Field(default_factory=list)
    allergies: list[str] = Field(default_factory=list)
    gad7_answers: list[int] = Field(default_factory=list)  # 7 ints, each 0-3


class HospitalOut(BaseModel):
    id: str
    name: str
    city: str | None = None
    type: str

    @classmethod
    def from_row(cls, h) -> "HospitalOut":
        return cls(id=str(h.id), name=h.name, city=h.city, type=h.type.value)


class EnrollByCode(BaseModel):
    code: str


class EnrollRequest(BaseModel):
    hospital_id: str


class EnrollmentStatusOut(BaseModel):
    status: str            # none | pending | approved | rejected
    hospital_id: str | None = None
    hospital_name: str | None = None
    # populated on the coordinator's pending-list view
    enrollment_id: str | None = None
    patient_name: str | None = None
    patient_email: str | None = None
