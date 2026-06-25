"""Domain 2 — Onboarding & Medical Profile."""
import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import ConditionSource, GoalType, MedicationLogStatus, PhaseKey
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class OnboardingProgress(Base, TimestampMixin):
    __tablename__ = "onboarding_progress"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    current_step: Mapped[int] = mapped_column(Integer, default=1)
    step_data: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)


class PatientCondition(Base, TimestampMixin):
    __tablename__ = "patient_conditions"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    condition: Mapped[str] = mapped_column(String, nullable=False)
    source: Mapped[ConditionSource] = mapped_column(Enum(ConditionSource), default=ConditionSource.onboarding)


class PatientAllergy(Base, TimestampMixin):
    __tablename__ = "patient_allergies"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    allergy: Mapped[str] = mapped_column(String, nullable=False)


class Medication(Base, TimestampMixin):
    __tablename__ = "medications"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    dose: Mapped[str | None] = mapped_column(String, nullable=True)
    schedule: Mapped[str | None] = mapped_column(String, nullable=True)
    times: Mapped[str | None] = mapped_column(String, nullable=True)  # csv "08:00,20:00"
    is_anticoagulant: Mapped[bool] = mapped_column(Boolean, default=False)
    stop_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    bridge_protocol: Mapped[str | None] = mapped_column(Text, nullable=True)
    purpose_de: Mapped[str | None] = mapped_column(Text, nullable=True)
    phase: Mapped[PhaseKey | None] = mapped_column(Enum(PhaseKey), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class MedicationLog(Base, TimestampMixin):
    __tablename__ = "medication_logs"

    id: Mapped[uuid.UUID] = uuid_pk()
    medication_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("medications.id"), index=True, nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    scheduled_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    taken_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[MedicationLogStatus] = mapped_column(Enum(MedicationLogStatus), default=MedicationLogStatus.taken)


class Goal(Base, TimestampMixin):
    __tablename__ = "goals"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[GoalType] = mapped_column(Enum(GoalType), nullable=False)
    description: Mapped[str | None] = mapped_column(String, nullable=True)
    target_value: Mapped[str | None] = mapped_column(String, nullable=True)
    target_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    achieved: Mapped[bool] = mapped_column(Boolean, default=False)
