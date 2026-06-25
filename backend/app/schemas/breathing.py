"""Breathing / respiratory exercise logging (FR-063 prehab, FR-101 hourly coach)."""
from pydantic import BaseModel


class BreathingLog(BaseModel):
    session_type: str = "breathing"  # breathing | spirometry | cough
    count: int = 0  # breaths completed


class BreathingTodayOut(BaseModel):
    today_count: int
    target: int
