#!/usr/bin/env bash
# Redeploy the MioHart backend to its current state on this (EC2) host.
# Run this ON the EC2 box, from inside the repo:  bash backend/redeploy_ec2.sh
#
# It pulls latest code, installs deps, migrates the DB, seeds education content,
# and restarts the service. It auto-detects how the app is run (systemd / Docker
# / gunicorn) and falls back to a plain nohup gunicorn if none is found.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
echo "==> Repo: $REPO_ROOT"

echo "==> Pulling latest code"
git fetch origin
git checkout main
git pull --ff-only origin main

cd "$REPO_ROOT/backend"

echo "==> Python deps"
if [ -d ".venv" ]; then source .venv/bin/activate; elif [ -d "venv" ]; then source venv/bin/activate; fi
pip install -r requirements.txt

echo "==> DB migrate + seed"
alembic upgrade head
python -m app.seed_content || echo "(seed_content skipped/failed — continuing)"

echo "==> Restarting the API"
if systemctl list-units --type=service 2>/dev/null | grep -qiE 'mioh(eart|art)|fastapi|uvicorn|gunicorn'; then
  SVC=$(systemctl list-units --type=service 2>/dev/null | grep -oiE '[a-z0-9_-]*(mioh(eart|art)|fastapi|uvicorn|gunicorn)[a-z0-9_-]*\.service' | head -1)
  echo "    systemd service: $SVC"
  sudo systemctl restart "$SVC"
  sudo systemctl --no-pager status "$SVC" | head -5
elif [ -f docker-compose.yml ] && command -v docker >/dev/null; then
  echo "    docker compose"
  docker compose up -d --build
else
  echo "    no service manager found — starting gunicorn via nohup on :8000"
  pkill -f "gunicorn main:app" 2>/dev/null || true
  sleep 1
  nohup gunicorn main:app -k uvicorn.workers.UvicornWorker -w 4 -b 0.0.0.0:8000 \
    > "$REPO_ROOT/backend/gunicorn.log" 2>&1 &
  sleep 3
fi

echo "==> Health check"
sleep 2
curl -fsS http://localhost:8000/api/health && echo "  ✓ backend healthy" || echo "  ✗ health check failed — see logs"
echo "==> Done. New routes should now return 401 (not 404):"
curl -s -o /dev/null -w "   /api/settings/data-requests -> %{http_code}\n" http://localhost:8000/api/settings/data-requests
