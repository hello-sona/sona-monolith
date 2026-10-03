# E2E Tests

Capybara, driven by RSpec, against the running UI and API.

The suite lives in this package so it stays independent of `frontend/` (Vitest) and `backend/` (RSpec request specs). It uses [Cuprite](https://github.com/rubycdp/cuprite), which talks to Chrome over the DevTools Protocol, so there is no chromedriver to install.

## Setup

Requires Ruby 3.2+, Chrome, and Node (to start the frontend if it is not already up). From this directory:

```bash
bundle install
```

## Run

```bash
bundle exec rspec
```

If nothing is listening on ports 8000 and 5173, a suite hook runs `bin/rails db:prepare` and starts Rails (SQLite) and Vite, then stops them afterward. Server output goes to `log/backend.log` and `log/frontend.log`.

Because this package has its own `Gemfile`, the hook clears the bundler variables `bundle exec` set before spawning Rails. Otherwise Rails would boot against this suite's bundle and fail to find its gems.

To point at servers you already started:

```bash
E2E_FRONTEND_URL=http://127.0.0.1:5173 E2E_BACKEND_URL=http://127.0.0.1:8000 bundle exec rspec
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `E2E_FRONTEND_URL` | `http://127.0.0.1:5173` | UI origin |
| `E2E_BACKEND_URL` | `http://127.0.0.1:8000` | API origin |

In GitHub Actions those URLs come from repository secrets.

## Lint

```bash
bundle exec rubocop
```

## What it covers

- Login page heading and Sign in button, in a real browser
- `GET /api/auth/csrf` returns a CSRF token and sets the session cookie
