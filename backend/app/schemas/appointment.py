from pydantic import BaseModel


class AppointmentOut(BaseModel):
    id: str
    title: str
    subtitle: str | None = None
    date: str
    time: str | None = None
    location: str | None = None
    appointment_type: str
    is_confirmed: bool

    @classmethod
    def from_row(cls, a) -> "AppointmentOut":
        return cls(
            id=str(a.id),
            title=a.title,
            subtitle=a.subtitle,
            date=a.date,
            time=a.time,
            location=a.location,
            appointment_type=a.appointment_type.value if a.appointment_type else "followup",
            is_confirmed=a.is_confirmed,
        )
