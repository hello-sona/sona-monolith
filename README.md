# Sona

Sona is a ChatGPT-style chat app: a Django API with session cookies, and a Vite/React UI. Sign in with email or Google, then start conversations.

| Path | What it is |
| --- | --- |
| [`frontend/`](frontend/README.md) | React UI (Vite, MUI) |
| [`backend/`](backend/README.md) | Django REST API |
| [`e2e/`](e2e/README.md) | End-to-end tests |

The frontend and backend are meant to deploy independently. Point the UI at the API with `VITE_API_URL`.

[End-to-end tests](e2e/README.md) open a real browser against the running UI and API so we catch wiring issues that unit tests miss (login page, CSRF, and similar smoke checks). That README covers the Playwright/pytest setup, how to run the suite, and what it covers.

## Prerequisites

- Node.js 22+
- Python 3.12+
- [uv](https://docs.astral.sh/uv/)
- Docker (optional, for Postgres)

## Quick start

### 1. Environment files

Do not commit real secrets. Copy the examples and fill in values locally:

```bash
cp .env.example .env
cp frontend/.env.example frontend/.env
```

Generate a Django signing key and put it in `.env` as `DJANGO_SECRET_KEY` (shell only is fine too):

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

| Variable | Where | Purpose |
| --- | --- | --- |
| `DJANGO_SECRET_KEY` | `.env` | Cookie, session, and CSRF signing. Required to run the API. |
| `DEBUG` | `.env` | Django debug flag (`true` locally). |
| `ALLOWED_HOSTS` | `.env` | Comma-separated hosts (`*` is fine locally). |
| `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` | `.env` | Postgres. Leave blank to use the local Compose defaults (`sona` / `localhost` / `5432`). |
| `GOOGLE_CLIENT_ID` | `.env` | Google Identity Services client ID (backend). |
| `VITE_API_URL` | `frontend/.env` | API origin. Defaults to `http://localhost:8000`. |
| `VITE_GOOGLE_CLIENT_ID` | `frontend/.env` | Same Google client ID as the backend. Must match `GOOGLE_CLIENT_ID`. |

Google sign-in is optional. If those client IDs are empty, the UI still offers email/password.

### 2. Run with Docker Compose (Postgres)

From the repo root, with `DJANGO_SECRET_KEY` set in `.env`:

```bash
docker compose up --build
```

- UI: [http://localhost:5173](http://localhost:5173)
- API: [http://localhost:8000](http://localhost:8000)

Apply migrations and seed a local user (in another terminal):

```bash
docker compose exec backend uv run python manage.py migrate
docker compose exec backend uv run python manage.py seed_test_user
```

### 3. Run without Docker (SQLite)

```bash
# API
cd backend
uv sync --group dev
source .venv/bin/activate
export DB_ENGINE=sqlite
python manage.py migrate
python manage.py seed_test_user
python manage.py runserver 8000

# UI (second terminal)
cd frontend
npm install
npm run dev
```

Sign in at [http://localhost:5173/login](http://localhost:5173/login) with:

- **admin** or **admin@example.com**
- **password!123**

That seed user is for local development only.

## Using the app

- `/login` and `/register` — email/password, or Google if client IDs are set
- `/` — new chat
- `/c/:conversationId` — an existing thread

Auth is a Django session cookie plus CSRF, not JWT. The assistant is a local stub until a model is wired up.
