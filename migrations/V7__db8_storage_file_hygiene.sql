-- DB-8: storage.file has no created_at at all, and no index supporting its
-- polymorphic (table_name, ref_id) lookup pattern -- every "find the files
-- attached to this record" query is a sequential scan.
--
-- Verified before writing: storage.file has zero rows today, so adding a
-- NOT NULL column with a default is safe either way -- no backfill needed.

ALTER TABLE storage.file
    ADD COLUMN created_at timestamp without time zone NOT NULL DEFAULT now();

CREATE INDEX idx_file_table_name_ref_id ON storage.file (table_name, ref_id);
