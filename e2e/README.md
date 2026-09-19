# E2E Tests

Playwright, driven by pytest, against the running UI and API.

The suite lives in this package so it stays independent of `frontend/` (Vitest) and `backend/` (pytest-django). It uses [pytest-playwright](https://playwright.dev/python/docs/test-runners) and Chromium.

## Setup

Requires Python 3.12+, [uv](https://docs.astral.sh/uv/), and Node (to start the frontend if it is not already up). From this directory:

```bash
uv sync --group dev
uv run playwright install chromium
```

## Run

```bash
uv run pytest
```

If nothing is listening on ports 8000 and 5173, a session fixture starts Django (SQLite) and Vite, then stops them afterward. It sets a throwaway `DJANGO_SECRET_KEY` for that process only.

To point at servers you already started:

```bash
E2E_FRONTEND_URL=http://127.0.0.1:5173 E2E_BACKEND_URL=http://127.0.0.1:8000 uv run pytest
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `E2E_FRONTEND_URL` | `http://127.0.0.1:5173` | UI origin |
| `E2E_BACKEND_URL` | `http://127.0.0.1:8000` | API origin |

In GitHub Actions those URLs come from repository secrets.

## Lint

```bash
uv run ruff check .
```

## What it covers

- Login page heading and Sign in button
- `GET /api/auth/csrf/` returns a CSRF token
