# packages/db

Placeholder for database schema and migration-related assets that are
shared across more than just `apps/api` (e.g. reference SQL, ERDs, seed
data, or a future standalone Python models package used by `apps/api` and
`apps/workers`-style background jobs).

Today, the actual database wiring lives in `apps/api`:

- SQLAlchemy engine/session setup: `apps/api/app/db/`
- Alembic migrations: `apps/api/alembic/`

Nothing is implemented here yet — no schema, no migrations. This directory
is intentionally empty of code until there is a concrete need to share
database code outside of `apps/api`.
