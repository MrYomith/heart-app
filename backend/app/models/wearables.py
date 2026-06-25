"""Domain 7 — Wearables."""
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base
from app.enums import WearableMetric, WearableProvider, WearableStatus
from app.models.base import JSONBType, TimestampMixin, uuid_pk


class WearableConnection(Base, TimestampMixin):
    __tablename__ = "wearable_connections"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    provider: Mapped[WearableProvider] = mapped_column(Enum(WearableProvider), nullable=False)
    status: Mapped[WearableStatus] = mapped_column(Enum(WearableStatus), default=WearableStatus.disconnected)
    oauth_tokens: Mapped[dict | None] = mapped_column(JSONBType, nullable=True)  # encrypted at app layer
    last_sync_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class WearableReading(Base):
    __tablename__ = "wearable_readings"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    metric: Mapped[WearableMetric] = mapped_column(Enum(WearableMetric), nullable=False)
    value: Mapped[float] = mapped_column(Float, nullable=False)
    unit: Mapped[str | None] = mapped_column(String, nullable=True)
    source: Mapped[str | None] = mapped_column(String, nullable=True)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
