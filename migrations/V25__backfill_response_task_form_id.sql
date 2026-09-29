-- US2-6 : backfills form.response.task_form_id for every row
-- submitted before mobile-backend started populating it
-- (mobile-backend#58). The column is the real FK (V9) to
-- form.task_form.form_id, but nothing wrote it until that fix, so every
-- historical response carries NULL.
--
-- Why this is needed and not just cosmetic: web-backend's
-- fetchAnswerFieldsForUserAndDate (US2-6's history/diary read path) skips
-- any response whose task_form_id is NULL, while fetchOwnSubmissionDays
-- lists days straight from form.response with no such filter. Without this
-- backfill the two disagree -- the history page lists every day the farmer
-- ever submitted on, and opening any pre-fix day renders an empty answer
-- table. That also defeats V22's documented fallback ("web-app's history
-- page falls back to the raw form-list view for any date with no row
-- here"), since the raw view is exactly what comes up empty.
--
-- Why deriving it is safe: task_log_id holds task.task_id (DB-1 -- a
-- misleading name kept deliberately, see mobile-backend's own comment at
-- the insert site), and form.task_form maps task_id -> form_id. Verified
-- against the dev database before writing this:
--   * every task has exactly one task_form row (78/78), so the derivation
--     is unambiguous -- no task could resolve to two different form_ids
--   * all 79 NULL rows resolve; 0 have no matching task_form
--   * all 6 rows mobile-backend#58 had already populated match the value
--     derived here exactly (6 agree / 0 disagree) -- so this reproduces
--     what the application itself writes, rather than guessing
--
-- Idempotent: only touches rows still NULL, so re-running is a no-op, and
-- it never overwrites a value the application wrote.

UPDATE form.response r
SET task_form_id = tf.form_id
FROM form.task_form tf
WHERE tf.task_id = r.task_log_id
  AND r.task_form_id IS NULL;
