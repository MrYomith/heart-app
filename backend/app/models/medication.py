from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from app.database import Base


class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)
    dose = Column(String, nullable=True)
    schedule = Column(String, nullable=True)
    times = Column(String, nullable=True)  # comma-separated e.g. "08:00,20:00"
    is_active = Column(Boolean, default=True)
    notes = Column(String, nullable=True)
