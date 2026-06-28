# MioHart — Production Deployment

This is the backend (FastAPI + Neon PostgreSQL). Host it in an **EU region** (close to
the Neon Frankfurt DB) for GDPR and for low DB round-trip latency.

## 1. Environment

Copy `.env.example` → `.env` and fill in real values. The variables that matter in
production:

| Var | Required | Notes |
|-----|----------|-------|
| `ENVIRONMENT` | yes | Set to `production`. Enables the SECRET_KEY guard, hides `/docs`, sends HSTS. |
| `DATABASE_URL` | yes | Neon **pooled** connection string, `?sslmode=require`, Frankfurt region. |
| `SECRET_KEY` | yes | `python -c "import secrets; print(secrets.token_urlsafe(48))"`. App refuses to start in production without it. |
| `CORS_ORIGINS` | yes | Comma-separated front-end origins, e.g. `https://app.mioheart.de,https://dashboard.mioheart.de`. |
| `WEB_CONCURRENCY` | no | Gunicorn workers (default 4). Rule of thumb: 2×CPU+1. |
| `ANTHROPIC_API_KEY` | for Food AI | Without it the Food AI feature degrades gracefully. |
| `STORAGE_BACKEND` | no | `local` (default) or `s3`. Use `s3` in production for wound photos / media. |
| `S3_BUCKET`, `S3_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | if S3 | EU bucket; objects are written with AES256 server-side encryption. |

## 2. Run with Docker

```bash
docker compose up --build -d
```

The container runs `alembic upgrade head` on start (applies migrations), then serves
via gunicorn + uvicorn workers on port 8000 with a `/api/health` healthcheck. It runs
as a non-root user.

Put a TLS-terminating reverse proxy (nginx / Caddy / cloud LB) in front; the app emits
HSTS but expects HTTPS to be terminated upstream.

## 3. Run without Docker

```bash
pip install -r requirements.txt
alembic upgrade head
gunicorn main:app -k uvicorn.workers.UvicornWorker -w 4 -b 0.0.0.0:8000
```

## 4. Tests

```bash
python -m pytest          # backend — runs on in-memory SQLite, no Neon needed
cd ../frontend_flutter && flutter test
```

## 5. What is built vs. what still needs your accounts/keys

**Done (in code):**
- Self-hosted JWT auth, bcrypt, login lockout (5 fails / 15 min → 30 min lock).
- Env-driven CORS, security headers, production SECRET_KEY guard, docs hidden in prod.
- Neon connection pooling tuned for remote latency.
- Swappable storage (local ⇄ S3) for wound photos and education media.
- Docker image (non-root, healthcheck, auto-migrate) + compose.
- Backend pytest suite + Flutter widget smoke test.

**Still needs external accounts / decisions (not code — your inputs):**
- [ ] **ANTHROPIC_API_KEY** — for the Food AI vision feature.
- [ ] **S3 bucket (EU region)** — set `STORAGE_BACKEND=s3` + AWS creds.
- [ ] **Firebase / FCM** — push notifications (device tokens already modelled).
- [ ] **EU hosting** — deploy near Neon Frankfurt.
- [ ] **German i18n** — UI copy translation pass (locale field exists; strings to be localised).
- [ ] **Security / penetration test** — before handling real patient data.
- [ ] **App Store / Play Store** accounts — for mobile release.
- [ ] **Regulatory** — clinical content sign-off and medical-device/GDPR review as applicable.
- [ ] **Rotate the Neon DB password** that was shared earlier in chat.

## Security notes
- `.env`, `secrets/`, `*-service-account.json`, `uploads/`, `*.db` are gitignored — never commit them.
- `audit_log` / `consent_log` are append-only (GDPR/NFR).
- Patient record IDs are UUIDs (no enumeration).
