# Seed data

Not yet decided. Two different kinds of data will eventually live here, and they're deliberately NOT the same thing:

- **Reference/lookup data the app needs to function** (roles, provinces, etc.) — this should become its own versioned Flyway migration (`migrations/V*__...sql`), not a file in this folder, since the app breaking without it existing makes it a schema-level concern.
- **Fake dev/test data** (sample farmers, test accounts) — this is what actually belongs in this folder. Run manually/locally, never applied automatically by Flyway or CI.

## What's here

- `mock_forms.sql` — 1 test farmer (`auth.user_account`) + 4 mock forms (`form.task`/`task_form`/`section`/`question`), structured after real forms but with fresh IDs and no real farmer data. Built for the chatbot's Sprint 1 dialogue-engine testing (no Kotlin/Go required to exercise the guided flow against these). Only useful against a genuinely **empty** DB — the team's shared `flyway_test` already has equivalent real-shaped data (84 `form.task_form` rows, 35 `auth.user_account` rows), so it wasn't run there; this is for the next fresh DB (new teammate, CI, etc.):

  ```
  psql "$DATABASE_URL" -f seed/mock_forms.sql
  ```
