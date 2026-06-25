# MioHeart — Deploy & Test Guide

## Live backend (DONE)
- **URL:** http://ec2-3-86-212-253.compute-1.amazonaws.com/
- Runs via `systemd` service `miohart` (auto-restarts, survives reboot), behind nginx on port 80.
- DB: Neon Postgres (shared with local dev). Python 3.12 venv via `uv`.

### Manage the backend (SSH)
```bash
chmod 600 ~/Downloads/mioheart.pem
ssh -i ~/Downloads/mioheart.pem ubuntu@ec2-3-86-212-253.compute-1.amazonaws.com
sudo systemctl status miohart        # check
sudo journalctl -u miohart -n 50     # logs
sudo systemctl restart miohart       # restart
```

### Redeploy backend after code changes (from your Mac)
```bash
cd /Users/thisalthulnith/mioheart/heart-app
rsync -az --delete --exclude '__pycache__' --exclude '.venv' --exclude '*.pyc' \
  --exclude 'miohart.db' --exclude '.git' \
  -e "ssh -i ~/Downloads/mioheart.pem" \
  backend/ ubuntu@ec2-3-86-212-253.compute-1.amazonaws.com:~/miohart-backend/
ssh -i ~/Downloads/mioheart.pem ubuntu@ec2-3-86-212-253.compute-1.amazonaws.com \
  'cd ~/miohart-backend && ~/.local/bin/uv pip install -r requirements.txt && sudo systemctl restart miohart'
```

## Clinician/Admin dashboard → Netlify
The dashboard is built (`clinician-dashboard/dist`) and configured (`netlify.toml`) to proxy
`/api` and `/auth` to the EC2 backend, so the HTTPS site reaches the HTTP backend with no
mixed-content errors. It's mobile-responsive (sidebar collapses to a top bar on phones).

### Deploy (run these — Netlify login opens YOUR browser)
```bash
cd /Users/thisalthulnith/mioheart/heart-app/clinician-dashboard
netlify login          # log in as thisalthulnith2024@gmail.com
netlify deploy --prod --dir=dist
# When prompted: "Create & configure a new site" → pick your team → name it (e.g. miohart-clinical)
```
Netlify prints the live URL (e.g. https://miohart-clinical.netlify.app).

## Demo logins (password: `demo1234`)
| Email | Role | Where |
|---|---|---|
| omar@example.com | Patient — Diagnosis stage | App (or Demo Login button) |
| ahmet@example.com | Patient — Inpatient | App |
| maria@example.com | Patient — Rehab | App |
| admin@example.com | **Admin** (content management) | Dashboard |
| nurse@example.com | Clinician | Dashboard |

Admin → **⚙️ Admin tab** → **Education content** / **App content catalog**: create / edit /
publish / delete. Changes appear in the patient app immediately (same DB).

## Patient app (Flutter) against the live backend
The app defaults to `http://localhost:8000`. To test a device/simulator against EC2, edit
`frontend_flutter/lib/services/api_client.dart` `_resolveBaseUrl()` to return
`http://ec2-3-86-212-253.compute-1.amazonaws.com`.

## Google / Firebase login (the "way")
Self-hosted email+password login already works. To add Google sign-in:
1. Firebase console → create project → add iOS & Android apps (bundle/package id from the Flutter project).
2. Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android) into the
   Flutter platform folders. Enable **Google** under Authentication → Sign-in methods.
3. Add `firebase_core` + `google_sign_in` to `pubspec.yaml`; wire the "Continue with Google"
   button to sign in, get the Firebase ID token, and POST it to a backend
   `/auth/firebase` endpoint that verifies it with `firebase-admin` (already in requirements)
   and links/creates the user via `users.firebase_uid`.
4. Backend needs the Firebase service-account JSON (set `GOOGLE_APPLICATION_CREDENTIALS`).

## API keys
- **ANTHROPIC_API_KEY** — set in `backend/.env` (and on EC2 `~/miohart-backend/.env`) to enable
  the Food-AI nutrition feature. Without it that endpoint returns 503; everything else works.
- Rotate the Neon DB password that was shared in chat.
