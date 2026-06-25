"""Domain 12 — Clinician outputs."""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import (
    PeerMatchStatus,
    PeerMatchType,
    ReferralStatus,
    ReportType,
    SurgeryType,
)
from app.models.base import TimestampMixin, uuid_pk


class Referral(Base, TimestampMixin):
    __tablename__ = "referrals"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    referred_to_role: Mapped[str | None] = mapped_column(String, nullable=True)
    trigger_score_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("clinical_scores.id"), nullable=True)
    status: Mapped[ReferralStatus] = mapped_column(Enum(ReferralStatus), default=ReferralStatus.pending)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class Report(Base, TimestampMixin):
    __tablename__ = "reports"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    generated_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    type: Mapped[ReportType] = mapped_column(Enum(ReportType), nullable=False)
    s3_key: Mapped[str | None] = mapped_column(String, nullable=True)
    date_range_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    date_range_end: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class PeerMatch(Base, TimestampMixin):
    __tablename__ = "peer_matches"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    matched_user_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    type: Mapped[PeerMatchType] = mapped_column(Enum(PeerMatchType), nullable=False)
    surgery_type: Mapped[SurgeryType | None] = mapped_column(Enum(SurgeryType), nullable=True)
    age_band: Mapped[str | None] = mapped_column(String, nullable=True)
    status: Mapped[PeerMatchStatus] = mapped_column(Enum(PeerMatchStatus), default=PeerMatchStatus.opted_in)
    is_moderated: Mapped[bool] = mapped_column(Boolean, default=True)
