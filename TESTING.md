# MioHeart — Run, Test & Setup Guide

## 1. Demo logins (password for all: `demo1234`)

Open the app → **"Try the demo"** card on the login screen → tap a stage. Or type the email + password.

| Email | Role | Where they are in the journey |
|---|---|---|
| `omar@example.com` | Patient | 🔍 Diagnosis (pre-surgery, 8%) |
| `ahmet@example.com` | Patient | 🩹 Inpatient recovery (Day 5, 60%) |
| `maria@example.com` | Patient | 🚶 Post-discharge rehab (78%) |
| `nurse@example.com` | Clinician | Care-team dashboard |

> Real signup accounts (e.g. `thisalthulnith2024@gmail.com`) keep working too — the demo seed never touches them.

---

## 2. Run everything locally

**Backend (FastAPI + Neon Postgres)** — from `backend/`:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Always use `--reload` so code changes apply. It's currently running this way (logs: `/tmp/miohart_backend.log`).

Seed/refresh demo data (idempotent — safe to re-run):
```bash
python -m app.seed_data       # 3 demo patients + clinician
python -m app.seed_content    # education hub + symptom/fasting/resource catalogs
```

**Patient app (Flutter) — iOS Simulator:**
```bash
cd frontend_flutter
flutter run -d "iPhone 17 Pro"      # or: flutter run  (pick the simulator)
```
The app auto-targets the backend: `localhost:8000` on iOS, `10.0.2.2:8000` on Android — no config needed.

**Clinician/Admin dashboard (React):**
```bash
cd clinician-dashboard
npm install && npm run dev          # opens on http://localhost:5173
```
Log in as `nurse@example.com / demo1234`. Admin features need an **admin** account (ask me to seed one, or set a user's role to `admin`).

---

## 3. Run on an Android emulator

Android SDK is **not installed on this machine**, so I couldn't run it here — but the app is Android-ready. To run it:

1. Install **Android Studio** → https://developer.android.com/studio
2. First launch installs the SDK. Then: **Tools → Device Manager → Create Device** (e.g. Pixel 7, API 34).
3. Verify: `flutter doctor` should show ✅ Android toolchain.
4. Start the emulator, then:
   ```bash
   cd frontend_flutter && flutter run
   ```
   (The app uses `10.0.2.2:8000` to reach your local backend from the Android emulator automatically.)

---

## 4. Google / Firebase login — the way to enable it

Right now login is **email + password** (works fully, self-hosted JWT + bcrypt). The "Continue with Google" button is a placeholder. To enable real Google sign-in:

1. **Create a Firebase project** → https://console.firebase.google.com → add an **iOS app** and an **Android app** with the bundle id `com.miohart.miohart`.
2. Download the config files and place them:
   - iOS: `frontend_flutter/ios/Runner/GoogleService-Info.plist`
   - Android: `frontend_flutter/android/app/google-services.json`
   *(both are gitignored — never commit them)*
3. In Firebase Console → **Authentication → Sign-in method → enable Google**.
4. Add packages: `flutter pub add firebase_core firebase_auth google_sign_in`, then `flutterfire configure`.
5. Wire the button: on Google sign-in success you get a Firebase ID token → send it to a new backend endpoint `POST /auth/firebase` that verifies it (Firebase Admin SDK) and maps/creates the user by `firebase_uid` (the `users.firebase_uid` column already exists). I can build this endpoint + button once you've added the Firebase project and the two config files.

**What I need from you for this:** the Firebase project created + the two config files (or just the project + I'll guide placement).

---

## 5. API keys you need to supply

| Key | Used for | Status |
|---|---|---|
| **Neon `DATABASE_URL`** | Postgres database | ✅ set in `backend/.env` (rotate the password — it was shared in chat) |
| **`ANTHROPIC_API_KEY`** | Mio food-AI (photo/describe a meal → nutrition) | ⚠️ **not set** — add to `backend/.env`; the Food AI returns 503 until then |
| **Firebase config files** | Google login | ⚠️ needed only if you want Google sign-in (section 4) |

`.env` lives at `backend/.env` (gitignored). Format:
```
DATABASE_URL=postgresql://...neon.tech/neondb?sslmode=require
SECRET_KEY=<random-long-string>
ANTHROPIC_API_KEY=sk-ant-...
```

---

## 6. What's working now (fixed this round)

- ✅ **Task list & journey no longer double** — deduped data, added DB unique indexes, made the auto-generators race-safe.
- ✅ **No more dummy heart-rate / glucose** — Home + More wearable cards read real synced data, or show "—" (glucose isn't a tracked metric, so it's gone).
- ✅ **Journey ring climbs as you tick tasks** ("0/5 tasks done today").
- ✅ **Daily plan auto-generates** per stage (was empty for real users).
- ✅ **Messages = real chat** — inline composer bar; send → your message appears instantly.
- ✅ **Education Hub + phase guides** have real, readable content (admin-editable).
- ✅ Demo login buttons + 3 demo patients across stages.

## 7. Still needs building / your input
- **Google login** (needs your Firebase project — section 4).
- **Food AI** (needs `ANTHROPIC_API_KEY` — section 5).
- **Quizzes & badges** — DB tables exist but no endpoints/UI yet (next build).
- **Push notifications** (hourly breathing reminders etc.) — needs APNs/FCM setup (a production concern).
- **Wearable live sync** (Apple Health / Fitbit) — schema + manual entry done; live OAuth sync not wired.
