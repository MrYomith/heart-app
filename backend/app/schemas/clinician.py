"""Clinician dashboard schemas (FR-282–286)."""
from pydantic import BaseModel


class ClinicianPatientOut(BaseModel):
    id: str
    name: str
    surgery_type: str | None
    current_phase: str
    journey_progress: float
    alert_level: str   # red | amber | green
    open_alerts: int


class AlertOut(BaseModel):
    id: str
    patient_id: str
    patient_name: str
    type: str
    severity: str      # critical | warning | info
    triggered_at: str | None
    acknowledged: bool


class VitalPoint(BaseModel):
    type: str
    value: float
    recorded_at: str | None


class ScoreOut(BaseModel):
    score_type: str
    score: int
    severity: str | None
    administered_at: str | None


class WoundPhotoSummary(BaseModel):
    id: str
    day_post_op: int | None
    uploaded_at: str | None
    reviewed: bool


class PatientDetailOut(BaseModel):
    id: str
    name: str
    email: str
    surgery_type: str | None
    surgery_date: str | None
    nyha_class: str | None
    current_phase: str
    journey_progress: float
    open_alerts: list[AlertOut]
    recent_pain: list[VitalPoint]
    recent_mood: list[VitalPoint]
    clinical_scores: list[ScoreOut]
    wound_photos: list[WoundPhotoSummary]
    medications: list[dict]
