--
-- PostgreSQL database dump
--


-- Dumped from database version 17.10 (4f20678)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: agriculture; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA agriculture;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: collection; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA collection;


--
-- Name: form; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA form;


--
-- Name: processing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA processing;


--
-- Name: ref; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ref;


--
-- Name: research; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA research;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: sync_farm_constant(); Type: FUNCTION; Schema: ref; Owner: -
--

CREATE FUNCTION ref.sync_farm_constant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ref.farm_constant (farm_id, farm_name)
        VALUES (NEW.farm_id, NEW.farm_name);

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE ref.farm_constant
        SET farm_name = NEW.farm_name
        WHERE farm_id = NEW.farm_id;

    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM ref.farm_constant
        WHERE farm_id = OLD.farm_id;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: sync_hub_constant(); Type: FUNCTION; Schema: ref; Owner: -
--

CREATE FUNCTION ref.sync_hub_constant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ref.hub_constant (hub_id, hub_name)
        VALUES (NEW.hub_id, NEW.hub_name);

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE ref.hub_constant
        SET hub_name = NEW.hub_name
        WHERE hub_id = NEW.hub_id;

    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM ref.hub_constant
        WHERE hub_id = OLD.hub_id;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: sync_plot_constant(); Type: FUNCTION; Schema: ref; Owner: -
--

CREATE FUNCTION ref.sync_plot_constant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ref.plot_constant (plot_id, plot_name)
        VALUES (NEW.plot_id, NEW.plot_name);

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE ref.plot_constant
        SET plot_name = NEW.plot_name
        WHERE plot_id = NEW.plot_id;

    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM ref.plot_constant
        WHERE plot_id = OLD.plot_id;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: sync_processing_station_constant(); Type: FUNCTION; Schema: ref; Owner: -
--

CREATE FUNCTION ref.sync_processing_station_constant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ref.processing_station_constant (processing_station_id, processing_station_name)
        VALUES (NEW.processing_station_id, NEW.processing_station_name);

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE ref.processing_station_constant
        SET processing_station_name = NEW.processing_station_name
        WHERE processing_station_id = NEW.processing_station_id;

    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM ref.processing_station_constant
        WHERE processing_station_id = OLD.processing_station_id;
    END IF;

    RETURN NEW;
END;
$$;


SET default_table_access_method = heap;

--
-- Name: farm; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm (
    farm_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_name character varying,
    hub_id uuid,
    geo_id uuid,
    found_date date DEFAULT CURRENT_DATE,
    total_area numeric,
    address_detail character varying,
    subdistrict_id uuid NOT NULL,
    district_id uuid NOT NULL,
    province_id uuid NOT NULL,
    zip_code character varying,
    contact_name character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farm_activity; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_activity (
    farm_activity_id character varying NOT NULL,
    farm_id uuid NOT NULL,
    plot_id uuid,
    farm_activity_type_id uuid NOT NULL,
    description character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farm_activity_chemical; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_activity_chemical (
    farm_activity_id character varying NOT NULL,
    chem_bio_id uuid NOT NULL,
    amount numeric(10,2)
);


--
-- Name: farm_activity_fertilizer; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_activity_fertilizer (
    farm_activity_id character varying NOT NULL,
    fertilizer_id uuid NOT NULL
);


--
-- Name: farm_economic_eval; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_economic_eval (
    eval_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_id uuid,
    is_naive_planter boolean DEFAULT false,
    fertilizer_use_times_per_year integer DEFAULT 0,
    fertilizer_cost numeric DEFAULT 0,
    chem_bio_use_times_per_year integer DEFAULT 0,
    chem_bio_cost numeric DEFAULT 0,
    weeding_times_per_year integer DEFAULT 0,
    weeding_by_self boolean DEFAULT false,
    weeding_labor_cost numeric DEFAULT 0,
    pruning_times_per_year integer DEFAULT 0,
    pruning_by_self boolean DEFAULT false,
    pruning_labor_cost numeric DEFAULT 0,
    harvest_times_per_month integer DEFAULT 0,
    harvest_by_self boolean DEFAULT false,
    harvest_labor_cost numeric DEFAULT 0,
    harvest_volume_kg_per_time numeric DEFAULT 0,
    cocoa_price numeric DEFAULT 0,
    electricity_cost numeric DEFAULT 0,
    fuel_cost numeric DEFAULT 0,
    other_expenses_cost numeric DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farm_initial_cost; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_initial_cost (
    farm_initial_cost_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_id uuid NOT NULL,
    plant_cost_per_tree numeric DEFAULT 0,
    hole_filler_material_id uuid,
    hole_filler_amount_g numeric DEFAULT 0,
    hole_filler_cost numeric DEFAULT 0,
    prep_area_by_self boolean DEFAULT false,
    prep_area_labor_cost numeric DEFAULT 0,
    dig_hole_by_self boolean DEFAULT false,
    dig_hole_labor_cost numeric DEFAULT 0,
    planting_by_self boolean DEFAULT false,
    planting_labor_cost numeric DEFAULT 0,
    watering_system_cost numeric DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farm_pest_disease_record; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farm_pest_disease_record (
    pest_disease_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_id uuid NOT NULL,
    plot_id uuid,
    pest_disease_id uuid NOT NULL,
    management_method character varying,
    is_quality_damage boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farmer; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farmer (
    user_id uuid NOT NULL,
    first_name character varying,
    last_name character varying,
    nickname character varying,
    birth_date date,
    nationality character varying,
    ethnicity character varying,
    religion character varying,
    id_card_number character varying,
    address_detail character varying,
    subdistrict_id uuid NOT NULL,
    district_id uuid NOT NULL,
    province_id uuid NOT NULL,
    zip_code character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    salary_income numeric,
    family_member_count integer DEFAULT 1,
    agri_worker_count integer DEFAULT 1,
    agri_experience date DEFAULT CURRENT_DATE,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: farmer_farm; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.farmer_farm (
    farmer_farm_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farmer_id uuid NOT NULL,
    farm_id uuid NOT NULL
);


--
-- Name: plot; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.plot (
    plot_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_id uuid NOT NULL,
    plot_name character varying,
    total_area numeric,
    land_ownership character varying,
    cocoa_planted_area numeric,
    has_chemical_use boolean DEFAULT false,
    land_type_id uuid,
    soil_type_id uuid,
    water_source_id uuid,
    watering_system_id uuid,
    found_date date DEFAULT CURRENT_DATE,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: plot_breed; Type: TABLE; Schema: agriculture; Owner: -
--

CREATE TABLE agriculture.plot_breed (
    plot_breed_id uuid DEFAULT gen_random_uuid() NOT NULL,
    plot_id uuid NOT NULL,
    breed_id uuid NOT NULL,
    tree_count integer,
    is_primary_breed boolean DEFAULT false
);


--
-- Name: permission; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.permission (
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_key character varying,
    description character varying
);


--
-- Name: role; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.role (
    role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_name character varying
);


--
-- Name: role_permission; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.role_permission (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL
);


--
-- Name: user_account; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_account (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying,
    password_hash character varying,
    is_password_reset boolean DEFAULT false,
    is_requires_password_reset boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_role; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.user_role (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL
);


--
-- Name: harvest; Type: TABLE; Schema: collection; Owner: -
--

CREATE TABLE collection.harvest (
    harvest_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hub_id uuid NOT NULL,
    farm_id uuid NOT NULL,
    plot_id uuid,
    tree_id uuid,
    harvest_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: harvest_collection; Type: TABLE; Schema: collection; Owner: -
--

CREATE TABLE collection.harvest_collection (
    collection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_id uuid NOT NULL,
    batch_id uuid NOT NULL
);


--
-- Name: harvest_grade_detail; Type: TABLE; Schema: collection; Owner: -
--

CREATE TABLE collection.harvest_grade_detail (
    harvest_id uuid NOT NULL,
    grade_code character varying NOT NULL,
    quantity_kg numeric,
    description character varying DEFAULT ''::character varying,
    is_clean boolean,
    is_appropriate_size boolean,
    weight_gram_per_pod numeric,
    is_sprout boolean,
    is_dry boolean,
    is_shriveled boolean,
    cut_test_result character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: assignment; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.assignment (
    assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying DEFAULT 'NOT_STARTED'::character varying NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: question; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.question (
    question_id uuid DEFAULT gen_random_uuid() NOT NULL,
    section_id uuid NOT NULL,
    label character varying,
    description character varying,
    input_type character varying DEFAULT 'VARCHAR'::character varying,
    field_name character varying,
    default_value jsonb,
    sort_order integer,
    is_mandatory boolean DEFAULT false,
    is_active boolean DEFAULT true
);


--
-- Name: question_visibility; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.question_visibility (
    visibility_id uuid DEFAULT gen_random_uuid() NOT NULL,
    question_id uuid NOT NULL,
    role character varying,
    province_id uuid
);


--
-- Name: response; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.response (
    response_id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_log_id uuid NOT NULL,
    user_id uuid NOT NULL,
    submitted_at timestamp without time zone DEFAULT now(),
    answer jsonb,
    status character varying
);


--
-- Name: section; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.section (
    section_id uuid DEFAULT gen_random_uuid() NOT NULL,
    form_id uuid NOT NULL,
    title character varying,
    description character varying,
    sort_order integer,
    is_active boolean DEFAULT true
);


--
-- Name: task; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.task (
    task_id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying,
    description character varying DEFAULT ''::character varying,
    task_type character varying DEFAULT 'FORM'::character varying,
    open_at timestamp without time zone,
    close_at timestamp without time zone
);


--
-- Name: task_form; Type: TABLE; Schema: form; Owner: -
--

CREATE TABLE form.task_form (
    form_id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    title character varying,
    description character varying,
    content character varying DEFAULT ''::character varying,
    handler character varying,
    is_multiple_submit boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: batch; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.batch (
    batch_id uuid DEFAULT gen_random_uuid() NOT NULL,
    processing_station_id uuid NOT NULL,
    origin character varying,
    notes character varying DEFAULT ''::character varying,
    quantity_kg numeric,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: drying_batch; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.drying_batch (
    batch_id uuid NOT NULL,
    drying_facility_type_id uuid NOT NULL,
    has_air_flow boolean DEFAULT false,
    fan_count integer DEFAULT 0,
    fan_power numeric(8,2) DEFAULT 0,
    notes character varying,
    started_at timestamp without time zone,
    ends_at timestamp without time zone
);


--
-- Name: fermentation_batch; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.fermentation_batch (
    batch_id uuid NOT NULL,
    air_exposure_type_id uuid NOT NULL,
    tank_material_id uuid NOT NULL,
    tank_volume_liter numeric,
    notes character varying,
    started_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL
);


--
-- Name: hub; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.hub (
    hub_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hub_name character varying,
    geo_id uuid,
    found_date date,
    address_detail character varying,
    subdistrict_id uuid NOT NULL,
    district_id uuid NOT NULL,
    province_id uuid NOT NULL,
    zip_code character varying,
    contact_name character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: hub_collector; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.hub_collector (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hub_id uuid,
    first_name character varying,
    last_name character varying,
    nickname character varying,
    birthdate date,
    id_card_number character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    subdistrict_id uuid,
    district_id uuid,
    province_id uuid,
    zip_code character varying
);


--
-- Name: processing_record; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.processing_record (
    processing_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    batch_id uuid,
    processing_activity_type_id uuid,
    temp_outside numeric,
    temp_inside numeric,
    humi numeric,
    weather_condition_id uuid,
    bean_color_outside character varying,
    bean_color_inside character varying,
    smell character varying,
    recorded_at timestamp without time zone
);


--
-- Name: processing_station; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.processing_station (
    processing_station_id uuid DEFAULT gen_random_uuid() NOT NULL,
    processing_station_name character varying,
    hub_id uuid,
    geo_id uuid,
    found_date date,
    processing_station_area numeric,
    address_detail character varying,
    subdistrict_id uuid NOT NULL,
    district_id uuid NOT NULL,
    province_id uuid NOT NULL,
    zip_code character varying,
    contact_name character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: processor; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.processor (
    user_id uuid NOT NULL,
    first_name character varying,
    last_name character varying,
    nickname character varying,
    birth_date date,
    id_card_number character varying,
    address_detail character varying,
    subdistrict_id uuid,
    district_id uuid,
    province_id uuid,
    zip_code character varying,
    phone_number character varying,
    line character varying,
    facebook character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: processor_processing_station; Type: TABLE; Schema: processing; Owner: -
--

CREATE TABLE processing.processor_processing_station (
    processor_processing_station_id uuid DEFAULT gen_random_uuid() NOT NULL,
    processor_id uuid NOT NULL,
    processing_station_id uuid NOT NULL
);


--
-- Name: air_exposure_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.air_exposure_type_constant (
    air_exposure_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    air_exposure_type_name character varying
);


--
-- Name: breed_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.breed_constant (
    breed_id uuid DEFAULT gen_random_uuid() NOT NULL,
    breed_name character varying
);


--
-- Name: chem_bio_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.chem_bio_constant (
    chem_bio_id uuid DEFAULT gen_random_uuid() NOT NULL,
    chem_bio_name character varying,
    description character varying DEFAULT ''::character varying
);


--
-- Name: cocoa_bean_grade_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.cocoa_bean_grade_constant (
    cocoa_bean_grade_id uuid DEFAULT gen_random_uuid() NOT NULL,
    cocoa_bean_grade_name character varying
);


--
-- Name: district_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.district_constant (
    district_id uuid DEFAULT gen_random_uuid() NOT NULL,
    district_name_th character varying(255),
    district_name_en character varying(255),
    province_id uuid NOT NULL,
    description character varying DEFAULT ''::character varying
);


--
-- Name: drying_facility_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.drying_facility_constant (
    drying_facility_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    drying_facility_type_name character varying
);


--
-- Name: farm_activity_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.farm_activity_type_constant (
    farm_activity_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    farm_activity_type_name character varying
);


--
-- Name: farm_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.farm_constant (
    farm_id uuid NOT NULL,
    farm_name character varying NOT NULL
);


--
-- Name: fertilizer_application_stage_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.fertilizer_application_stage_constant (
    fertilizer_application_stage_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fertilizer_application_stage_name_th character varying(255),
    fertilizer_application_stage_name_en character varying(255),
    fertilizer_application_stage_description character varying DEFAULT ''::character varying
);


--
-- Name: fertilizer_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.fertilizer_constant (
    fertilizer_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fertilizer_name character varying,
    description character varying DEFAULT ''::character varying,
    is_organic boolean DEFAULT false
);


--
-- Name: grade_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.grade_constant (
    grade_id uuid DEFAULT gen_random_uuid() NOT NULL,
    grade_name character varying(100),
    is_fail boolean DEFAULT false
);


--
-- Name: hole_filler_material_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.hole_filler_material_constant (
    hole_filler_material_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hole_filler_material_name character varying
);


--
-- Name: hub_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.hub_constant (
    hub_id uuid NOT NULL,
    hub_name character varying NOT NULL
);


--
-- Name: land_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.land_type_constant (
    land_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    land_type_name character varying
);


--
-- Name: location_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.location_type_constant (
    location_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    location_type_name character varying
);


--
-- Name: pest_disease_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.pest_disease_constant (
    pest_disease_id uuid DEFAULT gen_random_uuid() NOT NULL,
    pest_disease_name character varying,
    type character varying,
    description character varying DEFAULT ''::character varying
);


--
-- Name: plot_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.plot_constant (
    plot_id uuid NOT NULL,
    plot_name character varying NOT NULL
);


--
-- Name: processing_activity_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.processing_activity_type_constant (
    processing_activity_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    processing_activity_type_name character varying
);


--
-- Name: processing_defect_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.processing_defect_constant (
    processing_defect_id uuid DEFAULT gen_random_uuid() NOT NULL,
    processing_defect_name character varying
);


--
-- Name: processing_station_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.processing_station_constant (
    processing_station_id uuid NOT NULL,
    processing_station_name character varying NOT NULL
);


--
-- Name: province_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.province_constant (
    province_id uuid DEFAULT gen_random_uuid() NOT NULL,
    province_name_th character varying(255),
    province_name_en character varying(255),
    description character varying DEFAULT ''::character varying
);


--
-- Name: soil_type_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.soil_type_constant (
    soil_type_id uuid DEFAULT gen_random_uuid() NOT NULL,
    soil_type_name character varying
);


--
-- Name: subdistrict_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.subdistrict_constant (
    subdistrict_id uuid DEFAULT gen_random_uuid() NOT NULL,
    subdistrict_name_th character varying(255),
    subdistrict_name_en character varying(255),
    district_id uuid NOT NULL,
    description character varying DEFAULT ''::character varying,
    zipcode character varying
);


--
-- Name: tank_material_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.tank_material_constant (
    tank_material_id uuid DEFAULT gen_random_uuid() NOT NULL,
    tank_material_name character varying
);


--
-- Name: water_source_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.water_source_constant (
    water_source_id uuid DEFAULT gen_random_uuid() NOT NULL,
    water_source_name character varying
);


--
-- Name: watering_system_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.watering_system_constant (
    watering_system_id uuid DEFAULT gen_random_uuid() NOT NULL,
    watering_system_name character varying
);


--
-- Name: weather_condition_constant; Type: TABLE; Schema: ref; Owner: -
--

CREATE TABLE ref.weather_condition_constant (
    weather_condition_id uuid DEFAULT gen_random_uuid() NOT NULL,
    weather_condition_name character varying
);


--
-- Name: researcher; Type: TABLE; Schema: research; Owner: -
--

CREATE TABLE research.researcher (
    user_id uuid NOT NULL,
    first_name character varying,
    last_name character varying,
    organization character varying
);


--
-- Name: file; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.file (
    file_id uuid DEFAULT gen_random_uuid() NOT NULL,
    file_name character varying(255),
    table_name character varying,
    ref_id uuid NOT NULL,
    code character varying,
    original_name character varying(255),
    file_extension character varying(20),
    mime_type character varying(100),
    file_size bigint,
    storage_path character varying,
    storage_provider character varying(50),
    checksum character varying(128),
    version integer DEFAULT 1,
    is_public boolean DEFAULT false,
    status character varying(20) DEFAULT 'active'::character varying,
    uploaded_by uuid NOT NULL
);


--
-- Name: geo; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.geo (
    geo_id uuid DEFAULT gen_random_uuid() NOT NULL,
    uploaded_by uuid NOT NULL,
    geom public.geometry(Geometry,4326),
    code character varying,
    source_type character varying(20),
    area_sq_m double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    ip_address inet
);


--
-- Name: farm pk_farm; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm
    ADD CONSTRAINT pk_farm PRIMARY KEY (farm_id);


--
-- Name: farm_activity pk_farm_activity; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity
    ADD CONSTRAINT pk_farm_activity PRIMARY KEY (farm_activity_id);


--
-- Name: farm_activity_chemical pk_farm_activity_chemical; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_chemical
    ADD CONSTRAINT pk_farm_activity_chemical PRIMARY KEY (farm_activity_id, chem_bio_id);


--
-- Name: farm_activity_fertilizer pk_farm_activity_fertilizer; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_fertilizer
    ADD CONSTRAINT pk_farm_activity_fertilizer PRIMARY KEY (farm_activity_id, fertilizer_id);


--
-- Name: farm_economic_eval pk_farm_economic_eval; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_economic_eval
    ADD CONSTRAINT pk_farm_economic_eval PRIMARY KEY (eval_id);


--
-- Name: farm_initial_cost pk_farm_initial_cost; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_initial_cost
    ADD CONSTRAINT pk_farm_initial_cost PRIMARY KEY (farm_initial_cost_id);


--
-- Name: farm_pest_disease_record pk_farm_pest_disease_record; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_pest_disease_record
    ADD CONSTRAINT pk_farm_pest_disease_record PRIMARY KEY (pest_disease_record_id);


--
-- Name: farmer pk_farmer; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer
    ADD CONSTRAINT pk_farmer PRIMARY KEY (user_id);


--
-- Name: farmer_farm pk_farmer_farm; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer_farm
    ADD CONSTRAINT pk_farmer_farm PRIMARY KEY (farmer_farm_id);


--
-- Name: plot pk_plot; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT pk_plot PRIMARY KEY (plot_id);


--
-- Name: plot_breed pk_plot_breed; Type: CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot_breed
    ADD CONSTRAINT pk_plot_breed PRIMARY KEY (plot_breed_id);


--
-- Name: permission pk_permission; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (permission_id);


--
-- Name: role pk_role; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role
    ADD CONSTRAINT pk_role PRIMARY KEY (role_id);


--
-- Name: role_permission pk_role_permission; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role_permission
    ADD CONSTRAINT pk_role_permission PRIMARY KEY (role_id, permission_id);


--
-- Name: user_account pk_user_account; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_account
    ADD CONSTRAINT pk_user_account PRIMARY KEY (user_id);


--
-- Name: user_role pk_user_role; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_role
    ADD CONSTRAINT pk_user_role PRIMARY KEY (user_id, role_id);


--
-- Name: harvest pk_harvest; Type: CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest
    ADD CONSTRAINT pk_harvest PRIMARY KEY (harvest_id);


--
-- Name: harvest_collection pk_harvest_collection; Type: CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest_collection
    ADD CONSTRAINT pk_harvest_collection PRIMARY KEY (collection_id);


--
-- Name: harvest_grade_detail pk_harvest_grade_detail; Type: CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest_grade_detail
    ADD CONSTRAINT pk_harvest_grade_detail PRIMARY KEY (harvest_id, grade_code);


--
-- Name: assignment pk_assignment; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.assignment
    ADD CONSTRAINT pk_assignment PRIMARY KEY (assignment_id);


--
-- Name: task_form pk_form; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.task_form
    ADD CONSTRAINT pk_form PRIMARY KEY (form_id);


--
-- Name: question pk_question; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.question
    ADD CONSTRAINT pk_question PRIMARY KEY (question_id);


--
-- Name: question_visibility pk_question_visibility; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.question_visibility
    ADD CONSTRAINT pk_question_visibility PRIMARY KEY (visibility_id);


--
-- Name: response pk_response; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.response
    ADD CONSTRAINT pk_response PRIMARY KEY (response_id);


--
-- Name: section pk_section; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.section
    ADD CONSTRAINT pk_section PRIMARY KEY (section_id);


--
-- Name: task pk_task; Type: CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.task
    ADD CONSTRAINT pk_task PRIMARY KEY (task_id);


--
-- Name: batch pk_batch; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.batch
    ADD CONSTRAINT pk_batch PRIMARY KEY (batch_id);


--
-- Name: drying_batch pk_drying_batch; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.drying_batch
    ADD CONSTRAINT pk_drying_batch PRIMARY KEY (batch_id);


--
-- Name: fermentation_batch pk_fermentation_batch; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.fermentation_batch
    ADD CONSTRAINT pk_fermentation_batch PRIMARY KEY (batch_id);


--
-- Name: hub pk_hub; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub
    ADD CONSTRAINT pk_hub PRIMARY KEY (hub_id);


--
-- Name: hub_collector pk_hub_collector; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub_collector
    ADD CONSTRAINT pk_hub_collector PRIMARY KEY (user_id);


--
-- Name: processing_record pk_processing_record; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_record
    ADD CONSTRAINT pk_processing_record PRIMARY KEY (processing_record_id);


--
-- Name: processing_station pk_processing_station; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_station
    ADD CONSTRAINT pk_processing_station PRIMARY KEY (processing_station_id);


--
-- Name: processor pk_processor; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor
    ADD CONSTRAINT pk_processor PRIMARY KEY (user_id);


--
-- Name: processor_processing_station pk_processor_processing_station; Type: CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor_processing_station
    ADD CONSTRAINT pk_processor_processing_station PRIMARY KEY (processor_processing_station_id);


--
-- Name: air_exposure_type_constant pk_air_exposure_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.air_exposure_type_constant
    ADD CONSTRAINT pk_air_exposure_type PRIMARY KEY (air_exposure_type_id);


--
-- Name: breed_constant pk_breed; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.breed_constant
    ADD CONSTRAINT pk_breed PRIMARY KEY (breed_id);


--
-- Name: chem_bio_constant pk_chem_bio; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.chem_bio_constant
    ADD CONSTRAINT pk_chem_bio PRIMARY KEY (chem_bio_id);


--
-- Name: cocoa_bean_grade_constant pk_cocoa_bean_grade; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.cocoa_bean_grade_constant
    ADD CONSTRAINT pk_cocoa_bean_grade PRIMARY KEY (cocoa_bean_grade_id);


--
-- Name: district_constant pk_district; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.district_constant
    ADD CONSTRAINT pk_district PRIMARY KEY (district_id);


--
-- Name: drying_facility_constant pk_drying_facility; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.drying_facility_constant
    ADD CONSTRAINT pk_drying_facility PRIMARY KEY (drying_facility_type_id);


--
-- Name: farm_activity_type_constant pk_farm_activity_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.farm_activity_type_constant
    ADD CONSTRAINT pk_farm_activity_type PRIMARY KEY (farm_activity_type_id);


--
-- Name: farm_constant pk_farm_constant; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.farm_constant
    ADD CONSTRAINT pk_farm_constant PRIMARY KEY (farm_id);


--
-- Name: fertilizer_constant pk_fertilizer; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.fertilizer_constant
    ADD CONSTRAINT pk_fertilizer PRIMARY KEY (fertilizer_id);


--
-- Name: fertilizer_application_stage_constant pk_fertilizer_application_stage; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.fertilizer_application_stage_constant
    ADD CONSTRAINT pk_fertilizer_application_stage PRIMARY KEY (fertilizer_application_stage_id);


--
-- Name: grade_constant pk_grade; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.grade_constant
    ADD CONSTRAINT pk_grade PRIMARY KEY (grade_id);


--
-- Name: hole_filler_material_constant pk_hole_filler_material; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.hole_filler_material_constant
    ADD CONSTRAINT pk_hole_filler_material PRIMARY KEY (hole_filler_material_id);


--
-- Name: hub_constant pk_hub_constant; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.hub_constant
    ADD CONSTRAINT pk_hub_constant PRIMARY KEY (hub_id);


--
-- Name: land_type_constant pk_land_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.land_type_constant
    ADD CONSTRAINT pk_land_type PRIMARY KEY (land_type_id);


--
-- Name: location_type_constant pk_location_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.location_type_constant
    ADD CONSTRAINT pk_location_type PRIMARY KEY (location_type_id);


--
-- Name: pest_disease_constant pk_pest_disease; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.pest_disease_constant
    ADD CONSTRAINT pk_pest_disease PRIMARY KEY (pest_disease_id);


--
-- Name: plot_constant pk_plot_constant; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.plot_constant
    ADD CONSTRAINT pk_plot_constant PRIMARY KEY (plot_id);


--
-- Name: processing_activity_type_constant pk_processing_activity_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.processing_activity_type_constant
    ADD CONSTRAINT pk_processing_activity_type PRIMARY KEY (processing_activity_type_id);


--
-- Name: processing_defect_constant pk_processing_defect; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.processing_defect_constant
    ADD CONSTRAINT pk_processing_defect PRIMARY KEY (processing_defect_id);


--
-- Name: processing_station_constant pk_processing_station_constant; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.processing_station_constant
    ADD CONSTRAINT pk_processing_station_constant PRIMARY KEY (processing_station_id);


--
-- Name: province_constant pk_province; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.province_constant
    ADD CONSTRAINT pk_province PRIMARY KEY (province_id);


--
-- Name: soil_type_constant pk_soil_type; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.soil_type_constant
    ADD CONSTRAINT pk_soil_type PRIMARY KEY (soil_type_id);


--
-- Name: subdistrict_constant pk_subdistrict; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.subdistrict_constant
    ADD CONSTRAINT pk_subdistrict PRIMARY KEY (subdistrict_id);


--
-- Name: tank_material_constant pk_tank_material; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.tank_material_constant
    ADD CONSTRAINT pk_tank_material PRIMARY KEY (tank_material_id);


--
-- Name: water_source_constant pk_water_source; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.water_source_constant
    ADD CONSTRAINT pk_water_source PRIMARY KEY (water_source_id);


--
-- Name: watering_system_constant pk_watering_system; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.watering_system_constant
    ADD CONSTRAINT pk_watering_system PRIMARY KEY (watering_system_id);


--
-- Name: weather_condition_constant pk_weather_condition; Type: CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.weather_condition_constant
    ADD CONSTRAINT pk_weather_condition PRIMARY KEY (weather_condition_id);


--
-- Name: researcher pk_researcher; Type: CONSTRAINT; Schema: research; Owner: -
--

ALTER TABLE ONLY research.researcher
    ADD CONSTRAINT pk_researcher PRIMARY KEY (user_id);


--
-- Name: file pk_file; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.file
    ADD CONSTRAINT pk_file PRIMARY KEY (file_id);


--
-- Name: geo pk_geo; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.geo
    ADD CONSTRAINT pk_geo PRIMARY KEY (geo_id);


--
-- Name: farm trg_sync_farm_constant; Type: TRIGGER; Schema: agriculture; Owner: -
--

CREATE TRIGGER trg_sync_farm_constant AFTER INSERT OR DELETE OR UPDATE ON agriculture.farm FOR EACH ROW EXECUTE FUNCTION ref.sync_farm_constant();


--
-- Name: plot trg_sync_plot_constant; Type: TRIGGER; Schema: agriculture; Owner: -
--

CREATE TRIGGER trg_sync_plot_constant AFTER INSERT OR DELETE OR UPDATE ON agriculture.plot FOR EACH ROW EXECUTE FUNCTION ref.sync_plot_constant();


--
-- Name: hub trg_sync_hub_constant; Type: TRIGGER; Schema: processing; Owner: -
--

CREATE TRIGGER trg_sync_hub_constant AFTER INSERT OR DELETE OR UPDATE ON processing.hub FOR EACH ROW EXECUTE FUNCTION ref.sync_hub_constant();


--
-- Name: processing_station trg_sync_processing_station_constant; Type: TRIGGER; Schema: processing; Owner: -
--

CREATE TRIGGER trg_sync_processing_station_constant AFTER INSERT OR DELETE OR UPDATE ON processing.processing_station FOR EACH ROW EXECUTE FUNCTION ref.sync_processing_station_constant();


--
-- Name: farm_activity_chemical fk_farm_activity_chemical_activity; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_chemical
    ADD CONSTRAINT fk_farm_activity_chemical_activity FOREIGN KEY (farm_activity_id) REFERENCES agriculture.farm_activity(farm_activity_id);


--
-- Name: farm_activity_chemical fk_farm_activity_chemical_chem_bio; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_chemical
    ADD CONSTRAINT fk_farm_activity_chemical_chem_bio FOREIGN KEY (chem_bio_id) REFERENCES ref.chem_bio_constant(chem_bio_id);


--
-- Name: farm_activity fk_farm_activity_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity
    ADD CONSTRAINT fk_farm_activity_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: farm_activity_fertilizer fk_farm_activity_fertilizer; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_fertilizer
    ADD CONSTRAINT fk_farm_activity_fertilizer FOREIGN KEY (fertilizer_id) REFERENCES ref.fertilizer_constant(fertilizer_id);


--
-- Name: farm_activity_fertilizer fk_farm_activity_fertilizer_activity; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity_fertilizer
    ADD CONSTRAINT fk_farm_activity_fertilizer_activity FOREIGN KEY (farm_activity_id) REFERENCES agriculture.farm_activity(farm_activity_id);


--
-- Name: farm_activity fk_farm_activity_plot; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity
    ADD CONSTRAINT fk_farm_activity_plot FOREIGN KEY (plot_id) REFERENCES agriculture.plot(plot_id);


--
-- Name: farm_activity fk_farm_activity_type; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_activity
    ADD CONSTRAINT fk_farm_activity_type FOREIGN KEY (farm_activity_type_id) REFERENCES ref.farm_activity_type_constant(farm_activity_type_id);


--
-- Name: farm fk_farm_district; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm
    ADD CONSTRAINT fk_farm_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: farm_economic_eval fk_farm_economic_eval_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_economic_eval
    ADD CONSTRAINT fk_farm_economic_eval_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: farm fk_farm_hub; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm
    ADD CONSTRAINT fk_farm_hub FOREIGN KEY (hub_id) REFERENCES processing.hub(hub_id);


--
-- Name: farm_initial_cost fk_farm_initial_cost_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_initial_cost
    ADD CONSTRAINT fk_farm_initial_cost_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: farm_initial_cost fk_farm_initial_cost_hole_filler_material; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_initial_cost
    ADD CONSTRAINT fk_farm_initial_cost_hole_filler_material FOREIGN KEY (hole_filler_material_id) REFERENCES ref.hole_filler_material_constant(hole_filler_material_id);


--
-- Name: farm_pest_disease_record fk_farm_pest_disease_record_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_pest_disease_record
    ADD CONSTRAINT fk_farm_pest_disease_record_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: farm_pest_disease_record fk_farm_pest_disease_record_pest_disease; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_pest_disease_record
    ADD CONSTRAINT fk_farm_pest_disease_record_pest_disease FOREIGN KEY (pest_disease_id) REFERENCES ref.pest_disease_constant(pest_disease_id);


--
-- Name: farm_pest_disease_record fk_farm_pest_disease_record_plot; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm_pest_disease_record
    ADD CONSTRAINT fk_farm_pest_disease_record_plot FOREIGN KEY (plot_id) REFERENCES agriculture.plot(plot_id);


--
-- Name: farm fk_farm_province; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm
    ADD CONSTRAINT fk_farm_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: farm fk_farm_subdistrict; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farm
    ADD CONSTRAINT fk_farm_subdistrict FOREIGN KEY (subdistrict_id) REFERENCES ref.subdistrict_constant(subdistrict_id);


--
-- Name: farmer fk_farmer_district; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer
    ADD CONSTRAINT fk_farmer_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: farmer_farm fk_farmer_farm_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer_farm
    ADD CONSTRAINT fk_farmer_farm_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: farmer_farm fk_farmer_farm_farmer; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer_farm
    ADD CONSTRAINT fk_farmer_farm_farmer FOREIGN KEY (farmer_id) REFERENCES agriculture.farmer(user_id);


--
-- Name: farmer fk_farmer_province; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer
    ADD CONSTRAINT fk_farmer_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: farmer fk_farmer_subdistrict; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer
    ADD CONSTRAINT fk_farmer_subdistrict FOREIGN KEY (subdistrict_id) REFERENCES ref.subdistrict_constant(subdistrict_id);


--
-- Name: farmer fk_farmer_user; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.farmer
    ADD CONSTRAINT fk_farmer_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: plot_breed fk_plot_breed_breed; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot_breed
    ADD CONSTRAINT fk_plot_breed_breed FOREIGN KEY (breed_id) REFERENCES ref.breed_constant(breed_id);


--
-- Name: plot_breed fk_plot_breed_plot; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot_breed
    ADD CONSTRAINT fk_plot_breed_plot FOREIGN KEY (plot_id) REFERENCES agriculture.plot(plot_id);


--
-- Name: plot fk_plot_farm; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT fk_plot_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: plot fk_plot_land_type; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT fk_plot_land_type FOREIGN KEY (land_type_id) REFERENCES ref.land_type_constant(land_type_id);


--
-- Name: plot fk_plot_soil_type; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT fk_plot_soil_type FOREIGN KEY (soil_type_id) REFERENCES ref.soil_type_constant(soil_type_id);


--
-- Name: plot fk_plot_water_source; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT fk_plot_water_source FOREIGN KEY (water_source_id) REFERENCES ref.water_source_constant(water_source_id);


--
-- Name: plot fk_plot_watering_system; Type: FK CONSTRAINT; Schema: agriculture; Owner: -
--

ALTER TABLE ONLY agriculture.plot
    ADD CONSTRAINT fk_plot_watering_system FOREIGN KEY (watering_system_id) REFERENCES ref.watering_system_constant(watering_system_id);


--
-- Name: role_permission fk_role_permission_permission; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role_permission
    ADD CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES auth.permission(permission_id);


--
-- Name: role_permission fk_role_permission_role; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.role_permission
    ADD CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES auth.role(role_id);


--
-- Name: user_role fk_user_role_role; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_role
    ADD CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES auth.role(role_id);


--
-- Name: user_role fk_user_role_user; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.user_role
    ADD CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: harvest_collection fk_harvest_collection_batch; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest_collection
    ADD CONSTRAINT fk_harvest_collection_batch FOREIGN KEY (batch_id) REFERENCES processing.batch(batch_id);


--
-- Name: harvest_collection fk_harvest_collection_harvest; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest_collection
    ADD CONSTRAINT fk_harvest_collection_harvest FOREIGN KEY (harvest_id) REFERENCES collection.harvest(harvest_id);


--
-- Name: harvest fk_harvest_farm; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest
    ADD CONSTRAINT fk_harvest_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: harvest_grade_detail fk_harvest_grade_detail_harvest; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest_grade_detail
    ADD CONSTRAINT fk_harvest_grade_detail_harvest FOREIGN KEY (harvest_id) REFERENCES collection.harvest(harvest_id);


--
-- Name: harvest fk_harvest_hub; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest
    ADD CONSTRAINT fk_harvest_hub FOREIGN KEY (hub_id) REFERENCES processing.hub(hub_id);


--
-- Name: harvest fk_harvest_plot; Type: FK CONSTRAINT; Schema: collection; Owner: -
--

ALTER TABLE ONLY collection.harvest
    ADD CONSTRAINT fk_harvest_plot FOREIGN KEY (plot_id) REFERENCES agriculture.plot(plot_id);


--
-- Name: assignment fk_assignment_task; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.assignment
    ADD CONSTRAINT fk_assignment_task FOREIGN KEY (task_id) REFERENCES form.task(task_id);


--
-- Name: assignment fk_assignment_user; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.assignment
    ADD CONSTRAINT fk_assignment_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: task_form fk_form_task; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.task_form
    ADD CONSTRAINT fk_form_task FOREIGN KEY (task_id) REFERENCES form.task(task_id);


--
-- Name: question fk_question_section; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.question
    ADD CONSTRAINT fk_question_section FOREIGN KEY (section_id) REFERENCES form.section(section_id);


--
-- Name: question_visibility fk_question_visibility_province; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.question_visibility
    ADD CONSTRAINT fk_question_visibility_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: question_visibility fk_question_visibility_question; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.question_visibility
    ADD CONSTRAINT fk_question_visibility_question FOREIGN KEY (question_id) REFERENCES form.question(question_id);


--
-- Name: response fk_response_user; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.response
    ADD CONSTRAINT fk_response_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: section fk_section_form; Type: FK CONSTRAINT; Schema: form; Owner: -
--

ALTER TABLE ONLY form.section
    ADD CONSTRAINT fk_section_form FOREIGN KEY (form_id) REFERENCES form.task_form(form_id);


--
-- Name: batch fk_batch_processing_station; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.batch
    ADD CONSTRAINT fk_batch_processing_station FOREIGN KEY (processing_station_id) REFERENCES processing.processing_station(processing_station_id);


--
-- Name: drying_batch fk_drying_batch_batch; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.drying_batch
    ADD CONSTRAINT fk_drying_batch_batch FOREIGN KEY (batch_id) REFERENCES processing.batch(batch_id);


--
-- Name: drying_batch fk_drying_batch_drying_facility; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.drying_batch
    ADD CONSTRAINT fk_drying_batch_drying_facility FOREIGN KEY (drying_facility_type_id) REFERENCES ref.drying_facility_constant(drying_facility_type_id);


--
-- Name: fermentation_batch fk_fermentation_batch_air_exposure_type; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.fermentation_batch
    ADD CONSTRAINT fk_fermentation_batch_air_exposure_type FOREIGN KEY (air_exposure_type_id) REFERENCES ref.air_exposure_type_constant(air_exposure_type_id);


--
-- Name: fermentation_batch fk_fermentation_batch_batch; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.fermentation_batch
    ADD CONSTRAINT fk_fermentation_batch_batch FOREIGN KEY (batch_id) REFERENCES processing.batch(batch_id);


--
-- Name: fermentation_batch fk_fermentation_batch_tank_material; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.fermentation_batch
    ADD CONSTRAINT fk_fermentation_batch_tank_material FOREIGN KEY (tank_material_id) REFERENCES ref.tank_material_constant(tank_material_id);


--
-- Name: hub_collector fk_hub_collector_hub; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub_collector
    ADD CONSTRAINT fk_hub_collector_hub FOREIGN KEY (hub_id) REFERENCES processing.hub(hub_id);


--
-- Name: hub fk_hub_district; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub
    ADD CONSTRAINT fk_hub_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: hub fk_hub_province; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub
    ADD CONSTRAINT fk_hub_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: hub fk_hub_subdistrict; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.hub
    ADD CONSTRAINT fk_hub_subdistrict FOREIGN KEY (subdistrict_id) REFERENCES ref.subdistrict_constant(subdistrict_id);


--
-- Name: processor_processing_station fk_pps_processing_station; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor_processing_station
    ADD CONSTRAINT fk_pps_processing_station FOREIGN KEY (processing_station_id) REFERENCES processing.processing_station(processing_station_id);


--
-- Name: processor_processing_station fk_pps_processor; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor_processing_station
    ADD CONSTRAINT fk_pps_processor FOREIGN KEY (processor_id) REFERENCES processing.processor(user_id);


--
-- Name: processing_record fk_processing_record_activity_type; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_record
    ADD CONSTRAINT fk_processing_record_activity_type FOREIGN KEY (processing_activity_type_id) REFERENCES ref.processing_activity_type_constant(processing_activity_type_id);


--
-- Name: processing_record fk_processing_record_batch; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_record
    ADD CONSTRAINT fk_processing_record_batch FOREIGN KEY (batch_id) REFERENCES processing.batch(batch_id);


--
-- Name: processing_record fk_processing_record_weather_condition; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_record
    ADD CONSTRAINT fk_processing_record_weather_condition FOREIGN KEY (weather_condition_id) REFERENCES ref.weather_condition_constant(weather_condition_id);


--
-- Name: processing_station fk_processing_station_district; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_station
    ADD CONSTRAINT fk_processing_station_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: processing_station fk_processing_station_hub; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_station
    ADD CONSTRAINT fk_processing_station_hub FOREIGN KEY (hub_id) REFERENCES processing.hub(hub_id);


--
-- Name: processing_station fk_processing_station_province; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_station
    ADD CONSTRAINT fk_processing_station_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: processing_station fk_processing_station_subdistrict; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processing_station
    ADD CONSTRAINT fk_processing_station_subdistrict FOREIGN KEY (subdistrict_id) REFERENCES ref.subdistrict_constant(subdistrict_id);


--
-- Name: processor fk_processor_district; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor
    ADD CONSTRAINT fk_processor_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: processor fk_processor_province; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor
    ADD CONSTRAINT fk_processor_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: processor fk_processor_subdistrict; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor
    ADD CONSTRAINT fk_processor_subdistrict FOREIGN KEY (subdistrict_id) REFERENCES ref.subdistrict_constant(subdistrict_id);


--
-- Name: processor fk_processor_user; Type: FK CONSTRAINT; Schema: processing; Owner: -
--

ALTER TABLE ONLY processing.processor
    ADD CONSTRAINT fk_processor_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: district_constant fk_district_province; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.district_constant
    ADD CONSTRAINT fk_district_province FOREIGN KEY (province_id) REFERENCES ref.province_constant(province_id);


--
-- Name: farm_constant fk_farm_constant_farm; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.farm_constant
    ADD CONSTRAINT fk_farm_constant_farm FOREIGN KEY (farm_id) REFERENCES agriculture.farm(farm_id);


--
-- Name: hub_constant fk_hub_constant_hub; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.hub_constant
    ADD CONSTRAINT fk_hub_constant_hub FOREIGN KEY (hub_id) REFERENCES processing.hub(hub_id);


--
-- Name: plot_constant fk_plot_constant_plot; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.plot_constant
    ADD CONSTRAINT fk_plot_constant_plot FOREIGN KEY (plot_id) REFERENCES agriculture.plot(plot_id);


--
-- Name: processing_station_constant fk_processing_station_constant_station; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.processing_station_constant
    ADD CONSTRAINT fk_processing_station_constant_station FOREIGN KEY (processing_station_id) REFERENCES processing.processing_station(processing_station_id);


--
-- Name: subdistrict_constant fk_subdistrict_district; Type: FK CONSTRAINT; Schema: ref; Owner: -
--

ALTER TABLE ONLY ref.subdistrict_constant
    ADD CONSTRAINT fk_subdistrict_district FOREIGN KEY (district_id) REFERENCES ref.district_constant(district_id);


--
-- Name: researcher fk_researcher_user; Type: FK CONSTRAINT; Schema: research; Owner: -
--

ALTER TABLE ONLY research.researcher
    ADD CONSTRAINT fk_researcher_user FOREIGN KEY (user_id) REFERENCES auth.user_account(user_id);


--
-- Name: file fk_file_uploaded_by; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.file
    ADD CONSTRAINT fk_file_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES auth.user_account(user_id);


--
-- Name: geo fk_geo_uploaded_by; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.geo
    ADD CONSTRAINT fk_geo_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES auth.user_account(user_id);


--
-- PostgreSQL database dump complete
--


