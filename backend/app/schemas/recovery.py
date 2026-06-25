"""Delirium screening (FR-103) + nutrition recovery (FR-106) schemas."""
from pydantic import BaseModel


class DeliriumSubmit(BaseModel):
    # One bool per orientation question: True = answered correctly / oriented.
    answers: list[bool] = []


class DeliriumResult(BaseModel):
    confusion_score: int   # number of confused/incorrect answers
    risk: bool             # delirium risk → nurse alerted
    message: str


class NutritionLogIn(BaseModel):
    protein_grams: int | None = None
    hydration_glasses: int | None = None
    meals_count: int | None = None
    bowel_movement: bool = False


class NutritionTodayOut(BaseModel):
    protein_grams: int
    hydration_glasses: int
    meals_count: int
    bowel_movement: bool
    protein_target: int
    hydration_target: int
