# packages/core

Framework-independent domain logic shared by `apps/web` and `apps/mobile`.

**Rules:**

- No dependency on React, React Native, Expo, FastAPI, or any other
  UI/framework package.
- No business logic yet — the Python backend (`apps/api/app/modules`) is the
  single source of truth for business rules (customers, projects, offers,
  invoices, time entries). This package is **not** a place to re-implement
  those rules in TypeScript; it exists for genuinely shared,
  framework-independent frontend code (e.g. types generated from
  `packages/contract`, formatting/validation helpers used by both
  `apps/web` and `apps/mobile`).

Add code under `src/` and export it from `src/index.ts`.
