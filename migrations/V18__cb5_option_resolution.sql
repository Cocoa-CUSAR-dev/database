-- CB-5, corrected 2026-08-23: the register (and the project's own GitHub
-- tracker, chatbot#16) called part (a) "Done", but live data shows that
-- was never actually finished. weather_condition_code WAS renamed to
-- weather_condition_id at some point (not captured in any tracked
-- migration -- likely a manual edit during the 2026-08-09 live-test
-- session, same as several of the CB-* fixes from that day), but its
-- input_type was left at VARCHAR. buildSections() in web-backend's
-- FormRepository.kt only calls fetchRefChoices() for INPUT_TYPE=='OPTION'
-- rows, so this field has been silently free-text this whole time despite
-- looking fixed on paper.
--
-- Once flipped to OPTION, weather_condition_id needs no Kotlin special
-- case: fieldName.removeSuffix("_id")+"_constant" = "weather_condition_constant",
-- which is the real table (verified against V1 baseline), and its columns
-- (weather_condition_id, weather_condition_name) match the naive
-- convention exactly -- this is exactly the shape the convention was
-- built for.
UPDATE form.question
SET input_type = 'OPTION'
WHERE field_name = 'weather_condition_id';

-- CB-5(c): drying_batch's field is worse than "needs an OPTION flag" --
-- live data shows the field_name itself is wrong. The real destination,
-- processing.drying_batch.drying_facility_type_id, is a NOT NULL UUID FK
-- to ref.drying_facility_constant(drying_facility_type_id) -- a clean
-- surrogate key, not a natural-key case like harvest_grade_detail's
-- grade_code (CB-5(b), already fixed by V14). But the live field_name is
-- "drying_facility_type_code", which matches no column on
-- processing.drying_batch at all -- Go's liveColumns allowlist would
-- silently drop it, the same failure class as CB-2/CB-3/CB-4.
--
-- Scoped tightly: confirmed exactly 1 real (non-phantom) row has this
-- field_name anywhere in form.question, same as V14's grade_id rename.
UPDATE form.question
SET field_name = 'drying_facility_type_id', input_type = 'OPTION'
WHERE field_name = 'drying_facility_type_code';

-- Even with the rename, the naive convention still can't resolve this one:
-- "drying_facility_type_id".removeSuffix("_id")+"_constant" =
-- "drying_facility_type_constant", which doesn't exist -- the real table
-- is ref.drying_facility_constant (no "_type" in the table name, despite
-- the FK column being named drying_facility_type_id). Needs a Kotlin
-- special case mirroring the existing grade_code one (paired web-backend
-- change, not in this repo).

-- Both fields just became OPTION-typed, so per V16's own stated
-- convention ("no OPTION/BOOLEAN rows here since those are already fully
-- constrained by their own choice list"), their VARCHAR-shaped validation
-- rules no longer apply. weather_condition_code's row was already
-- orphaned (the field was renamed to weather_condition_id without this
-- row being updated); drying_facility_type_code's row is orphaned by the
-- rename two statements above.
DELETE FROM form.field_validation_rule
WHERE field_name IN ('weather_condition_code', 'drying_facility_type_code');
