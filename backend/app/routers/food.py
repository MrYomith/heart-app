"""AI food logging (FR-044/FR-106 AI layer).

POST a meal photo and/or description; Claude parses the nutrition and the result
is logged to the patient's daily NutritionLog (protein + meal count), keeping the
existing nutrition tracking the single source of truth.
"""
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.core.auth import get_current_user
from app.database import get_db
from app.models import NutritionLog, User
from app.services.food_ai import FoodAIUnavailable, analyze_meal

router = APIRouter(prefix="/api/food", tags=["food-ai"])


@router.post("/analyze")
async def analyze(
    description: str | None = Form(default=None),
    file: UploadFile | None = File(default=None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    image_bytes = await file.read() if file else None
    media_type = file.content_type if file else None
    try:
        result = analyze_meal(description=description, image_bytes=image_bytes, media_type=media_type)
    except FoodAIUnavailable as e:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, str(e))
    except ValueError as e:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, str(e))
    except Exception:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, "Could not analyse the meal. Please try again.")

    # Log into today's nutrition row (FR-044/FR-106).
    today = date.today()
    row = db.query(NutritionLog).filter(NutritionLog.user_id == user.id, NutritionLog.log_date == today).first()
    if not row:
        row = NutritionLog(user_id=user.id, log_date=today, protein_grams=0, meals_count=0)
        db.add(row)
    row.protein_grams = (row.protein_grams or 0) + result["protein_g"]
    row.meals_count = (row.meals_count or 0) + 1
    db.commit()

    return {"analysis": result, "logged_date": today.isoformat()}
