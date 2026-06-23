from sqlalchemy import Column, Integer, String, Date, Float
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True)
    surgery_date = Column(String, nullable=True)
    current_phase = Column(String, default="diagnosis")
    journey_progress = Column(Float, default=0.0)
    hospital = Column(String, nullable=True)
    surgeon = Column(String, nullable=True)
    diagnosis = Column(String, nullable=True)
