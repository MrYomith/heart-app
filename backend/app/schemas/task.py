from pydantic import BaseModel


class TaskOut(BaseModel):
    id: str
    title: str
    subtitle: str | None = None
    icon: str | None = None
    category: str | None = None
    scheduled_time: str | None = None
    time_color: str = "teal"
    phase: str | None = None
    task_date: str | None = None
    is_done: bool = False
    priority: int = 0

    @classmethod
    def from_row(cls, t) -> "TaskOut":
        return cls(
            id=str(t.id),
            title=t.title,
            subtitle=t.subtitle,
            icon=t.icon,
            category=t.category.value if t.category else None,
            scheduled_time=t.scheduled_time,
            time_color=t.time_color or "teal",
            phase=t.phase,
            task_date=t.task_date,
            is_done=t.is_done,
            priority=t.priority or 0,
        )


class TaskToggle(BaseModel):
    is_done: bool
