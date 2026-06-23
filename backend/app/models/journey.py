from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base


class JourneyPhase(Base):
    __tablename__ = "journey_phases"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    phase_key = Column(String, nullable=False)
    label = Column(String, nullable=False)
    emoji = Column(String, nullable=True)
    status = Column(String, default="upcoming")  # completed | active | upcoming
    date_label = Column(String, nullable=True)
    subtitle = Column(String, nullable=True)
    order = Column(Integer, default=0)
