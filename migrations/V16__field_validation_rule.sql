-- form.field_validation_rule: per-field validation rules for the
-- chatbot's guided flow. Chat answers currently aren't checked against
-- anything beyond is_mandatory and OPTION/BOOLEAN choices, so a bad
-- free-text/number answer reaches Go's dissection step unchecked instead
-- of getting a helpful re-ask.
--
-- Keyed by field_name, not question_id: 352 form.question rows collapse
-- to only 42 distinct field_names, and every field_name reused across
-- multiple handlers (notes, gis, upload, farm_id, quantity_kg, etc.) has
-- a consistent input_type everywhere -- same meaning, not a name
-- collision. A rule set once here applies to every existing and future
-- question row that shares the field_name, with no copy-forward step
-- needed when a new day's recurring task_form is created.
--
-- validation_rule keeps the constraint and its error message together in
-- one JSONB value, e.g. {"type":"FLOAT","min":0,"max":500,"errorMessage":
-- "..."} -- the CHECK below enforces every rule has a message. "type"
-- mirrors form.question.input_type verbatim; no OPTION/BOOLEAN rows here
-- since those are already fully constrained by their own choice list /
-- true-false shape.

CREATE TABLE form.field_validation_rule (
    field_name character varying PRIMARY KEY,
    validation_rule jsonb NOT NULL,
    CONSTRAINT chk_validation_rule_has_message CHECK (validation_rule ? 'errorMessage')
);

-- Initial ruleset for the 23 fields (of 42 total) that need a value-shape
-- check -- excludes OPTION/BOOLEAN (already constrained) and `upload`
-- (a file attachment despite input_type=VARCHAR, not text).
--
-- min/max/maxLength values are a first-pass estimate from each field's
-- domain shape, not yet confirmed with the forms' actual owner -- expect
-- a follow-up migration correcting specific numbers, same pattern V14
-- used to fix a wrong field_name after the fact.
INSERT INTO form.field_validation_rule (field_name, validation_rule) VALUES
    ('amount', '{"type":"FLOAT","min":0,"max":1000,"errorMessage":"กรุณากรอกปริมาณ 0-1,000"}'::jsonb),
    ('bean_color_inside', '{"type":"VARCHAR","maxLength":200,"errorMessage":"กรุณากรอกไม่เกิน 200 ตัวอักษร"}'::jsonb),
    ('bean_color_outside', '{"type":"VARCHAR","maxLength":200,"errorMessage":"กรุณากรอกไม่เกิน 200 ตัวอักษร"}'::jsonb),
    ('cut_test_result', '{"type":"VARCHAR","maxLength":500,"errorMessage":"กรุณากรอกไม่เกิน 500 ตัวอักษร"}'::jsonb),
    ('description', '{"type":"VARCHAR","maxLength":500,"errorMessage":"กรุณากรอกไม่เกิน 500 ตัวอักษร"}'::jsonb),
    ('drying_facility_type_code', '{"type":"VARCHAR","maxLength":200,"errorMessage":"กรุณากรอกไม่เกิน 200 ตัวอักษร"}'::jsonb),
    ('ends_at', '{"type":"DATETIME","maxDate":"today","errorMessage":"ห้ามระบุเวลาที่ยังไม่ถึง"}'::jsonb),
    ('fan_count', '{"type":"INT","min":0,"max":50,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนพัดลมเป็นจำนวนเต็ม 0-50"}'::jsonb),
    ('fan_power', '{"type":"FLOAT","min":0,"max":5000,"errorMessage":"กรุณากรอกกำลังไฟฟ้า 0-5,000 (วัตต์)"}'::jsonb),
    ('gis', '{"type":"GEODATA","validLatLng":true,"errorMessage":"พิกัดไม่ถูกต้อง"}'::jsonb),
    ('harvest_date', '{"type":"DATE","maxDate":"today","errorMessage":"ห้ามระบุวันที่ในอนาคต"}'::jsonb),
    ('humi', '{"type":"FLOAT","min":0,"max":100,"errorMessage":"ความชื้นต้องอยู่ระหว่าง 0-100%"}'::jsonb),
    ('logistic_result', '{"type":"VARCHAR","maxLength":500,"errorMessage":"กรุณากรอกไม่เกิน 500 ตัวอักษร"}'::jsonb),
    ('management_method', '{"type":"VARCHAR","maxLength":500,"errorMessage":"กรุณากรอกไม่เกิน 500 ตัวอักษร"}'::jsonb),
    ('notes', '{"type":"VARCHAR","maxLength":500,"errorMessage":"กรุณากรอกไม่เกิน 500 ตัวอักษร"}'::jsonb),
    ('quantity_kg', '{"type":"FLOAT","min":0,"max":5000,"errorMessage":"กรุณากรอกปริมาณ 0-5,000 (กก.)"}'::jsonb),
    ('smell', '{"type":"VARCHAR","maxLength":200,"errorMessage":"กรุณากรอกไม่เกิน 200 ตัวอักษร"}'::jsonb),
    ('started_at', '{"type":"DATETIME","maxDate":"today","errorMessage":"ห้ามระบุเวลาที่ยังไม่ถึง"}'::jsonb),
    ('tank_volume_liter', '{"type":"FLOAT","min":0,"max":10000,"errorMessage":"กรุณากรอกขนาดถัง 0-10,000 (ลิตร)"}'::jsonb),
    ('temp_inside', '{"type":"FLOAT","min":0,"max":100,"errorMessage":"กรุณากรอกอุณหภูมิ 0-100 (องศาเซลเซียส)"}'::jsonb),
    ('temp_outside', '{"type":"FLOAT","min":0,"max":60,"errorMessage":"กรุณากรอกอุณหภูมิ 0-60 (องศาเซลเซียส)"}'::jsonb),
    ('weather_condition_code', '{"type":"VARCHAR","maxLength":200,"errorMessage":"กรุณากรอกไม่เกิน 200 ตัวอักษร"}'::jsonb),
    ('weight_gram_per_pod', '{"type":"FLOAT","min":0,"max":500,"errorMessage":"กรุณากรอกน้ำหนัก 0-500 (กรัม)"}'::jsonb);
