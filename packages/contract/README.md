# packages/contract

The shared API contract between `apps/api` (provider) and `apps/web` /
`apps/mobile` (consumers), expressed as an OpenAPI 3.0 specification.

- `openapi.yaml` — root document: info, servers, security schemes, and the
  `paths`/`schemas` index. Only endpoints that actually exist in `apps/api`
  are wired into it.
- `paths/` — one file per resource, referenced from `openapi.yaml`.
- `schemas/` — one file per data shape, referenced from `paths/` and
  `openapi.yaml`.

`customers.yaml`, `projects.yaml` and their schema counterparts are
placeholder stub files for the future `modules/customers` and
`modules/projects` backend modules. They are intentionally **not** yet
referenced from `openapi.yaml` — fill them in and wire them up alongside the
corresponding backend module.

Rules of thumb:

- This package describes the contract only — no server or client
  implementation code lives here.
- Keep it in sync with `apps/api` as endpoints are added, but let the
  backend module's implementation lag/lead in small, reviewable steps
  rather than speculatively documenting endpoints that don't exist yet.
- Validate with `pnpm --filter contract lint` (see `package.json` in this
  directory).
