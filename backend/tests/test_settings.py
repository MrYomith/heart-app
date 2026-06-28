"""Patient settings: notification prefs, locale, GDPR export/deletion."""


def test_notification_prefs_defaults_then_update(client, registered_user):
    h = registered_user["headers"]
    # Defaults are created on first read.
    r = client.get("/api/settings/notifications", headers=h)
    assert r.status_code == 200
    assert r.json()["muted_categories"] == []
    assert "critical" in r.json()["unmutable_categories"]

    # Update — but critical/alert can never be muted (silently dropped).
    r = client.put("/api/settings/notifications", headers=h, json={
        "muted_categories": ["motivation", "social", "critical"],
        "quiet_hours_start": "21:30", "quiet_hours_end": "06:30",
    })
    assert r.status_code == 200
    body = r.json()
    assert "critical" not in body["muted_categories"]
    assert set(body["muted_categories"]) == {"motivation", "social"}
    assert body["quiet_hours_start"] == "21:30"


def test_notification_prefs_reject_unknown_category(client, registered_user):
    r = client.put("/api/settings/notifications", headers=registered_user["headers"], json={
        "muted_categories": ["not_a_category"],
    })
    assert r.status_code == 400


def test_set_locale(client, registered_user):
    r = client.patch("/api/settings/locale", headers=registered_user["headers"], json={"locale": "en"})
    assert r.status_code == 200 and r.json()["locale"] == "en"
    r = client.patch("/api/settings/locale", headers=registered_user["headers"], json={"locale": "fr"})
    assert r.status_code == 400


def test_data_export_returns_profile_and_logs_request(client, registered_user):
    h = registered_user["headers"]
    r = client.post("/api/settings/data-export", headers=h)
    assert r.status_code == 200
    body = r.json()
    assert body["profile"]["email"] == registered_user["email"]
    assert "vitals" in body and "consent_log" in body
    # The request is logged.
    reqs = client.get("/api/settings/data-requests", headers=h).json()
    assert any(x["type"] == "export" for x in reqs)


def test_data_deletion_requires_confirm_then_disables_login(client, registered_user):
    h = registered_user["headers"]
    assert client.post("/api/settings/data-deletion", headers=h, json={"confirm": False}).status_code == 400
    r = client.post("/api/settings/data-deletion", headers=h, json={"confirm": True})
    assert r.status_code == 200 and r.json()["status"] == "deleted"
    # Soft-deleted account can no longer log in.
    login = client.post("/auth/login", json={
        "email": registered_user["email"], "password": registered_user["password"],
    })
    assert login.status_code == 401


def test_settings_require_auth(client):
    assert client.get("/api/settings/notifications").status_code == 401
