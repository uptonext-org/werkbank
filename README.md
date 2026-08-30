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

## Start PostgreSQL

```bash
docker compose up -d db
```

This starts PostgreSQL on `localhost:5432` with the credentials from `.env`
(`POSTGRES_USER`/`POSTGRES_PASSWORD`/`POSTGRES_DB`, defaulting to
`werkbank`/`werkbank`/`werkbank`).

Alternatively, `docker compose up --build` also builds and runs the API
itself as a container (`infra/docker/api.Dockerfile`).

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
