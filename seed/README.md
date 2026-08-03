# Seed data

Not yet decided. Two different kinds of data will eventually live here, and they're deliberately NOT the same thing:

- **Reference/lookup data the app needs to function** (roles, provinces, etc.) — this should become its own versioned Flyway migration (`migrations/V*__...sql`), not a file in this folder, since the app breaking without it existing makes it a schema-level concern.
- **Fake dev/test data** (sample farmers, test accounts) — this is what actually belongs in this folder. Run manually/locally, never applied automatically by Flyway or CI.

Nothing here yet — waiting on direction for what's next.
