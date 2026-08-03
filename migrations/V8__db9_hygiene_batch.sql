-- DB-9: hygiene batch.
--
-- 1. agriculture.farm_activity(_fertilizer/_chemical) used a varchar PK/FK
--    instead of uuid, inconsistent with every other table in the schema.
--    Verified before writing: all three tables have zero rows today, so
--    this is a clean type change with nothing to convert or backfill.

ALTER TABLE agriculture.farm_activity_fertilizer DROP CONSTRAINT fk_farm_activity_fertilizer_activity;
ALTER TABLE agriculture.farm_activity_chemical DROP CONSTRAINT fk_farm_activity_chemical_activity;

ALTER TABLE agriculture.farm_activity
    ALTER COLUMN farm_activity_id TYPE uuid USING gen_random_uuid(),
    ALTER COLUMN farm_activity_id SET DEFAULT gen_random_uuid();

ALTER TABLE agriculture.farm_activity_fertilizer
    ALTER COLUMN farm_activity_id TYPE uuid USING gen_random_uuid();

ALTER TABLE agriculture.farm_activity_chemical
    ALTER COLUMN farm_activity_id TYPE uuid USING gen_random_uuid();

ALTER TABLE agriculture.farm_activity_fertilizer
    ADD CONSTRAINT fk_farm_activity_fertilizer_activity FOREIGN KEY (farm_activity_id) REFERENCES agriculture.farm_activity (farm_activity_id);

ALTER TABLE agriculture.farm_activity_chemical
    ADD CONSTRAINT fk_farm_activity_chemical_activity FOREIGN KEY (farm_activity_id) REFERENCES agriculture.farm_activity (farm_activity_id);

-- 2. storage.geo.source_type is free text; only four real values are in use
--    today. Verified before writing: 'plot', 'region', 'hub', 'farm' are the
--    only values that currently appear.

ALTER TABLE storage.geo
    ADD CONSTRAINT chk_geo_source_type CHECK (source_type IN ('plot', 'region', 'hub', 'farm'));

-- Deliberately NOT touched here, left as a judgment call for whoever owns
-- these features rather than guessed at:
--   - form.response.status / storage.file.status: both are free-text status
--     columns, but the real set of valid values isn't clearly established
--     (form.response only ever stores the literal 'COMPLETED' today, and
--     storage.file has zero rows to infer from) -- adding a CHECK here would
--     be guessing, not verifying.
