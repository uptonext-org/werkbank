// packages/core
//
// Framework-independent domain logic shared between apps/web and
// apps/mobile (e.g. validation, formatting, view-model shaping).
//
// Boundaries:
// - No React, React Native, Expo, FastAPI, or other UI/framework imports.
// - Business rules (customers, projects, offers, invoices, time entries)
//   are owned by the Python backend in apps/api/app/modules — this
//   package must not re-implement them. It exists for small, genuinely
//   framework-independent helpers the frontends need on both platforms
//   (e.g. shared TypeScript types generated from the contract, formatting
//   utilities, pure client-side validation mirrors).
//
// Nothing is implemented yet — this is a placeholder export so the
// package builds and can be imported by apps/web and apps/mobile.
export const CORE_PACKAGE_NAME = '@werkbank/core';
