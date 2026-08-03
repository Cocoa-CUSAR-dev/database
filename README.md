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

## Known issues from the Phase 0 register — status

Full detail on each: the docs site's Phase 0 register. Status here:

| ID | Fix | Status |
|---|---|---|
| DB-1 | Restore `other.sql`'s trigger functions | **Already resolved by `V1__baseline.sql` itself** — it was pulled straight from the live database, not reconstructed from the truncated file, so the trigger functions came through correctly as a side effect. No separate migration needed. |
| DB-2 | FK `form.response.task_log_id` → `form.task` | `V2__db2_response_task_fk.sql` |
| DB-3 | UNIQUE + NOT NULL on identity columns | `V3__db3_unique_identity_columns.sql` — `username`, `role_name`, `permission_key`. Deliberately **not** `password_hash` (see the migration's own comment — LINE-only accounts need it nullable). |
| DB-4 | `geo_id` FKs (×3) | `V4__db4_geo_id_fks.sql` — `agriculture.farm`, `processing.hub`, `processing.processing_station`. |
| DB-5 | Hot-path indexes + GiST | `V5__db5_hot_path_indexes.sql` — every FK column across the schema that had no supporting index (62 of them), plus a GiST index on `storage.geo.geom`. |
| DB-6 | Adopt a migration tool | **This repo *is* that fix** — no separate migration; Flyway itself is the resolution. |
| DB-7 | Consolidate grades onto `grade_constant` | `V6__db7_consolidate_grades.sql` — `ref.cocoa_bean_grade_constant` was empty and unreferenced; dropped. `collection.harvest_grade_detail.grade_code` now FKs to `ref.grade_constant`. |
| DB-8 | Index + `created_at` on `storage.file` | `V7__db8_storage_file_hygiene.sql` |
| DB-9 | Hygiene batch | `V8__db9_hygiene_batch.sql` — `agriculture.farm_activity(_fertilizer/_chemical)`'s varchar PK/FK converted to uuid (all three tables were empty, safe); `CHECK` constraint on `storage.geo.source_type`. A couple of items (`form.response.status`, `storage.file.status`) were deliberately left alone — see the migration's own note on why. |

Every migration above was checked against the **live data** before being written (no orphaned FKs, no existing NULLs/duplicates that would make the constraint fail, no rows in the tables whose column types changed) — none of them should fail to apply. **None of them have been run against the real database yet** — same deliberate-pause policy as the baseline itself.
