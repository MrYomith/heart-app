"""Domain 8 — Content & Education."""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import ContentTopic, ContentType
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class AppContent(Base, TimestampMixin):
    """Admin-managed content & catalogs (symptoms, phase resources, emergency
    contacts, fasting steps, reminders, support links) — editable without an
    app release. hospital_id null = global; set = hospital-specific override."""
    __tablename__ = "app_content"

    id: Mapped[uuid.UUID] = uuid_pk()
    category: Mapped[str] = mapped_column(String, index=True, nullable=False)  # symptom | phase_resource | emergency_contact | fasting_step | surgery_reminder | support_resource
    item_key: Mapped[str | None] = mapped_column(String, nullable=True)        # stable key, e.g. 'fever'
    title: Mapped[str] = mapped_column(String, nullable=False)
    body: Mapped[str | None] = mapped_column(Text, nullable=True)
    emoji: Mapped[str | None] = mapped_column(String, nullable=True)
    severity: Mapped[str | None] = mapped_column(String, nullable=True)        # symptoms: critical | warning
    stage: Mapped[str | None] = mapped_column(String, index=True, nullable=True)   # phase_resource: diagnosis|preop|...
    section: Mapped[str | None] = mapped_column(String, nullable=True)         # grouping within a stage
    payload: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)     # extra (phone, url, route)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    hospital_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("hospitals.id"), nullable=True)
    locale: Mapped[str] = mapped_column(String, default="en", nullable=False)
    published: Mapped[bool] = mapped_column(Boolean, default=True)


class EducationContent(Base, TimestampMixin):
    __tablename__ = "education_content"

    id: Mapped[uuid.UUID] = uuid_pk()
    title: Mapped[str] = mapped_column(String, nullable=False)
    type: Mapped[ContentType] = mapped_column(Enum(ContentType), nullable=False)
    topic: Mapped[ContentTopic | None] = mapped_column(Enum(ContentTopic), nullable=True)
    stage: Mapped[str | None] = mapped_column(String, nullable=True)
    surgery_types: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)  # filter list
    s3_key: Mapped[str | None] = mapped_column(String, nullable=True)
    duration_sec: Mapped[int | None] = mapped_column(Integer, nullable=True)
    category: Mapped[str | None] = mapped_column(String, nullable=True)
    has_german_subtitles: Mapped[bool] = mapped_column(Boolean, default=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    published: Mapped[bool] = mapped_column(Boolean, default=True)


class ContentProgress(Base, TimestampMixin):
    __tablename__ = "content_progress"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    content_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("education_content.id"), index=True, nullable=False)
    resume_position_sec: Mapped[int] = mapped_column(Integer, default=0)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    favourited: Mapped[bool] = mapped_column(Boolean, default=False)
    last_viewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class Quiz(Base, TimestampMixin):
    __tablename__ = "quizzes"

    id: Mapped[uuid.UUID] = uuid_pk()
    topic: Mapped[str | None] = mapped_column(String, nullable=True)
    title: Mapped[str] = mapped_column(String, nullable=False)


class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    id: Mapped[uuid.UUID] = uuid_pk()
    quiz_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("quizzes.id"), index=True, nullable=False)
    question: Mapped[str] = mapped_column(Text, nullable=False)
    options: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    correct_index: Mapped[int | None] = mapped_column(Integer, nullable=True)
    explanation: Mapped[str | None] = mapped_column(Text, nullable=True)


class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    quiz_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("quizzes.id"), index=True, nullable=False)
    score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    answers: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)
    attempted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class Badge(Base):
    __tablename__ = "badges"

    id: Mapped[uuid.UUID] = uuid_pk()
    key: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str | None] = mapped_column(String, nullable=True)
    icon: Mapped[str | None] = mapped_column(String, nullable=True)


class UserBadge(Base):
    __tablename__ = "user_badges"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    badge_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("badges.id"), index=True, nullable=False)
    earned_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
