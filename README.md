# Tabbr

Keep tabs. Split bills. Settle up.

A self-hostable expense sharing app — use the cloud or run your own instance.

## Features
- Add expenses (amount, payer, description, date)
- Auto-calculate who owes whom
- Clean minimal UI

## Stack
- **Frontend**: React + Vite
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL
- **Deploy**: Docker Compose

## Deploy

### Docker Compose (local)

```bash
cp .env.example .env
# edit .env to change default credentials
docker compose up --build -d
```

### Portainer (stack from Git repo)

The `stack.env` file in the repo provides default values for all environment variables. Portainer reads it automatically when deploying via Repository.

In Portainer → Stacks → Add stack → Repository:
1. Set the Git repo URL
2. Set the compose path to `docker-compose.yml`
3. Optionally override environment variables in the Portainer UI:
   - `POSTGRES_DB` (default: tabbr)
   - `POSTGRES_USER` (default: tabbr)
   - `POSTGRES_PASSWORD` (default: tabbr — change this!)
   - `PORT` (default: 3000)

## Development

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```