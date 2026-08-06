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

## Choose your path

### ☁️ Tabbr Cloud (hosted)

The easiest way to get started. No server to manage, no setup required.

1. Download the Tabbr app
2. Select "Tabbr Cloud" on first launch
3. You're ready to split bills

**Pricing:** Free during beta. Tabbr Pro at €4.99/month for advanced features (coming soon).

### 🏠 Self-Hosted (free, open source)

Run Tabbr on your own server. Full control, no limits, no fees.

#### Quick start (no clone needed)

Create a `docker-compose.yml` on your server:

```yaml
services:
  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: tabbr
      POSTGRES_USER: tabbr
      POSTGRES_PASSWORD: CHANGE_ME_TO_SOMETHING_SECURE
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
      DATABASE_URL: postgresql+asyncpg://tabbr:CHANGE_ME_TO_SOMETHING_SECURE@db:5432/tabbr

volumes:
  pgdata:
```

Then:

```bash
docker compose up -d
```

- API on http://localhost:8000
- API docs on http://localhost:8000/docs

#### From this repo (with build)

```bash
git clone https://github.com/WyliGr/tabbr.git
cd tabbr
cp .env.example .env
# Edit .env: change POSTGRES_PASSWORD to something secure
docker compose up -d
```

#### Portainer (Proxmox / Docker stacks)

1. Go to **Stacks → Add stack**
2. Paste the compose YAML above
3. Set `POSTGRES_PASSWORD` to something secure
4. Deploy the stack
5. The backend image is pulled automatically from GHCR

#### Local dev (no Docker)

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# Uses SQLite fallback if no DATABASE_URL set
```

#### Connecting the mobile app

1. Launch the Tabbr app
2. Select "Self-Hosted"
3. Enter your server URL (e.g. `http://192.168.1.X:8000`)
4. Tap "Test connection" to verify
5. Tap "Save and continue"

#### Replacing the pre-built image

To build the backend image yourself:

```bash
cd backend
docker build -t tabbr-backend .
# Replace ghcr.io/wyligr/tabbr-backend:latest with tabbr-backend in your compose
```

#### Updating

```bash
docker compose pull
docker compose up -d
```

#### Requirements

- Docker 20+ and Docker Compose v2
- ~256MB RAM minimum
- No GPU needed
- PostgreSQL 16 (included in compose)

## Mobile app

Flutter, Nothing OS dark theme, custom accent color picker.

```bash
cd mobile
flutter pub get
flutter run          # debug on device
flutter build apk    # release APK
```

Download latest APK: https://github.com/WyliGr/tabbr/releases

## License

MIT — see [LICENSE](LICENSE)

## Contributing

PRs welcome. Fork, branch, submit.