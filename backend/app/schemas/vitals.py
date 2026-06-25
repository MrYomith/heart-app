"""Vitals: patient-entered clinical readings (mood, pain, spo2, etc.)."""
from pydantic import BaseModel, Field


class VitalCreate(BaseModel):
    type: str  # mood | pain_rest | pain_cough | pain_move | spo2 | heart_rate | weight | temperature | steps | bp_systolic | bp_diastolic
    value: float
    recorded_at: str | None = None  # ISO; defaults to now server-side


class VitalOut(BaseModel):
    id: str
    type: str
    value: float
    recorded_at: str

    @classmethod
    def from_row(cls, v) -> "VitalOut":
        return cls(
            id=str(v.id),
            type=v.type.value if v.type else "",
            value=v.value,
            recorded_at=v.recorded_at.isoformat() if v.recorded_at else "",
        )


class VitalLogResult(BaseModel):
    vital: VitalOut
    alert_raised: bool = False
    message: str | None = None
