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

## Quick Start (Docker)

```bash
cp .env.example .env
docker compose up --build
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000/docs

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