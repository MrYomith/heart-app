"""Domain 10 — Appointments, Rehab, Surgery Day, Recordings."""
import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import AppointmentType, RecordingType, TheatreEvent
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class Appointment(Base, TimestampMixin):
    __tablename__ = "appointments"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String, nullable=False)
    subtitle: Mapped[str | None] = mapped_column(String, nullable=True)
    date: Mapped[str] = mapped_column(String, nullable=False)
    time: Mapped[str | None] = mapped_column(String, nullable=True)
    location: Mapped[str | None] = mapped_column(String, nullable=True)
    hospital_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("hospitals.id"), nullable=True)
    appointment_type: Mapped[AppointmentType] = mapped_column(Enum(AppointmentType), default=AppointmentType.followup)
    is_confirmed: Mapped[bool] = mapped_column(Boolean, default=True)


class RehabEnrollment(Base, TimestampMixin):
    __tablename__ = "rehab_enrollments"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    hospital_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("hospitals.id"), nullable=True)
    program_overview: Mapped[str | None] = mapped_column(Text, nullable=True)
    start_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    what_to_bring: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)


class Recording(Base, TimestampMixin):
    __tablename__ = "recordings"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[RecordingType] = mapped_column(Enum(RecordingType), nullable=False)
    s3_key: Mapped[str] = mapped_column(String, nullable=False)
    duration_sec: Mapped[int | None] = mapped_column(Integer, nullable=True)
    for_carer_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    uploaded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class TheatreStatusEvent(Base):
    __tablename__ = "theatre_status_events"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    event: Mapped[TheatreEvent] = mapped_column(Enum(TheatreEvent), nullable=False)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    recorded_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
