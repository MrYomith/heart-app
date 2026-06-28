"""App configuration loaded from environment (.env)."""
import os

from dotenv import load_dotenv

load_dotenv()

# "development" | "production". Controls fail-fast guards and docs exposure.
ENVIRONMENT = os.getenv("ENVIRONMENT", "development").strip().lower()
IS_PRODUCTION = ENVIRONMENT == "production"

SECRET_KEY = os.getenv("SECRET_KEY", "dev-insecure-change-me")
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "10080"))  # 7 days (dev)

# CORS allow-list. In production set CORS_ORIGINS to a comma-separated list of the
# real web/dashboard origins; dev falls back to localhost.
_default_origins = "http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://localhost:5173,http://127.0.0.1:5173"
CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", _default_origins).split(",") if o.strip()]

# Fail fast in production if the secret was never set — never ship the dev default.
if IS_PRODUCTION and SECRET_KEY == "dev-insecure-change-me":
    raise RuntimeError(
        "SECRET_KEY must be set to a strong random value in production. "
        "Generate one: python -c \"import secrets; print(secrets.token_urlsafe(48))\""
    )

# Login lockout policy (FR-002)
MAX_FAILED_LOGINS = 5
FAILED_LOGIN_WINDOW_MINUTES = 15
LOCKOUT_MINUTES = 30

# Current consent document version (NFR-041)
CONSENT_VERSION = "1.0"
