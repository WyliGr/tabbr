# Tricount Replica

Simple expense sharing webapp — a lightweight Tricount clone.

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
   - `POSTGRES_DB` (default: tricount)
   - `POSTGRES_USER` (default: tricount)
   - `POSTGRES_PASSWORD` (default: tricount — change this!)
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