from pydantic import BaseModel


class MedicationOut(BaseModel):
    id: str
    name: str
    dose: str | None = None
    schedule: str | None = None
    times: list[str] = []
    is_anticoagulant: bool = False
    purpose: str | None = None
    taken_today: bool = False

    @classmethod
    def from_row(cls, m, taken_today: bool = False) -> "MedicationOut":
        return cls(
            id=str(m.id),
            name=m.name,
            dose=m.dose,
            schedule=m.schedule,
            times=[t.strip() for t in (m.times or "").split(",") if t.strip()],
            is_anticoagulant=m.is_anticoagulant,
            purpose=m.purpose_de,
            taken_today=taken_today,
        )
