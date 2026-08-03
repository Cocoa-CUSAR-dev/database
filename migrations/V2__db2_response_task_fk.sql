-- DB-2: form.response.task_log_id has no FK, so an answer could point to a
-- deleted/nonexistent task. Now a hard dependency for the chatbot seam
-- (ADR 0001), not just a standalone weak point.
--
-- Verified before writing: no existing form.response rows point at a
-- nonexistent form.task -- safe to add without cleanup.

ALTER TABLE form.response
    ADD CONSTRAINT fk_response_task FOREIGN KEY (task_log_id) REFERENCES form.task (task_id);
