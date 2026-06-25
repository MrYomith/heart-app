"""App configuration loaded from environment (.env)."""
import os

from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "dev-insecure-change-me")
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "10080"))  # 7 days (dev)

# Login lockout policy (FR-002)
MAX_FAILED_LOGINS = 5
FAILED_LOGIN_WINDOW_MINUTES = 15
LOCKOUT_MINUTES = 30

# Current consent document version (NFR-041)
CONSENT_VERSION = "1.0"
