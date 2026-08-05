# Tabbr

Keep tabs. Split bills. Settle up.

A self-hostable expense sharing app. Backend API + mobile app.

## Structure

```
tabbr/
  backend/          FastAPI + SQLAlchemy async (API server)
  mobile/           Flutter app (Android)
  docker-compose.yml
```

## Backend

FastAPI + PostgreSQL. Room-based expense sharing with 5-letter codes.

### Run with Docker

```bash
cp .env.example .env
# change POSTGRES_PASSWORD
docker compose up --build -d
```

API on http://localhost:8000
Docs on http://localhost:8000/docs

### Portainer

Deploy from Git repo using `docker-compose.yml` and `stack.env` for env vars.

### Local dev

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# uses SQLite fallback if no DATABASE_URL set
```

## Mobile app

Flutter 3.44.8, Material 3 dark theme.

```bash
cd mobile
flutter pub get
flutter run          # debug on device
flutter build apk    # release APK
```

Download latest APK: https://github.com/WyliGr/tabbr/releases

On first launch, enter your server URL (e.g. http://192.168.1.X:8000).