import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()

# Neon PostgreSQL in production/dev. Falls back to local SQLite only if DATABASE_URL
# is unset (UUID/JSONB/ENUM features need PostgreSQL, so set DATABASE_URL for real work).
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()

if DATABASE_URL:
    # Normalise the scheme SQLAlchemy expects for psycopg2.
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    engine = create_engine(DATABASE_URL, pool_pre_ping=True)
    IS_POSTGRES = True
else:
    engine = create_engine(
        "sqlite:///./miohart.db",
        connect_args={"check_same_thread": False},
    )
    IS_POSTGRES = False

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
