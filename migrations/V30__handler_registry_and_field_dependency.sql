-- US2-13 (docs-and-plan#239, #240): one source of truth for which tables a
-- form can write into ("handlers"), and which questions depend on which.
--
-- Until now the handler list was hard-coded in four places that had to be
-- kept in sync by hand -- web-backend's HandlerCatalogRepository, Go's
-- standaloneHandlerTables and staleParentFields, and the chatbot's
-- parent_picker maps. Adding a handler meant editing three repos, and three
-- databank tables (farm_initial_cost, farm_economic_eval, plot_breed) never
-- got an input path at all. After this migration, adding a handler is: its
-- table (if new) plus one row here. No service code changes.
--
-- Rows are added by MIGRATION ONLY, never from a UI. schema_name.table_name
-- ends up in a dynamic INSERT in Go's dissection, so it has to stay a
-- reviewed, version-controlled value. Each service additionally checks the
-- identifiers against ^[a-z_][a-z0-9_]*$ and confirms the table exists in
-- information_schema before using it.
--
-- Numbered V30: V29 (response_correction_log) is the latest on dev.

CREATE TABLE form.handler_registry (
    handler character varying NOT NULL,
    schema_name character varying NOT NULL,
    table_name character varying NOT NULL,
    label_th character varying NOT NULL,
    description_th character varying NOT NULL,
    -- 'garden' | 'cost' | 'plot_info' | 'harvest' | 'processing' -- groups the
    -- Data Map page's columns; not used by any submit/validation path.
    category character varying NOT NULL,
    -- 'daily' | 'per_season' | 'yearly' | 'once' -- display only.
    frequency character varying NOT NULL,
    -- Child handlers only: the handler whose existing row this one hangs off
    -- (picked first in the chatbot), and the column on THIS handler's table
    -- that stores it. Both set or both null.
    parent_handler character varying,
    parent_field character varying,
    -- Fields the form builder must require even though the column itself is
    -- nullable. "Required" otherwise means NOT NULL with no default, read live
    -- from information_schema. Exists for farm_economic_eval.farm_id: the
    -- column allows NULL, but a yearly economic evaluation that isn't tied to
    -- a farm can't be used for any analysis.
    extra_required_fields character varying[] NOT NULL DEFAULT '{}',
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT pk_handler_registry PRIMARY KEY (handler),
    CONSTRAINT uq_handler_registry_table UNIQUE (schema_name, table_name),
    CONSTRAINT fk_handler_registry_parent FOREIGN KEY (parent_handler) REFERENCES form.handler_registry (handler),
    CONSTRAINT chk_handler_registry_parent_pair CHECK ((parent_handler IS NULL) = (parent_field IS NULL)),
    CONSTRAINT chk_handler_registry_identifiers CHECK (
        schema_name ~ '^[a-z_][a-z0-9_]*$'
        AND table_name ~ '^[a-z_][a-z0-9_]*$'
        AND (parent_field IS NULL OR parent_field ~ '^[a-z_][a-z0-9_]*$')
    ),
    CONSTRAINT chk_handler_registry_category CHECK (category IN ('garden', 'cost', 'plot_info', 'harvest', 'processing')),
    CONSTRAINT chk_handler_registry_frequency CHECK (frequency IN ('daily', 'per_season', 'yearly', 'once'))
);

-- form.field_dependency: one question's valid choices depend on another
-- question's answer (a plot only makes sense inside the farm chosen before
-- it). Keyed by field_name like form.field_validation_rule (V16): one row
-- covers every handler and every future form that uses the field.
--
-- link_table.link_column is where the relationship is stored: the row in
-- link_table whose <child_field> column equals the chosen child id must have
-- link_column equal to the chosen parent id. link_table keeps its schema
-- prefix ('agriculture.plot') because the child rows can live outside ref.
CREATE TABLE form.field_dependency (
    child_field character varying NOT NULL,
    parent_field character varying NOT NULL,
    link_table character varying NOT NULL,
    link_column character varying NOT NULL,
    label_th character varying NOT NULL,
    CONSTRAINT pk_field_dependency PRIMARY KEY (child_field, parent_field),
    CONSTRAINT chk_field_dependency_identifiers CHECK (
        child_field ~ '^[a-z_][a-z0-9_]*$'
        AND parent_field ~ '^[a-z_][a-z0-9_]*$'
        AND link_table ~ '^[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*$'
        AND link_column ~ '^[a-z_][a-z0-9_]*$'
    )
);

-- The 10 existing handlers -- table, parent and parent_field reproduce
-- exactly what web-backend, Go and the chatbot hard-code today, so every
-- service behaves identically after switching to this table -- plus the 3
-- databank tables that had no input path (§3.3 of the design doc). Parents
-- are inserted before their children so the self-FK is satisfied.
INSERT INTO form.handler_registry
    (handler, schema_name, table_name, label_th, description_th, category, frequency,
     parent_handler, parent_field, extra_required_fields, sort_order)
VALUES
    ('farm_activity', 'agriculture', 'farm_activity',
     'กิจกรรมในสวน', 'บันทึกกิจกรรมที่ทำในสวนแต่ละวัน เช่น ใส่ปุ๋ย ตัดแต่งกิ่ง กำจัดวัชพืช',
     'garden', 'daily', NULL, NULL, '{}', 10),
    ('farm_pest_disease_record', 'agriculture', 'farm_pest_disease_record',
     'โรคและศัตรูพืช', 'บันทึกโรคและศัตรูพืชที่พบในสวน',
     'garden', 'daily', NULL, NULL, '{}', 40),
    ('harvest', 'collection', 'harvest',
     'การเก็บเกี่ยว', 'บันทึกการเก็บเกี่ยวผลโกโก้และจุดรวบรวมที่นำไปส่ง',
     'harvest', 'per_season', NULL, NULL, '{}', 50),
    ('batch', 'processing', 'batch',
     'แบทช์แปรรูป', 'เปิดแบทช์การแปรรูปที่สถานีแปรรูป',
     'processing', 'per_season', NULL, NULL, '{}', 70),
    ('processing_record', 'processing', 'processing_record',
     'บันทึกการแปรรูป', 'บันทึกขั้นตอนการแปรรูปแต่ละวัน',
     'processing', 'daily', NULL, NULL, '{}', 80),
    ('farm_activity_fertilizer', 'agriculture', 'farm_activity_fertilizer',
     'การใส่ปุ๋ย', 'ปุ๋ยที่ใช้ในกิจกรรมในสวนที่บันทึกไว้แล้ว',
     'garden', 'daily', 'farm_activity', 'farm_activity_id', '{}', 20),
    ('farm_activity_chemical', 'agriculture', 'farm_activity_chemical',
     'การใช้สารเคมี/ชีวภัณฑ์', 'สารเคมีหรือชีวภัณฑ์ที่ใช้ในกิจกรรมในสวนที่บันทึกไว้แล้ว',
     'garden', 'daily', 'farm_activity', 'farm_activity_id', '{}', 30),
    ('harvest_grade_detail', 'collection', 'harvest_grade_detail',
     'การคัดเกรด', 'แยกน้ำหนักผลผลิตตามเกรดของการเก็บเกี่ยวที่บันทึกไว้แล้ว',
     'harvest', 'per_season', 'harvest', 'harvest_id', '{}', 60),
    ('fermentation_batch', 'processing', 'fermentation_batch',
     'การหมัก', 'รายละเอียดการหมักของแบทช์ที่เปิดไว้แล้ว',
     'processing', 'per_season', 'batch', 'batch_id', '{}', 90),
    ('drying_batch', 'processing', 'drying_batch',
     'การตาก', 'รายละเอียดการตากของแบทช์ที่เปิดไว้แล้ว',
     'processing', 'per_season', 'batch', 'batch_id', '{}', 100),
    ('farm_initial_cost', 'agriculture', 'farm_initial_cost',
     'ต้นทุนเริ่มต้นการปลูก', 'ต้นทุนตอนเริ่มปลูก เช่น ค่ากล้า วัสดุรองหลุม ค่าแรง และระบบน้ำ',
     'cost', 'once', NULL, NULL, '{}', 110),
    ('farm_economic_eval', 'agriculture', 'farm_economic_eval',
     'ประเมินต้นทุนและรายได้รายปี', 'ต้นทุนและรายได้ของฟาร์มในรอบปี เช่น ปุ๋ย ค่าแรง ผลผลิต ราคาโกโก้',
     'cost', 'yearly', NULL, NULL, '{farm_id}', 120),
    ('plot_breed', 'agriculture', 'plot_breed',
     'สายพันธุ์ในแปลง', 'สายพันธุ์โกโก้ที่ปลูกในแต่ละแปลงและจำนวนต้น (หนึ่งแถวต่อหนึ่งสายพันธุ์)',
     'plot_info', 'once', NULL, NULL, '{}', 130);

-- All three verified against real columns: agriculture.plot.farm_id,
-- ref.district_constant.province_id, ref.subdistrict_constant.district_id.
-- ref.plot_constant (where plot choices come from) has no farm_id of its
-- own, which is why plot_id's link_table is agriculture.plot -- the two are
-- kept in sync by trg_sync_plot_constant and share plot_id.
INSERT INTO form.field_dependency (child_field, parent_field, link_table, link_column, label_th) VALUES
    ('plot_id', 'farm_id', 'agriculture.plot', 'farm_id', 'แปลงต้องอยู่ในฟาร์มที่เลือก'),
    ('district_id', 'province_id', 'ref.district_constant', 'province_id', 'อำเภอต้องอยู่ในจังหวัดที่เลือก'),
    ('subdistrict_id', 'district_id', 'ref.subdistrict_constant', 'district_id', 'ตำบลต้องอยู่ในอำเภอที่เลือก');

-- Validation rules for the new handlers' numeric fields (min 0, same shape as
-- V16). None of these field_names had a rule before. Costs, prices and weights
-- are FLOAT; counts and frequencies are INT. No max: the plausible range for a
-- farm's yearly cost isn't known yet, and a wrong max blocks real answers.
-- ON CONFLICT DO NOTHING so an existing rule is never overwritten.
INSERT INTO form.field_validation_rule (field_name, validation_rule) VALUES
    -- farm_initial_cost
    ('plant_cost_per_tree', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('hole_filler_amount_g', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('hole_filler_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('prep_area_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('dig_hole_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('planting_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('watering_system_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    -- farm_economic_eval
    ('fertilizer_use_times_per_year', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('fertilizer_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('chem_bio_use_times_per_year', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('chem_bio_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('weeding_times_per_year', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('weeding_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('pruning_times_per_year', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('pruning_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('harvest_times_per_month', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('harvest_labor_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('harvest_volume_kg_per_time', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('cocoa_price', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('electricity_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('fuel_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    ('other_expenses_cost', '{"type":"FLOAT","min":0,"errorMessage":"กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป"}'::jsonb),
    -- plot_breed
    ('tree_count', '{"type":"INT","min":0,"integerOnly":true,"errorMessage":"กรุณากรอกจำนวนต้นเป็นจำนวนเต็มตั้งแต่ 0 ขึ้นไป"}'::jsonb)
ON CONFLICT (field_name) DO NOTHING;

-- Guard: every registry row and dependency must point at something real. A
-- typo here would otherwise only surface at the first submission. Fails the
-- migration (and rolls it back) instead.
DO $$
DECLARE
    missing text;
BEGIN
    SELECT string_agg(r.schema_name || '.' || r.table_name, ', ') INTO missing
    FROM form.handler_registry r
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.tables t
        WHERE t.table_schema = r.schema_name AND t.table_name = r.table_name
    );
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'handler_registry points at missing table(s): %', missing;
    END IF;

    SELECT string_agg(r.handler || '.' || r.parent_field, ', ') INTO missing
    FROM form.handler_registry r
    WHERE r.parent_field IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema = r.schema_name AND c.table_name = r.table_name
          AND c.column_name = r.parent_field
    );
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'handler_registry parent_field not a column of its table: %', missing;
    END IF;

    SELECT string_agg(d.link_table || '.' || d.link_column || ' / ' || d.child_field, ', ') INTO missing
    FROM form.field_dependency d
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema || '.' || c.table_name = d.link_table AND c.column_name = d.link_column
    ) OR NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema || '.' || c.table_name = d.link_table AND c.column_name = d.child_field
    );
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'field_dependency link column(s) missing: %', missing;
    END IF;
END $$;
