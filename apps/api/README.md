# apps/api

FastAPI backend. A standard Python project — intentionally **not** part of
the pnpm workspace.

## Setup

```bash
cd apps/api
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

Copy the repo-root `.env.example` to `.env` (at the repo root, or into this
directory — `pydantic-settings` reads `apps/api/.env` when running from
this directory) and adjust as needed.

## Run

```bash
uvicorn app.main:app --reload --port 8000
```

Then check `curl http://localhost:8000/health`.

## Test / lint / typecheck

```bash
pytest
ruff check .
ruff format .
mypy app
```

## Migrations

```bash
alembic revision --autogenerate -m "describe change"
alembic upgrade head
```

Requires `DATABASE_URL`/`database_url` to point at a running PostgreSQL
instance (see `docker-compose.yml` at the repo root).

## Layout

- `app/main.py` — FastAPI app instance and top-level routing.
- `app/core/` — configuration.
- `app/db/` — SQLAlchemy engine/session and declarative base.
- `app/shared/` — cross-cutting concerns used by multiple modules:
  `auth/`, `tenancy/`, `errors/`, `audit/`.
- `app/modules/` — business modules (`customers`, `projects`, `offers`,
  `invoices`, `time_entries`), each owning its own routes, schemas,
  services and models. Empty until a module is implemented.
- `app/workers/` — background/async workers.
- `alembic/` — migrations.
- `tests/` — `unit/` and `integration/` tests.
