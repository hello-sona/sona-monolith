# Sona-monolith

Sona is a ChatGPT-style chat app: a Rails API with session cookies, and a Vite/React UI. Sign in with email or Google, then start conversations.

| Path | What it is |
| --- | --- |
| [`frontend/`](frontend/README.md) | React UI (Vite, MUI) |
| [`backend/`](backend/README.md) | Rails API + Avo admin |
| [`e2e/`](e2e/README.md) | End-to-end tests |

The frontend and backend are meant to deploy independently. Point the UI at the API with `VITE_API_URL`.

[End-to-end tests](e2e/README.md) open a real browser against the running UI and API so we catch wiring issues that unit tests miss (login page, CSRF, and similar smoke checks). That README covers the Capybara/RSpec setup, how to run the suite, and what it covers.

## Prerequisites

- Node.js 22+
- Ruby 3.2+
- libpq headers, for the `pg` gem (`brew install libpq` or `apt-get install libpq-dev`)
- Docker (optional, for Postgres)

## Quick start

### 1. Environment files

Do not commit real secrets. Copy the examples and fill in values locally:

```bash
cp .env.example .env
cp frontend/.env.example frontend/.env
```

`SECRET_KEY_BASE` is only needed in production; development and test generate a local secret. To produce one:

```bash
cd backend && bin/rails secret
```

| Variable | Where | Purpose |
| --- | --- | --- |
| `SECRET_KEY_BASE` | `.env` | Cookie, session, and CSRF signing. Required in production. |
| `ALLOWED_HOSTS` | `.env` | Comma-separated hosts (`*` is fine locally). |
| `CORS_ORIGINS` | `.env` | Browser origins allowed to send the session cookie. |
| `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` | `.env` | Postgres. Leave blank to use the local Compose defaults (`sona` / `localhost` / `5432`). |
| `DB_ENGINE` | shell | Set to `sqlite` to run without Postgres. |
| `GOOGLE_CLIENT_ID` | `.env` | Google Identity Services client ID (backend). |
| `VITE_API_URL` | `frontend/.env` | API origin. Defaults to `http://localhost:8000`. |
| `VITE_GOOGLE_CLIENT_ID` | `frontend/.env` | Same Google client ID as the backend. Must match `GOOGLE_CLIENT_ID`. |

Google sign-in is optional. If those client IDs are empty, the UI still offers email/password.

### 2. Run with Docker Compose (Postgres)

From the repo root:

```bash
docker compose up --build
```

- UI: [http://localhost:5173](http://localhost:5173)
- API: [http://localhost:8000](http://localhost:8000)

Apply migrations and seed a local user (in another terminal):

```bash
docker compose exec backend bin/rails db:prepare
docker compose exec backend bin/rails db:seed
```

### 3. Run without Docker (SQLite)

```bash
# API
cd backend
bundle install
export DB_ENGINE=sqlite
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 8000

# UI (second terminal)
cd frontend
npm install
npm run dev
```

The admin UI is at [http://localhost:8000/admin](http://localhost:8000/admin), behind a sign-in form at `/admin/login`. The seeded user is an admin.
