-- DB-4: three geo_id columns pointing at storage.geo with no FK enforcing it.
--
-- Verified before writing: zero orphaned geo_id values across all three
-- tables today -- safe to add without cleanup.

ALTER TABLE agriculture.farm
    ADD CONSTRAINT fk_farm_geo FOREIGN KEY (geo_id) REFERENCES storage.geo (geo_id);

ALTER TABLE processing.hub
    ADD CONSTRAINT fk_hub_geo FOREIGN KEY (geo_id) REFERENCES storage.geo (geo_id);

ALTER TABLE processing.processing_station
    ADD CONSTRAINT fk_processing_station_geo FOREIGN KEY (geo_id) REFERENCES storage.geo (geo_id);
