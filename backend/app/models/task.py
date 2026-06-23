from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Date
from app.database import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    subtitle = Column(String, nullable=True)
    icon = Column(String, nullable=True)
    category = Column(String, nullable=True)
    scheduled_time = Column(String, nullable=True)
    time_color = Column(String, default="teal")
    phase = Column(String, nullable=True)
    task_date = Column(String, nullable=True)
    is_done = Column(Boolean, default=False)
    priority = Column(Integer, default=0)
