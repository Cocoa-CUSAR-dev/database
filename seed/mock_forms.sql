-- Fake dev/test data for the chatbot's Sprint 1 GuidedFlow engine testing.
-- NOT Flyway-tracked -- run manually against a genuinely EMPTY dev DB only,
-- after V1-V9 (or later) have been applied there. See seed/README.md for why
-- this lives here and not as a migration.
--
-- NOT needed against the team's shared flyway_test DB -- that one already has
-- 84 real-shaped form.task_form rows (incl. all 4 handlers below) and 35
-- auth.user_account rows. Checked directly before writing this file's first
-- version, which assumed flyway_test was empty and turned out to be wrong --
-- this script is kept for the next genuinely fresh DB (a new teammate's
-- local setup, a CI database, etc.), not applied there.
--
-- Structure (titles/handlers/questions) copied from the real, existing DB via
-- read-only `psql` inspection -- not production/in-use data, just realistic
-- shapes. All IDs below are freshly generated (gen_random_uuid() defaults),
-- not reused from the source DB.
--
-- The 4 forms are the "standalone" handlers from task-dissection-design.md
-- (own generated PK, no parent-row dependency) -- deliberately excludes the
-- 5 "blocked" handlers (farm_activity_fertilizer, farm_activity_chemical,
-- harvest_grade_detail, fermentation_batch, drying_batch), which need a
-- parent-ID resolution that's still an open product question.
--
-- Simplification: OPTION-type questions normally resolve to real choice
-- lists via Kotlin's fetchRefChoices (ADR 0001). This seed doesn't populate
-- ref.* tables, so the guided flow test path treats OPTION questions as
-- free text too -- fine for exercising state transitions, not a real picker.

BEGIN;

INSERT INTO auth.user_account (username)
VALUES ('test_farmer_1');

-- Form 1: harvest (4 questions -- OPTION x2, VARCHAR, DATE)
WITH new_task AS (
    INSERT INTO form.task (title, description, task_type)
    VALUES ('จดบันทึกยอดส่งโกโก้', 'Mock task -- harvest', 'FORM')
    RETURNING task_id
), new_form AS (
    INSERT INTO form.task_form (task_id, title, handler)
    SELECT task_id, 'จดบันทึกยอดส่งโกโก้', 'harvest' FROM new_task
    RETURNING form_id
), new_section AS (
    INSERT INTO form.section (form_id, title, sort_order)
    SELECT form_id, 'harvest', 1 FROM new_form
    RETURNING section_id
)
INSERT INTO form.question (section_id, label, input_type, field_name, is_mandatory, sort_order)
SELECT section_id, v.label, v.input_type, v.field_name, v.is_mandatory, v.sort_order
FROM new_section, (VALUES
    ('เลือกฟาร์มที่จัดส่ง', 'OPTION', 'farm_id', true, 0),
    ('หน่วยรวบรวมที่จัดส่ง', 'OPTION', 'hub_id', true, 1),
    ('อธิบายการขนส่งมายังหน่วยรวบรวม', 'VARCHAR', 'logistic_result', false, 2),
    ('วันที่ส่งมา', 'DATE', 'harvest_date', true, 3)
) AS v(label, input_type, field_name, is_mandatory, sort_order);

-- Form 2: farm_activity (6 questions -- OPTION x3, VARCHAR, GEODATA, VARCHAR)
WITH new_task AS (
    INSERT INTO form.task (title, description, task_type)
    VALUES ('จดกิจกรรมในสวน', 'Mock task -- farm_activity', 'FORM')
    RETURNING task_id
), new_form AS (
    INSERT INTO form.task_form (task_id, title, handler)
    SELECT task_id, 'จดกิจกรรมในสวน', 'farm_activity' FROM new_task
    RETURNING form_id
), new_section AS (
    INSERT INTO form.section (form_id, title, sort_order)
    SELECT form_id, 'farm_activity', 1 FROM new_form
    RETURNING section_id
)
INSERT INTO form.question (section_id, label, input_type, field_name, is_mandatory, sort_order)
SELECT section_id, v.label, v.input_type, v.field_name, v.is_mandatory, v.sort_order
FROM new_section, (VALUES
    ('ฟาร์มที่ทำกิจกรรม', 'OPTION', 'farm_id', true, 0),
    ('แปลงที่ดำเนินการ หากทำทั้งฟาร์มไม่ต้องระบุ', 'OPTION', 'plot_id', false, 1),
    ('กิจกรรมที่ทำ', 'OPTION', 'farm_activity_type_id', true, 2),
    ('อธิบายรายละเอียดหรือหมายเหตุเพิ่มเติม (ถ้ามี)', 'VARCHAR', 'description', false, 3),
    ('ตำแหน่งปัจจุบัน', 'GEODATA', 'gis', false, 4),
    ('แนบภาพประกอบ', 'VARCHAR', 'upload', false, 5)
) AS v(label, input_type, field_name, is_mandatory, sort_order);

-- Form 3: farm_pest_disease_record (6 questions -- OPTION x2, VARCHAR, BOOLEAN, GEODATA, VARCHAR)
WITH new_task AS (
    INSERT INTO form.task (title, description, task_type)
    VALUES ('รายงานโรคและศัตรูพืช', 'Mock task -- farm_pest_disease_record', 'FORM')
    RETURNING task_id
), new_form AS (
    INSERT INTO form.task_form (task_id, title, handler)
    SELECT task_id, 'รายงานโรคและศัตรูพืช', 'farm_pest_disease_record' FROM new_task
    RETURNING form_id
), new_section AS (
    INSERT INTO form.section (form_id, title, sort_order)
    SELECT form_id, 'farm_pest_disease_record', 1 FROM new_form
    RETURNING section_id
)
INSERT INTO form.question (section_id, label, input_type, field_name, is_mandatory, sort_order)
SELECT section_id, v.label, v.input_type, v.field_name, v.is_mandatory, v.sort_order
FROM new_section, (VALUES
    ('ฟาร์มที่พบปัญหา', 'OPTION', 'farm_id', true, 0),
    ('โรคหรือแมลงที่พบ', 'OPTION', 'pest_disease_id', true, 1),
    ('วิธีจัดการ (หากจัดการได้โปรดระบุ)', 'VARCHAR', 'management_method', false, 2),
    ('ทำให้ผลโกโก้เสียคุณภาพหรือไม่', 'BOOLEAN', 'is_quality_damage', true, 3),
    ('ตำแหน่งปัจจุบัน', 'GEODATA', 'gis', false, 4),
    ('แนบภาพประกอบ', 'VARCHAR', 'upload', false, 5)
) AS v(label, input_type, field_name, is_mandatory, sort_order);

-- Form 4: processing_record (10 questions -- ALL is_mandatory=false in the
-- real data, copied as-is. This means the guided flow's "first required
-- question" is immediately satisfied (zero required slots) -- expected
-- behavior of this shape, not a bug; see the chatbot repo's
-- tests/conversation/test_service.py for a case covering it.)
WITH new_task AS (
    INSERT INTO form.task (title, description, task_type)
    VALUES ('งานแปรรูปผลิตภัณฑ์', 'Mock task -- processing_record', 'FORM')
    RETURNING task_id
), new_form AS (
    INSERT INTO form.task_form (task_id, title, handler)
    SELECT task_id, 'งานแปรรูปผลิตภัณฑ์', 'processing_record' FROM new_task
    RETURNING form_id
), new_section AS (
    INSERT INTO form.section (form_id, title, sort_order)
    SELECT form_id, 'processing_record', 1 FROM new_form
    RETURNING section_id
)
INSERT INTO form.question (section_id, label, input_type, field_name, is_mandatory, sort_order)
SELECT section_id, v.label, v.input_type, v.field_name, v.is_mandatory, v.sort_order
FROM new_section, (VALUES
    ('ประเภทกิจกรรมการแปรรูปที่ดำเนินการ', 'OPTION', 'processing_activity_type_id', false, 0),
    ('อุณหภูมินอกถัง/สิ่งอำนวยความสะดวก (องศาเซลเซียส)', 'FLOAT', 'temp_outside', false, 1),
    ('อุณหภูมิในถัง (องศาเซลเซียส) - กรอกเฉพาะหากเป็นการหมัก', 'FLOAT', 'temp_inside', false, 2),
    ('ความชิ้น (RH %) - กรอกเฉพาะหากเป็นการทำแห้ง', 'FLOAT', 'humi', false, 3),
    ('อธิบายสภาพอากาศระหว่างการแปรรูป', 'VARCHAR', 'weather_condition_id', false, 4),
    ('อธิบายสีเปลือกนอกของเมล็ด', 'VARCHAR', 'bean_color_outside', false, 5),
    ('อธิบายสีเนื้อในของเมล็ด - เฉพาะการหมัก', 'VARCHAR', 'bean_color_inside', false, 6),
    ('อธิบายกลิ่นที่เกิดขึ้น', 'VARCHAR', 'smell', false, 7),
    ('ตำแหน่งปัจจุบัน', 'GEODATA', 'gis', false, 8),
    ('แนบภาพประกอบ', 'VARCHAR', 'upload', false, 9)
) AS v(label, input_type, field_name, is_mandatory, sort_order);

COMMIT;
