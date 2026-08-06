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

### Quick start (no clone needed)

Create a `docker-compose.yml` on your server with:

```yaml
services:
  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: tabbr
      POSTGRES_USER: tabbr
      POSTGRES_PASSWORD: CHANGE_ME
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U tabbr"]
      interval: 5s
      timeout: 3s
      retries: 5

  backend:
    image: ghcr.io/wyligr/tabbr-backend:latest
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql+asyncpg://tabbr:CHANGE_ME@db:5432/tabbr

volumes:
  pgdata:
```

Then:

```bash
docker compose up -d
```

API on http://localhost:8000
Docs on http://localhost:8000/docs

### From this repo (with build)

```bash
git clone https://github.com/WyliGr/tabbr.git
cd tabbr
# edit docker-compose.yml: change POSTGRES_PASSWORD
docker compose up -d
```

### Portainer

Paste the compose above into a new stack. Set `POSTGRES_PASSWORD` to something secure. The backend image is pulled automatically from GHCR.

### Local dev

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# uses SQLite fallback if no DATABASE_URL set
```

## Mobile app

Flutter, Nothing OS dark theme, custom accent color picker.

```bash
cd mobile
flutter pub get
flutter run          # debug on device
flutter build apk    # release APK
```

Download latest APK: https://github.com/WyliGr/tabbr/releases

On first launch, enter your server URL (e.g. http://192.168.1.X:8000).