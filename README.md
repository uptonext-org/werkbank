# UpToWork — werkbank

Monorepo for UpToWork: a FastAPI backend, a React web app, and an Expo
mobile app, sharing one API contract.

This is a foundation for further development — project initialization and
tooling only. No business features are implemented yet.

## Technology stack

| Area      | Stack                                                     |
| --------- | ---------------------------------------------------------- |
| Backend   | Python, FastAPI, Pydantic, SQLAlchemy 2.x, Alembic, PostgreSQL |
| Web       | React, Vite, TypeScript                                   |
| Mobile    | React Native, Expo (Expo Router), TypeScript              |
| Monorepo  | pnpm workspaces, Turborepo                                |
| Infra     | Docker, Docker Compose                                    |

## Repository structure

```
apps/
  api/        FastAPI backend (standard Python project, not a pnpm package)
  web/        React + Vite web app
  mobile/     React Native + Expo mobile app
packages/
  contract/   Shared OpenAPI contract (apps/api, apps/web, apps/mobile all consume it)
  core/       Framework-independent TypeScript domain logic shared by web/mobile
  db/         Placeholder for future shared database assets (see packages/db/README.md)
docs/
  adr/            Architecture Decision Records
  requirements/   Product/business requirements
  runbooks/       Operational how-tos
infra/
  docker/     Dockerfiles
  scripts/    Infra/dev scripts
docker-compose.yml   Local dev environment (PostgreSQL, API)
pnpm-workspace.yaml  pnpm workspace definition (web, mobile, contract, core)
turbo.json           Turborepo task pipeline
```

Each app/package has its own README with more detail.

## Prerequisites

- Node.js >= 20
- [pnpm](https://pnpm.io/) >= 9 (`npm install -g pnpm`, or `corepack enable` if available)
- Python >= 3.11
- Docker + Docker Compose (for PostgreSQL, and optionally for running the API in a container)

## Local setup

```bash
git clone <this repo>
cd werkbank
cp .env.example .env   # adjust values if needed

# JS/TS workspace (web, mobile, contract, core)
pnpm install

# Python backend
cd apps/api
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
cd ../..
```

## Docker

Everything (PostgreSQL, the API, and the web app) can run in Docker, or you
can run just PostgreSQL in Docker and the API/web app natively — both
workflows are supported.

```bash
docker compose up --build       # build images and start db + api + web
docker compose up -d db         # just PostgreSQL, run apps/api locally
docker compose up -d            # start everything, detached
docker compose down             # stop and remove containers
docker compose down -v          # also delete the postgres_data volume
docker compose logs -f          # tail logs for all services
docker compose logs -f api      # tail logs for one service
docker compose build            # rebuild images (after Dockerfile/dep changes)
docker compose up --build       # rebuild and restart in one step
```

This starts:

| Service | Container      | Host port                     | Notes                                  |
| ------- | -------------- | ------------------------------ | --------------------------------------- |
| `db`    | `werkbank-db`  | `127.0.0.1:${POSTGRES_PORT:-5432}` | PostgreSQL 16, data persisted in the `postgres_data` volume |
| `api`   | `werkbank-api` | `${API_PORT:-8000}`            | FastAPI via uvicorn, `infra/docker/api.Dockerfile` |
| `web`   | `werkbank-web` | `${WEB_PORT:-5173}`            | Built React app served by nginx, `infra/docker/web.Dockerfile` |

`api` waits for `db`'s healthcheck; `web` reverse-proxies `/api/*` requests
to `api` (see `infra/docker/nginx.web.conf`), so `web -> api -> db` all
talk to each other by Docker Compose service name, never `localhost`.
`db`'s port is bound to `127.0.0.1` only (host tooling like `psql` or a DB
GUI can still reach it; other machines on the network cannot) — `api` and
`web` are published on all interfaces so a physical mobile device on the
same network can reach the API (see "Mobile app" below).

Check it's up: `curl http://localhost:8000/health` and open
`http://localhost:5173`.

### Database migrations (Docker)

Run Alembic inside the running `api` container — it has the venv and
`alembic.ini`/`alembic/` needed to do so:

```bash
docker compose exec api alembic upgrade head
docker compose exec api alembic revision --autogenerate -m "describe change"
```

(No automatic/destructive migration commands run on container start —
apply migrations explicitly, as above.)

### Backend tests (Docker)

The runtime `api` image intentionally excludes dev dependencies and the
`tests/` directory to keep the production image small. To run the test
suite in a container instead of a local venv, target the Dockerfile's
`builder` stage (which has the full toolchain) with `tests/` mounted in:

```bash
docker build -f infra/docker/api.Dockerfile --target builder -t werkbank-api-builder .
docker run --rm -v "$(pwd)/apps/api/tests:/build/tests:ro" -w /build werkbank-api-builder \
  sh -c "pip install '.[dev]' -q && pytest -q"
```

Day-to-day, running tests from the local venv (see "Start the backend"
below) is simpler.

## Start PostgreSQL

```bash
docker compose up -d db
```

This starts PostgreSQL on `localhost:5432` with the credentials from `.env`
(`POSTGRES_USER`/`POSTGRES_PASSWORD`/`POSTGRES_DB`, defaulting to
`werkbank`/`werkbank`/`werkbank`).

## Start the backend

```bash
cd apps/api
source .venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

Check it's up: `curl http://localhost:8000/health`.

Apply database migrations (none exist yet, but the tooling is wired up):

```bash
alembic upgrade head
```

See [`apps/api/README.md`](apps/api/README.md) for tests, linting, and
migration commands.

## Start the web app

```bash
pnpm --filter web dev
```

Opens on `http://localhost:5173`.

## Start the mobile app

```bash
pnpm --filter mobile dev
```

Follow the Expo CLI's prompts to open in a simulator, a device via Expo Go,
or the web.

The mobile app has no Dockerfile and is not part of `docker-compose.yml` —
Expo/React Native isn't a server process to containerize, and it needs
access to a simulator/device that a container can't provide. It keeps
using its normal Expo dev workflow, and can talk to an API running either
natively or in Docker.

### Connecting the mobile app to the API

"`localhost`" means a different machine depending on where it's evaluated,
which trips people up with mobile + Docker:

- **From your host machine** (e.g. `curl` in a terminal, or a browser):
  `localhost:8000` reaches the API correctly, whether it's running
  natively or via `docker compose`, because its port is published to the
  host.
- **From inside another Docker container** (not applicable to mobile, but
  relevant to `web`/`api` themselves): `localhost` means that container
  itself, not the host or a sibling container — use the compose service
  name (`api`, `db`) instead, as `docker-compose.yml` does.
- **From a physical mobile device** (a phone running Expo Go, not a
  simulator on the same machine): `localhost` on the phone means the
  phone itself. It cannot reach `localhost:8000` on your development
  machine. Use your machine's LAN IP instead (e.g. `192.168.1.23:8000`,
  found via `ipconfig getifaddr en0` on macOS or `ipconfig` on Windows),
  and make sure the phone is on the same network. An iOS/Android
  **simulator/emulator** running on the same machine, by contrast, can
  usually reach `localhost:8000` directly (Android emulators are the
  exception — use `10.0.2.2:8000`).

No mobile networking code is wired up yet (the mobile app doesn't call the
API yet); this is just the configuration developers will need once it
does, e.g. via an Expo public env var such as `EXPO_PUBLIC_API_URL` set to
the appropriate value for the device being used.

## Development commands

Run from the repo root, across all JS/TS packages via Turborepo:

```bash
pnpm dev              # start web + mobile dev servers
pnpm build            # build all packages
pnpm lint             # lint all packages (and the OpenAPI contract)
pnpm typecheck        # typecheck all packages
pnpm test             # run all tests
pnpm format           # format the repo with Prettier
pnpm format:check     # check formatting without writing
pnpm contract:lint    # validate packages/contract/openapi.yaml
```

Scope a command to one package with `--filter`, e.g. `pnpm --filter web build`.

The Python backend is not part of the pnpm workspace — run its checks from
`apps/api` directly (see [`apps/api/README.md`](apps/api/README.md)):

```bash
cd apps/api && source .venv/bin/activate
pytest
ruff check .
ruff format .
mypy app
```
