"""Domain 6 — Lifestyle Logs."""
import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import (
    BreathingSessionType,
    CessationType,
    HabitType,
    JobType,
    JournalType,
    MobilisationMilestone,
)
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class NutritionLog(Base, TimestampMixin):
    __tablename__ = "nutrition_logs"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    log_date: Mapped[date] = mapped_column(Date, nullable=False)
    protein_grams: Mapped[int | None] = mapped_column(Integer, nullable=True)
    hydration_glasses: Mapped[int | None] = mapped_column(Integer, nullable=True)
    meals_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bowel_movement: Mapped[bool] = mapped_column(Boolean, default=False)


class ActivityLog(Base, TimestampMixin):
    __tablename__ = "activity_logs"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    log_date: Mapped[date] = mapped_column(Date, nullable=False)
    steps: Mapped[int | None] = mapped_column(Integer, nullable=True)
    active_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    walk_duration_sec: Mapped[int | None] = mapped_column(Integer, nullable=True)
    source: Mapped[str] = mapped_column(String, default="manual")


class BreathingSession(Base, TimestampMixin):
    __tablename__ = "breathing_sessions"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    session_type: Mapped[BreathingSessionType] = mapped_column(Enum(BreathingSessionType), nullable=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    scheduled_slot: Mapped[str | None] = mapped_column(String, nullable=True)


class MobilisationMilestoneLog(Base, TimestampMixin):
    __tablename__ = "mobilisation_milestones"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    milestone: Mapped[MobilisationMilestone] = mapped_column(Enum(MobilisationMilestone), nullable=False)
    target: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)  # physio-set
    achieved: Mapped[bool] = mapped_column(Boolean, default=False)
    achieved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    set_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)


class HabitLog(Base, TimestampMixin):
    __tablename__ = "habit_logs"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    log_date: Mapped[date] = mapped_column(Date, nullable=False)
    habit: Mapped[HabitType] = mapped_column(Enum(HabitType), nullable=False)
    done: Mapped[bool] = mapped_column(Boolean, default=False)


class CessationTracking(Base, TimestampMixin):
    __tablename__ = "cessation_tracking"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[CessationType] = mapped_column(Enum(CessationType), nullable=False)
    start_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    current_streak_days: Mapped[int] = mapped_column(Integer, default=0)
    goal: Mapped[str | None] = mapped_column(String, nullable=True)


class JournalEntry(Base, TimestampMixin):
    __tablename__ = "journal_entries"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[JournalType] = mapped_column(Enum(JournalType), nullable=False)
    body: Mapped[str | None] = mapped_column(Text, nullable=True)
    photo_s3_key: Mapped[str | None] = mapped_column(String, nullable=True)
    is_private: Mapped[bool] = mapped_column(Boolean, default=True)
    shared_with_care_team: Mapped[bool] = mapped_column(Boolean, default=False)
    entry_date: Mapped[date | None] = mapped_column(Date, nullable=True)


class ReturnToWorkPlan(Base, TimestampMixin):
    __tablename__ = "return_to_work_plans"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    job_type: Mapped[JobType] = mapped_column(Enum(JobType), nullable=False)
    target_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    plan: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
