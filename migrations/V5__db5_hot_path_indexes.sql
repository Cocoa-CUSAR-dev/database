-- DB-5: zero secondary indexes anywhere in the original schema. This adds
-- an index for every FK column that lacked one (Postgres does not
-- auto-index FK columns the way it does PKs), plus a GiST index for
-- spatial queries on storage.geo.geom.
--
-- Generated from a live query against the actual FK/index catalog, not
-- hand-typed -- see the query in this repo's README history if it needs
-- regenerating later.


CREATE INDEX idx_farm_district_id ON agriculture.farm (district_id);
CREATE INDEX idx_farm_hub_id ON agriculture.farm (hub_id);
CREATE INDEX idx_farm_province_id ON agriculture.farm (province_id);
CREATE INDEX idx_farm_subdistrict_id ON agriculture.farm (subdistrict_id);
CREATE INDEX idx_farm_activity_farm_activity_type_id ON agriculture.farm_activity (farm_activity_type_id);
CREATE INDEX idx_farm_activity_farm_id ON agriculture.farm_activity (farm_id);
CREATE INDEX idx_farm_activity_plot_id ON agriculture.farm_activity (plot_id);
CREATE INDEX idx_farm_economic_eval_farm_id ON agriculture.farm_economic_eval (farm_id);
CREATE INDEX idx_farm_initial_cost_farm_id ON agriculture.farm_initial_cost (farm_id);
CREATE INDEX idx_farm_initial_cost_hole_filler_material_id ON agriculture.farm_initial_cost (hole_filler_material_id);
CREATE INDEX idx_farm_pest_disease_record_farm_id ON agriculture.farm_pest_disease_record (farm_id);
CREATE INDEX idx_farm_pest_disease_record_pest_disease_id ON agriculture.farm_pest_disease_record (pest_disease_id);
CREATE INDEX idx_farm_pest_disease_record_plot_id ON agriculture.farm_pest_disease_record (plot_id);
CREATE INDEX idx_farmer_district_id ON agriculture.farmer (district_id);
CREATE INDEX idx_farmer_province_id ON agriculture.farmer (province_id);
CREATE INDEX idx_farmer_subdistrict_id ON agriculture.farmer (subdistrict_id);
CREATE INDEX idx_farmer_farm_farm_id ON agriculture.farmer_farm (farm_id);
CREATE INDEX idx_farmer_farm_farmer_id ON agriculture.farmer_farm (farmer_id);
CREATE INDEX idx_plot_farm_id ON agriculture.plot (farm_id);
CREATE INDEX idx_plot_land_type_id ON agriculture.plot (land_type_id);
CREATE INDEX idx_plot_soil_type_id ON agriculture.plot (soil_type_id);
CREATE INDEX idx_plot_water_source_id ON agriculture.plot (water_source_id);
CREATE INDEX idx_plot_watering_system_id ON agriculture.plot (watering_system_id);
CREATE INDEX idx_plot_breed_breed_id ON agriculture.plot_breed (breed_id);
CREATE INDEX idx_plot_breed_plot_id ON agriculture.plot_breed (plot_id);
CREATE INDEX idx_harvest_farm_id ON collection.harvest (farm_id);
CREATE INDEX idx_harvest_hub_id ON collection.harvest (hub_id);
CREATE INDEX idx_harvest_plot_id ON collection.harvest (plot_id);
CREATE INDEX idx_harvest_collection_batch_id ON collection.harvest_collection (batch_id);
CREATE INDEX idx_harvest_collection_harvest_id ON collection.harvest_collection (harvest_id);
CREATE INDEX idx_assignment_task_id ON form.assignment (task_id);
CREATE INDEX idx_assignment_user_id ON form.assignment (user_id);
CREATE INDEX idx_question_section_id ON form.question (section_id);
CREATE INDEX idx_question_visibility_province_id ON form.question_visibility (province_id);
CREATE INDEX idx_question_visibility_question_id ON form.question_visibility (question_id);
CREATE INDEX idx_response_user_id ON form.response (user_id);
CREATE INDEX idx_section_form_id ON form.section (form_id);
CREATE INDEX idx_task_form_task_id ON form.task_form (task_id);
CREATE INDEX idx_batch_processing_station_id ON processing.batch (processing_station_id);
CREATE INDEX idx_drying_batch_drying_facility_type_id ON processing.drying_batch (drying_facility_type_id);
CREATE INDEX idx_fermentation_batch_air_exposure_type_id ON processing.fermentation_batch (air_exposure_type_id);
CREATE INDEX idx_fermentation_batch_tank_material_id ON processing.fermentation_batch (tank_material_id);
CREATE INDEX idx_hub_district_id ON processing.hub (district_id);
CREATE INDEX idx_hub_province_id ON processing.hub (province_id);
CREATE INDEX idx_hub_subdistrict_id ON processing.hub (subdistrict_id);
CREATE INDEX idx_hub_collector_hub_id ON processing.hub_collector (hub_id);
CREATE INDEX idx_processing_record_batch_id ON processing.processing_record (batch_id);
CREATE INDEX idx_processing_record_processing_activity_type_id ON processing.processing_record (processing_activity_type_id);
CREATE INDEX idx_processing_record_weather_condition_id ON processing.processing_record (weather_condition_id);
CREATE INDEX idx_processing_station_district_id ON processing.processing_station (district_id);
CREATE INDEX idx_processing_station_hub_id ON processing.processing_station (hub_id);
CREATE INDEX idx_processing_station_province_id ON processing.processing_station (province_id);
CREATE INDEX idx_processing_station_subdistrict_id ON processing.processing_station (subdistrict_id);
CREATE INDEX idx_processor_district_id ON processing.processor (district_id);
CREATE INDEX idx_processor_province_id ON processing.processor (province_id);
CREATE INDEX idx_processor_subdistrict_id ON processing.processor (subdistrict_id);
CREATE INDEX idx_processor_processing_station_processing_station_id ON processing.processor_processing_station (processing_station_id);
CREATE INDEX idx_processor_processing_station_processor_id ON processing.processor_processing_station (processor_id);
CREATE INDEX idx_district_constant_province_id ON ref.district_constant (province_id);
CREATE INDEX idx_subdistrict_constant_district_id ON ref.subdistrict_constant (district_id);
CREATE INDEX idx_file_uploaded_by ON storage.file (uploaded_by);
CREATE INDEX idx_geo_uploaded_by ON storage.geo (uploaded_by);

-- GiST index for spatial queries on the geometry column.
CREATE INDEX idx_geo_geom ON storage.geo USING GIST (geom);

