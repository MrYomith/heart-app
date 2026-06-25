"""Domain 5 — Clinical Tracking."""
import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.types import Uuid

from app.database import Base
from app.enums import (
    AlertSeverity,
    AlertType,
    ScoreType,
    Severity,
    SymptomType,
    VitalSource,
    VitalType,
)
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class Vital(Base):
    __tablename__ = "vitals"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[VitalType] = mapped_column(Enum(VitalType), nullable=False)
    value: Mapped[float] = mapped_column(Float, nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    source: Mapped[VitalSource] = mapped_column(Enum(VitalSource), default=VitalSource.manual)


class ClinicalScore(Base):
    __tablename__ = "clinical_scores"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    score_type: Mapped[ScoreType] = mapped_column(Enum(ScoreType), nullable=False)
    score: Mapped[int] = mapped_column(Integer, nullable=False)
    answers: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    severity: Mapped[Severity | None] = mapped_column(Enum(Severity), nullable=True)
    administered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    scheduled_week: Mapped[int | None] = mapped_column(Integer, nullable=True)


class Alert(Base):
    __tablename__ = "alerts"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[AlertType] = mapped_column(Enum(AlertType), nullable=False)
    severity: Mapped[AlertSeverity] = mapped_column(Enum(AlertSeverity), nullable=False)
    triggered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    source_ref: Mapped[uuid.UUID | None] = mapped_column(Uuid, nullable=True)
    acked_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    acked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    resolution_note: Mapped[str | None] = mapped_column(Text, nullable=True)


class SymptomReport(Base):
    __tablename__ = "symptom_reports"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    symptom: Mapped[SymptomType] = mapped_column(Enum(SymptomType), nullable=False)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    reported_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class WoundPhoto(Base, TimestampMixin):
    __tablename__ = "wound_photos"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    s3_key: Mapped[str] = mapped_column(String, nullable=False)
    day_post_op: Mapped[int | None] = mapped_column(Integer, nullable=True)
    is_locked: Mapped[bool] = mapped_column(Boolean, default=True)
    uploaded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    reviewed_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    nurse_notes: Mapped[str | None] = mapped_column(Text, nullable=True)


class RecoveryCheckin(Base):
    __tablename__ = "recovery_checkins"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    feeling: Mapped[str | None] = mapped_column(String, nullable=True)
    wound_issues: Mapped[bool] = mapped_column(Boolean, default=False)
    pain_level: Mapped[int | None] = mapped_column(Integer, nullable=True)
    sleep_quality: Mapped[str | None] = mapped_column(String, nullable=True)
    concerns: Mapped[str | None] = mapped_column(Text, nullable=True)
    submitted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class RecoverySnapshot(Base):
    __tablename__ = "recovery_snapshots"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    snapshot_date: Mapped[date] = mapped_column(Date, nullable=False)
    actual_progress: Mapped[float | None] = mapped_column(Float, nullable=True)
    expected_progress: Mapped[float | None] = mapped_column(Float, nullable=True)
    on_track_pct: Mapped[float | None] = mapped_column(Float, nullable=True)
