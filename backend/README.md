# Backend

Django 6 + Django REST Framework. Session cookies, CSRF, and a nested chat API. Users sign in with email (or the short name `admin`) or a Google ID token.

## Setup

Requires Python 3.12+ and [uv](https://docs.astral.sh/uv/). From this directory, sync deps into a local virtualenv and activate it:

```bash
uv sync --group dev
source .venv/bin/activate
```

That creates `backend/.venv`. After activation, use `python`, `pytest`, and `ruff` as usual (no `uv run` prefix).

Set `DJANGO_SECRET_KEY` in the repo-root `.env` (see the [root README](../README.md)) or export it in your shell. The API will not start without it.

### SQLite (no Docker)

```bash
export DB_ENGINE=sqlite
python manage.py migrate
python manage.py seed_test_user
python manage.py runserver 8000
```

### Postgres

Start the database from the repo root (`docker compose up db`), fill `DB_*` in `.env` if they differ from the Compose defaults, then:

```bash
python manage.py migrate
python manage.py seed_test_user
python manage.py runserver 8000
```

Admin UI: [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/) (same seed user is staff/superuser).

## Seed user

`seed_test_user` creates or resets:

| Login | Password |
| --- | --- |
| `admin` or `admin@example.com` | `password!123` |

Local development only.

## API

Base URL defaults to `http://localhost:8000`. JSON, cookie session, CSRF header `X-CSRFToken` from `GET /api/auth/csrf/`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/auth/csrf/` | No | CSRF cookie + `{ csrfToken }` |
| `POST` | `/api/auth/register/` | No | `{ email, password, display_name? }` |
| `POST` | `/api/auth/login/` | No | `{ email, password }` — `email` may be `admin` |
| `POST` | `/api/auth/google/` | No | `{ credential }` Google GIS ID token |
| `POST` | `/api/auth/logout/` | Yes | End session |
| `GET` | `/api/auth/me/` | Yes | Current user |
| `GET`/`POST` | `/api/conversations/` | Yes | List / create |
| `GET`/`PATCH`/`DELETE` | `/api/conversations/:id/` | Yes | Read / rename / delete |
| `GET`/`POST` | `/api/conversations/:id/messages/` | Yes | History / send `{ content }` |

`POST` on messages returns the user turn, a stub assistant reply, and the updated conversation (title is derived from the first message).

## Lint and tests

With the venv active:

```bash
ruff check .
pytest
```

Tests use an in-memory SQLite database and do not need `DJANGO_SECRET_KEY` in `.env`.
