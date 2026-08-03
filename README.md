# Cocoa Supply Chain Databank — Database

The shared PostgreSQL database (NeonDB, PostGIS, pgcrypto) behind the Cocoa Supply Chain Databank (Is Thai Cacao). Both backends — Go (mobile) and Kotlin (web) — read and write this same database, and the new LINE OA chatbot service will too, so the schema is the integration contract between all three.

**8 schemas · 65 tables · 80 FKs.** This repo is the source of truth — **Flyway migrations, not a hand-edited SQL dump.**

---

## Role in the 2026–2027 plan

This repo is the **sole owner of the migration history** — full reasoning in ADR 0005 (`docs/adr/data-model-changes` in the `cocoa-docs` site). Go, Kotlin, and the new Python chatbot service all treat this database as externally migrated; none of them run migrations themselves. This closes off the split-brain risk (`GO-1`) the Phase 0 review flagged as the single biggest cross-repo architectural risk.

## What's in this repo

```
migrations/
  V1__baseline.sql        <- current live schema, frozen as the starting point
flyway.conf                <- Flyway config (no secrets — see .env.sample)
.env.sample                 <- connection env vars, copy to .env locally
seed/                        <- dev-only fake data (not Flyway-tracked) — not decided yet
.github/workflows/
  migrate-check.yml         <- CI: runs the full migration chain against a fresh DB on every PR
```

## `V1__baseline.sql` — how it was made

Pulled directly from the live database via `pg_dump --schema-only --no-owner --no-privileges --no-tablespaces`, not reconstructed from the old transfer folder's `schema.sql`/`other.sql` files. This was a deliberate choice: `other.sql` was truncated in the handover (`DB-1`) and missing its trigger functions — going straight to the live source instead of trying to repair that file sidesteps the problem entirely. Verified before use:

- 65 `CREATE TABLE`, 80 `FOREIGN KEY` constraints, 4 `CREATE FUNCTION` / 4 `CREATE TRIGGER` (the `ref.*_constant` sync triggers — recovered correctly this way) — matches the schema's known shape exactly.
- Both `CREATE EXTENSION IF NOT EXISTS pgcrypto` and `... postgis` are included, so this file is self-sufficient for standing up a fresh database — nothing implicit assumed about the target.
- Two psql-only meta-commands (`\restrict` / `\unrestrict`, added by newer `pg_dump` versions) were stripped — Flyway executes raw SQL over JDBC and doesn't understand psql meta-commands; leaving them in would break `flyway migrate` on the very first line.

## First-time setup

```bash
cp .env.sample .env   # fill in FLYWAY_URL / FLYWAY_USER / FLYWAY_PASSWORD
flyway -configFiles=flyway.conf migrate
```

**Flyway's connection format is JDBC, not libpq** — different from the `postgresql://user:pass@host/db?params` strings used elsewhere in this project (Go, `psql`). Flyway needs `jdbc:postgresql://host/db?params`, with user/password passed separately. See `.env.sample`.

## Baselining the real database — not done yet, on purpose

This repo currently has `V1__baseline.sql` as a **file**, tested to actually build the schema from scratch — but `flyway baseline` (the command that tells Flyway "the real NeonDB already matches V1, start tracking from here") has **not** been run against the live database yet. That's a deliberate, deferred decision — not an oversight. Next steps to be given directly before that happens.

## Golden rules (Flyway's own discipline — non-negotiable)

- **Never edit a migration file once it has been applied anywhere** — dev, staging, prod, even just a teammate's laptop. Need a fix? Write a new migration.
- Migrations apply in strict version order, exactly once, tracked in Flyway's own `flyway_schema_history` table.
- `R__*.sql` (repeatable migrations) re-run automatically whenever their file content changes — the right home for things like the sync-trigger functions going forward, instead of versioned one-shot files.
- Reference/lookup data the app depends on to function (roles, provinces) belongs in a versioned migration, not a manually-run seed script — see `seed/README.md`.

## Known issues carried over (full detail: the docs site's Phase 0 register)

- `DB-2` — `form.response.task_log_id` has no FK — now a hard dependency for the chatbot integration, not just a standalone weak point.
- `DB-3` — no UNIQUE constraints anywhere (e.g. `auth.user_account.username`).
- `DB-5` — no secondary indexes / no GiST on geometry.

These become `V2`, `V3`, etc. — not edits to `V1__baseline.sql`.
