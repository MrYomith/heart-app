"""Health check + security-header middleware."""


def test_health_ok(client):
    resp = client.get("/api/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_security_headers_present(client):
    resp = client.get("/api/health")
    assert resp.headers["X-Content-Type-Options"] == "nosniff"
    assert resp.headers["X-Frame-Options"] == "DENY"
    assert resp.headers["Referrer-Policy"] == "no-referrer"
    assert "Permissions-Policy" in resp.headers


def test_root_reports_running(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert "MioHart" in resp.json()["message"]
