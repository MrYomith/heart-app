"""Shared pytest fixtures.

Tests run against an in-memory SQLite database (cross-dialect model types make this
possible) so the suite is fast and needs no Neon connection. get_db is overridden to
use the test session; the schema is created fresh per test for isolation.
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Import models so every table is registered on Base.metadata before create_all.
import app.models  # noqa: F401
from app.database import Base, get_db
from main import app


@pytest.fixture()
def db_session():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,  # one shared in-memory connection across the test
    )
    Base.metadata.create_all(bind=engine)
    TestingSession = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = TestingSession()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def client(db_session):
    def _override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = _override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


# A password that satisfies the strength policy (>=12 chars, upper/lower/digit/special).
STRONG_PASSWORD = "TestPass123!@#"


@pytest.fixture()
def registered_user(client):
    """Register a user and return (email, password, token, headers)."""
    email = "patient@example.com"
    resp = client.post(
        "/auth/register",
        json={
            "name": "Test Patient",
            "email": email,
            "password": STRONG_PASSWORD,
            "consent_accepted": True,
        },
    )
    assert resp.status_code == 201, resp.text
    token = resp.json()["access_token"]
    return {
        "email": email,
        "password": STRONG_PASSWORD,
        "token": token,
        "headers": {"Authorization": f"Bearer {token}"},
    }
