from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routers import users, tasks, journey, medications, messages, appointments, progress

# Create all tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MioHart API",
    description="Backend API for the MioHart heart surgery companion app",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(tasks.router)
app.include_router(journey.router)
app.include_router(medications.router)
app.include_router(messages.router)
app.include_router(appointments.router)
app.include_router(progress.router)


@app.get("/")
def root():
    return {"message": "MioHart API is running", "version": "1.0.0", "docs": "/docs"}


@app.get("/api/health")
def health():
    return {"status": "ok"}
