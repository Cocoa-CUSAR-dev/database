-- CB-5, confirmed live 2026-08-19: the "grade" question on both
-- harvest_grade_detail forms is set to field_name = 'grade_id', which
-- resolves choices against ref.grade_constant.grade_id (a UUID surrogate
-- key). But the real destination column is
-- collection.harvest_grade_detail.grade_code, a NOT NULL natural-key text
-- column (e.g. "A"/"B"/"C") -- there is no grade_id column anywhere on
-- that table. Go's liveColumns allowlist correctly drops the unknown
-- "grade_id" key, so grade_code is never populated and the insert fails
-- its NOT NULL constraint.
--
-- Paired with a web-backend fix (FormRepository.kt's fetchRefChoices) that
-- special-cases field_name = 'grade_code' to resolve choices as
-- grade_constant.grade_name for both id and value, since grade_code
-- doesn't follow the standard "<field>_id -> <field>_constant, id column
-- named <field>_id" convention every other OPTION field uses.
--
-- Scoped tightly: confirmed exactly these 2 rows have field_name =
-- 'grade_id' anywhere in form.question, and no real domain table has a
-- grade_id column outside of ref.grade_constant itself (never a
-- legitimate destination column), so this WHERE clause can't touch
-- anything else.

UPDATE form.question
SET field_name = 'grade_code'
WHERE field_name = 'grade_id';
