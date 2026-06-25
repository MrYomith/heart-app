"""Hospital enrollment — links a self-registered patient to a hospital care team.

Two paths (both real-world): patient enters a clinic CODE (auto-approved), or
patient picks a hospital and the hospital APPROVES from the dashboard.
"""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import EnrollmentInitiatedBy, EnrollmentStatus
from app.models.base import TimestampMixin, uuid_pk


class EnrollmentCode(Base, TimestampMixin):
    """A join/activation code a hospital hands to its patients (DiGA-style)."""
    __tablename__ = "enrollment_codes"

    id: Mapped[uuid.UUID] = uuid_pk()
    hospital_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("hospitals.id"), index=True, nullable=False)
    code: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    label: Mapped[str | None] = mapped_column(String, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    max_uses: Mapped[int | None] = mapped_column(Integer, nullable=True)
    used_count: Mapped[int] = mapped_column(Integer, default=0)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class HospitalEnrollment(Base, TimestampMixin):
    __tablename__ = "hospital_enrollments"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    hospital_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("hospitals.id"), index=True, nullable=False)
    status: Mapped[EnrollmentStatus] = mapped_column(Enum(EnrollmentStatus), default=EnrollmentStatus.pending)
    initiated_by: Mapped[EnrollmentInitiatedBy] = mapped_column(Enum(EnrollmentInitiatedBy), nullable=False)
    code_used: Mapped[str | None] = mapped_column(String, nullable=True)
    requested_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    approved_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    rejected_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
