"""Domain 1 — Identity & Access."""
import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.types import Uuid

from app.database import Base
from app.enums import (
    CarerLinkStatus,
    ClinicianRole,
    ConsentType,
    DataRequestStatus,
    DataRequestType,
    HospitalType,
    NyhaClass,
    PhaseKey,
    Platform,
    SurgeryType,
    UserRole,
)
from app.models.base import JSONBType, SoftDeleteMixin, TimestampMixin, uuid_pk


class User(Base, TimestampMixin, SoftDeleteMixin):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = uuid_pk()
    firebase_uid: Mapped[str | None] = mapped_column(String, unique=True, index=True, nullable=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    # Self-hosted login holds a bcrypt hash here; Firebase users leave it null (Firebase owns the credential).
    password_hash: Mapped[str | None] = mapped_column(String, nullable=True)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.patient, nullable=False)
    date_of_birth: Mapped[date | None] = mapped_column(Date, nullable=True)
    profile_photo_url: Mapped[str | None] = mapped_column(String, nullable=True)
    locale: Mapped[str] = mapped_column(String, default="de", nullable=False)
    onboarding_complete: Mapped[bool] = mapped_column(Boolean, default=False)
    biometric_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    totp_secret: Mapped[str | None] = mapped_column(String, nullable=True)  # clinician 2FA
    clinician_specialty: Mapped[ClinicianRole | None] = mapped_column(Enum(ClinicianRole), nullable=True)  # set for clinician accounts
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    failed_login_count: Mapped[int] = mapped_column(Integer, default=0)
    locked_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Patient clinical profile
    surgery_type: Mapped[SurgeryType | None] = mapped_column(Enum(SurgeryType), nullable=True)
    surgery_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    discharge_date: Mapped[date | None] = mapped_column(Date, nullable=True)  # drives Stage 5/6 transitions
    stage_paused: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)  # clinician pause (FR-035)
    hospital_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("hospitals.id"), nullable=True)
    surgeon_name: Mapped[str | None] = mapped_column(String, nullable=True)
    nyha_class: Mapped[NyhaClass | None] = mapped_column(Enum(NyhaClass), nullable=True)
    diagnosis: Mapped[str | None] = mapped_column(String, nullable=True)
    current_phase: Mapped[PhaseKey] = mapped_column(Enum(PhaseKey), default=PhaseKey.diagnosis)
    journey_progress: Mapped[float] = mapped_column(Float, default=0.0)

    hospital: Mapped["Hospital | None"] = relationship("Hospital", lazy="selectin", foreign_keys=[hospital_id])


class Hospital(Base, TimestampMixin):
    __tablename__ = "hospitals"

    id: Mapped[uuid.UUID] = uuid_pk()
    name: Mapped[str] = mapped_column(String, nullable=False)
    address: Mapped[str | None] = mapped_column(String, nullable=True)
    city: Mapped[str | None] = mapped_column(String, nullable=True)
    postcode: Mapped[str | None] = mapped_column(String, nullable=True)
    phone: Mapped[str | None] = mapped_column(String, nullable=True)
    type: Mapped[HospitalType] = mapped_column(Enum(HospitalType), default=HospitalType.hospital)
    surgeon_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    maps_url: Mapped[str | None] = mapped_column(String, nullable=True)


class Device(Base, TimestampMixin):
    __tablename__ = "devices"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    fcm_token: Mapped[str | None] = mapped_column(String, nullable=True)
    platform: Mapped[Platform | None] = mapped_column(Enum(Platform), nullable=True)
    biometric_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ConsentLog(Base):
    __tablename__ = "consent_log"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    consent_type: Mapped[ConsentType] = mapped_column(Enum(ConsentType), nullable=False)
    consent_version: Mapped[str] = mapped_column(String, nullable=False)
    text_shown: Mapped[str | None] = mapped_column(Text, nullable=True)
    accepted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    withdrawn_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    ip_hash: Mapped[str | None] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class AuditLog(Base):
    __tablename__ = "audit_log"

    id: Mapped[uuid.UUID] = uuid_pk()
    actor_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), index=True, nullable=True)
    actor_role: Mapped[str | None] = mapped_column(String, nullable=True)
    action: Mapped[str] = mapped_column(String, nullable=False)
    entity_type: Mapped[str | None] = mapped_column(String, nullable=True)
    entity_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, nullable=True)
    patient_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), index=True, nullable=True)
    audit_metadata: Mapped[dict | None] = mapped_column("metadata", JSONBType, nullable=True)
    ip_hash: Mapped[str | None] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class CarerLink(Base, TimestampMixin):
    __tablename__ = "carer_links"

    id: Mapped[uuid.UUID] = uuid_pk()
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    carer_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), index=True, nullable=True)
    invite_email: Mapped[str | None] = mapped_column(String, nullable=True)
    invite_token: Mapped[str | None] = mapped_column(String, index=True, nullable=True)
    invite_expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[CarerLinkStatus] = mapped_column(Enum(CarerLinkStatus), default=CarerLinkStatus.pending)
    permissions: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    linked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ClinicianAssignment(Base, TimestampMixin):
    __tablename__ = "clinician_assignments"

    id: Mapped[uuid.UUID] = uuid_pk()
    clinician_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    patient_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    clinician_role: Mapped[ClinicianRole] = mapped_column(Enum(ClinicianRole), nullable=False)
    hospital_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("hospitals.id"), nullable=True)
    assigned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True)


class NotificationPreference(Base, TimestampMixin):
    __tablename__ = "notification_preferences"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    muted_categories: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    quiet_hours_start: Mapped[str] = mapped_column(String, default="22:00")
    quiet_hours_end: Mapped[str] = mapped_column(String, default="07:00")


class DataRequest(Base, TimestampMixin):
    __tablename__ = "data_requests"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    type: Mapped[DataRequestType] = mapped_column(Enum(DataRequestType), nullable=False)
    status: Mapped[DataRequestStatus] = mapped_column(Enum(DataRequestStatus), default=DataRequestStatus.requested)
    requested_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    export_s3_key: Mapped[str | None] = mapped_column(String, nullable=True)
