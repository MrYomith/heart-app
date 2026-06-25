from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, onboarding, enrollment, users, tasks, journey, medications, messages, appointments, progress, vitals, breathing
from app.routers import recovery, stage, wound, clinician, clinical_intake, wellbeing, clinician_manage, admin, education, wearables, food, content

# Schema is managed by Alembic migrations (run `alembic upgrade head`), not create_all.

app = FastAPI(
    title="MioHart API",
    description="Backend API for the MioHart heart surgery companion app",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8080",  # Flutter web dev
        "http://localhost:5173",  # Vite clinician dashboard
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(onboarding.router)
app.include_router(enrollment.router)
app.include_router(users.router)
app.include_router(tasks.router)
app.include_router(journey.router)
app.include_router(medications.router)
app.include_router(messages.router)
app.include_router(appointments.router)
app.include_router(progress.router)
app.include_router(vitals.router)
app.include_router(breathing.router)
app.include_router(recovery.delirium_router)
app.include_router(recovery.nutrition_router)
app.include_router(stage.eras_router)
app.include_router(stage.mobilisation_router)
app.include_router(wound.router)
app.include_router(clinician.router)
app.include_router(clinical_intake.router)
app.include_router(wellbeing.router)
app.include_router(clinician_manage.router)
app.include_router(admin.router)
app.include_router(education.router)
app.include_router(wearables.router)
app.include_router(food.router)
app.include_router(content.router)


@app.get("/")
def root():
    return {"message": "MioHart API is running", "version": "1.0.0", "docs": "/docs"}


@app.get("/api/health")
def health():
    return {"status": "ok"}
