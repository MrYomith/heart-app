"""Domain 3 — Journey & Stages."""
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import ActivatedBy, PhaseKey, PhaseStatus, TransitionTrigger
from app.models.base import TimestampMixin, uuid_pk


class JourneyPhase(Base, TimestampMixin):
    __tablename__ = "journey_phases"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    phase_key: Mapped[PhaseKey] = mapped_column(Enum(PhaseKey), nullable=False)
    label: Mapped[str] = mapped_column(String, nullable=False)
    emoji: Mapped[str | None] = mapped_column(String, nullable=True)
    status: Mapped[PhaseStatus] = mapped_column(Enum(PhaseStatus), default=PhaseStatus.upcoming)
    date_label: Mapped[str | None] = mapped_column(String, nullable=True)
    subtitle: Mapped[str | None] = mapped_column(String, nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    activated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    activated_by: Mapped[ActivatedBy | None] = mapped_column(Enum(ActivatedBy), nullable=True)


class StageTransition(Base):
    __tablename__ = "stage_transitions"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    from_phase: Mapped[PhaseKey | None] = mapped_column(Enum(PhaseKey), nullable=True)
    to_phase: Mapped[PhaseKey] = mapped_column(Enum(PhaseKey), nullable=False)
    trigger: Mapped[TransitionTrigger] = mapped_column(Enum(TransitionTrigger), nullable=False)
    actor_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
