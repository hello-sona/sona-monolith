# Frontend

Vite + React + MUI chat UI. It talks to the Django API with `fetch`, cookies, and CSRF.

## Setup

Requires Node.js 22+. From this directory:

```bash
cp .env.example .env
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173). The API must be running (see the [backend README](../backend/README.md)).

## Environment

| Variable | Purpose |
| --- | --- |
| `VITE_API_URL` | Backend origin. Defaults to `http://localhost:8000`. |
| `VITE_GOOGLE_CLIENT_ID` | Google Identity Services client ID. Must match `GOOGLE_CLIENT_ID` on the API. Leave empty to skip Google sign-in. |

Restart Vite after changing `.env`.

## Scripts

```bash
npm run dev          # local server, port 5173
npm run build        # production bundle
npm run preview      # serve the bundle
npm run lint         # Oxlint (app + tests)
npm test             # Vitest
npm run test:watch   # Vitest watch
```

## Routes

| Path | Screen |
| --- | --- |
| `/login` | Sign in |
| `/register` | Create an account |
| `/` | New chat |
| `/c/:conversationId` | Existing thread |

Unauthenticated visits to chat routes redirect to `/login`.
