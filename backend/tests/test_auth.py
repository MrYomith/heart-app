"""Auth flow: registration policy, login, lockout, identity (FR-001/002, NFR-041)."""
from conftest import STRONG_PASSWORD
from app.core.config import MAX_FAILED_LOGINS


def test_register_success_returns_token(client):
    resp = client.post("/auth/register", json={
        "name": "Alice", "email": "alice@example.com",
        "password": STRONG_PASSWORD, "consent_accepted": True,
    })
    assert resp.status_code == 201
    body = resp.json()
    assert body["access_token"]
    assert body["user"]["email"] == "alice@example.com"


def test_register_requires_consent(client):
    resp = client.post("/auth/register", json={
        "name": "Bob", "email": "bob@example.com",
        "password": STRONG_PASSWORD, "consent_accepted": False,
    })
    assert resp.status_code == 400


def test_register_rejects_weak_password(client):
    resp = client.post("/auth/register", json={
        "name": "Carol", "email": "carol@example.com",
        "password": "weak", "consent_accepted": True,
    })
    assert resp.status_code == 400


def test_register_duplicate_email_rejected(client, registered_user):
    resp = client.post("/auth/register", json={
        "name": "Dup", "email": registered_user["email"],
        "password": STRONG_PASSWORD, "consent_accepted": True,
    })
    assert resp.status_code == 400


def test_login_success(client, registered_user):
    resp = client.post("/auth/login", json={
        "email": registered_user["email"], "password": registered_user["password"],
    })
    assert resp.status_code == 200
    assert resp.json()["access_token"]


def test_login_wrong_password_is_generic_401(client, registered_user):
    resp = client.post("/auth/login", json={
        "email": registered_user["email"], "password": "WrongPass123!@#",
    })
    assert resp.status_code == 401
    # No email enumeration: message must not reveal which field was wrong.
    assert "email or password" in resp.json()["detail"].lower()


def test_login_unknown_email_same_401(client):
    resp = client.post("/auth/login", json={
        "email": "nobody@example.com", "password": "WhateverPass1!",
    })
    assert resp.status_code == 401


def test_account_locks_after_max_failed_logins(client, registered_user):
    for _ in range(MAX_FAILED_LOGINS):
        client.post("/auth/login", json={
            "email": registered_user["email"], "password": "WrongPass123!@#",
        })
    # Even the correct password is now refused with 429 (locked).
    resp = client.post("/auth/login", json={
        "email": registered_user["email"], "password": registered_user["password"],
    })
    assert resp.status_code == 429


def test_me_requires_auth(client):
    assert client.get("/auth/me").status_code == 401


def test_me_returns_current_user(client, registered_user):
    resp = client.get("/auth/me", headers=registered_user["headers"])
    assert resp.status_code == 200
    assert resp.json()["email"] == registered_user["email"]
