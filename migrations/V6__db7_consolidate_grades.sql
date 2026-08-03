-- DB-7: three disconnected grade representations existed --
--   ref.grade_constant (A/B/C, 3 rows, already matches real harvest data)
--   ref.cocoa_bean_grade_constant (0 rows, unreferenced by anything)
--   collection.harvest_grade_detail.grade_code (free text, not linked to either)
--
-- Verified before writing:
--   - ref.grade_constant already has exactly the values in use: A, B, C.
--   - ref.cocoa_bean_grade_constant has zero rows and zero FK references
--     anywhere in the schema -- genuinely dead, safe to drop.
--   - Every existing collection.harvest_grade_detail.grade_code value
--     (A/B/C) matches a ref.grade_constant.grade_name exactly -- safe to
--     add the FK without any data cleanup.

ALTER TABLE ref.grade_constant
    ADD CONSTRAINT uq_grade_constant_grade_name UNIQUE (grade_name);

ALTER TABLE collection.harvest_grade_detail
    ADD CONSTRAINT fk_harvest_grade_detail_grade FOREIGN KEY (grade_code) REFERENCES ref.grade_constant (grade_name);

DROP TABLE ref.cocoa_bean_grade_constant;
