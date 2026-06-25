from pydantic import BaseModel


class JourneyPhaseOut(BaseModel):
    id: str
    phase_key: str
    label: str
    emoji: str | None = None
    status: str
    date_label: str | None = None
    subtitle: str | None = None
    order: int

    @classmethod
    def from_row(cls, p) -> "JourneyPhaseOut":
        return cls(
            id=str(p.id),
            phase_key=p.phase_key.value if p.phase_key else "",
            label=p.label,
            emoji=p.emoji,
            status=p.status.value if p.status else "upcoming",
            date_label=p.date_label,
            subtitle=p.subtitle,
            order=p.sort_order or 0,
        )
