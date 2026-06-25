"""Shared column helpers and mixins for all models.

Portable types: UUID maps to native PostgreSQL UUID on Neon and CHAR(32) on SQLite;
JSONB maps to JSONB on PostgreSQL and JSON elsewhere.
"""
import uuid

from sqlalchemy import JSON, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.types import Uuid

# JSONB on PostgreSQL, plain JSON on other dialects.
JSONBType = JSON().with_variant(JSONB(), "postgresql")


def uuid_pk() -> Mapped[uuid.UUID]:
    """Primary key column: UUID, client-generated, avoids record enumeration."""
    return mapped_column(Uuid, primary_key=True, default=uuid.uuid4)


class TimestampMixin:
    created_at: Mapped["DateTime"] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped["DateTime"] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


class SoftDeleteMixin:
    deleted_at: Mapped["DateTime | None"] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
