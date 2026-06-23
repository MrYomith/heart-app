from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from app.database import Base


class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    subtitle = Column(String, nullable=True)
    date = Column(String, nullable=False)
    time = Column(String, nullable=True)
    location = Column(String, nullable=True)
    appointment_type = Column(String, default="followup")
    is_confirmed = Column(Boolean, default=True)
