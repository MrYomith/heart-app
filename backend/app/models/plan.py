"""Domain 4 — Daily Plan, Tasks & ERAS."""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import ErasItem, SurgeryChecklistCategory, TaskCategory
from app.models.base import TimestampMixin, uuid_pk


class Task(Base, TimestampMixin):
    __tablename__ = "tasks"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String, nullable=False)
    subtitle: Mapped[str | None] = mapped_column(String, nullable=True)
    icon: Mapped[str | None] = mapped_column(String, nullable=True)
    category: Mapped[TaskCategory | None] = mapped_column(Enum(TaskCategory), nullable=True)
    scheduled_time: Mapped[str | None] = mapped_column(String, nullable=True)
    time_color: Mapped[str] = mapped_column(String, default="teal")
    phase: Mapped[str | None] = mapped_column(String, nullable=True)
    task_date: Mapped[str | None] = mapped_column(String, nullable=True)
    is_done: Mapped[bool] = mapped_column(Boolean, default=False)
    priority: Mapped[int] = mapped_column(Integer, default=0)
    reasoning: Mapped[str | None] = mapped_column(Text, nullable=True)  # "why this?" FR-160


class ErasProgress(Base, TimestampMixin):
    __tablename__ = "eras_progress"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    item_key: Mapped[ErasItem] = mapped_column(Enum(ErasItem), nullable=False)
    progress: Mapped[int] = mapped_column(Integer, default=0)  # 0-100
    target: Mapped[int | None] = mapped_column(Integer, nullable=True)


class SurgeryChecklist(Base, TimestampMixin):
    __tablename__ = "surgery_checklist"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    item_key: Mapped[str] = mapped_column(String, nullable=False)
    label: Mapped[str | None] = mapped_column(String, nullable=True)
    is_done: Mapped[bool] = mapped_column(Boolean, default=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    category: Mapped[SurgeryChecklistCategory | None] = mapped_column(
        Enum(SurgeryChecklistCategory), nullable=True
    )
