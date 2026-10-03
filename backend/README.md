# Backend

Rails 8 (full stack, not `--api`, because the Avo admin needs views and assets). Session cookies, CSRF, and a nested chat API. Users sign in with email (or the short name `admin`) or a Google ID token.

## Setup

Requires Ruby 3.2+ and a C toolchain for the native gems. The `pg` gem needs libpq headers:

```bash
# macOS
brew install libpq
bundle config set --local build.pg --with-pg-config="$(brew --prefix libpq)/bin/pg_config"

# Debian/Ubuntu
sudo apt-get install -y libpq-dev
```

Then:

```bash
bundle install
```

`SECRET_KEY_BASE` is only required in production. In development and test Rails generates a local secret under `tmp/`.

### SQLite (no Docker)

```bash
export DB_ENGINE=sqlite
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 8000
```

### Postgres

Start the database from the repo root (`docker compose up db`), fill `DB_*` in `.env` if they differ from the Compose defaults, then:

```bash
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 8000
```

Admin UI: [http://127.0.0.1:8000/admin](http://127.0.0.1:8000/admin). Sign in at `/admin/login` with an account whose `admin` flag is set; the seed user qualifies.

## Seed user

`bin/rails db:seed` creates or resets:

| Login | Password |
| --- | --- |
| `admin` or `admin@example.com` | `password!123` |

Local development only.

## API

Base URL defaults to `http://localhost:8000`. JSON, cookie session, CSRF header `X-CSRF-Token` from `GET /api/auth/csrf`.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/auth/csrf` | No | Session cookie + `{ csrfToken }` |
| `POST` | `/api/auth/register` | No | `{ email, password, display_name? }` |
| `POST` | `/api/auth/login` | No | `{ email, password }` — `email` may be `admin` |
| `POST` | `/api/auth/google` | No | `{ credential }` Google GIS ID token |
| `DELETE` | `/api/auth/logout` | Yes | End session |
| `GET` | `/api/auth/me` | Yes | Current user |
| `GET`/`POST` | `/api/conversations` | Yes | List / create |
| `GET`/`PATCH`/`DELETE` | `/api/conversations/:id` | Yes | Read / rename / delete |
| `GET`/`POST` | `/api/conversations/:id/messages` | Yes | History / send `{ content }` |

`POST` on messages returns the user turn, a stub assistant reply, and the updated conversation (title is derived from the first message).

Errors are `{ "detail": "..." }` for single messages and `{ "field": ["..."] }` for per-attribute validation failures.

### CSRF and the session

Rails scopes the CSRF token to the session, so signing in or out invalidates the previous token. Every `/api` response therefore echoes the current token in the `X-CSRF-Token` header, and the UI updates its cached copy from it. Without that, the first write after login would fail.

## Database

Postgres by default; set `DB_ENGINE=sqlite` for a local run with no database service. Tests always use SQLite.

`db/schema.rb` is dumped from **Postgres**, which is why it carries `bigint` foreign keys and an `enable_extension` line. SQLite loads that dump fine. If you regenerate the schema from SQLite instead, the foreign keys come back as `integer` and no longer match `users.id` on Postgres — so run migrations against Postgres when the schema changes.

## Lint and tests

```bash
bundle exec rubocop
bundle exec rspec
```

Specs run against an on-disk SQLite database in `storage/` and need no `.env`.
