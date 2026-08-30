# docs

- [`adr/`](./adr) — Architecture Decision Records: one file per significant,
  hard-to-reverse technical decision (why, not just what), so the reasoning
  survives past the people who were in the room.
- [`requirements/`](./requirements) — product/business requirements this
  system is built against.
- [`runbooks/`](./runbooks) — operational how-tos: workflows and procedures
  for running, deploying, and troubleshooting the system (e.g.
  [`git-workflow.md`](./runbooks/git-workflow.md)).

The API contract lives in [`packages/contract`](../packages/contract), not
here — it's consumed by code (backend, web, mobile), not just read by
humans.
