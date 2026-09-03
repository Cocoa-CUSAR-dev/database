-- CB-10: chat.conversation and chat.conversation_answer have no way to
-- know when a conversation happened without cross-referencing
-- form.response.submitted_at, which only exists once a submission
-- actually succeeds (CB-1 fixed most of those failures, but conversations
-- that never reach confirmation -- abandoned, paused indefinitely -- still
-- have no timestamp anywhere).
--
-- No set_updated_at()-style trigger exists anywhere in this schema (only
-- the ref.sync_*_constant triggers, which mirror a different concern) --
-- every other table's updated_at column (V1 baseline) is a plain
-- DEFAULT now() column maintained by the application layer on writes, so
-- these two follow that same convention rather than introducing a new
-- trigger pattern for just these two tables.

ALTER TABLE chat.conversation
    ADD COLUMN created_at timestamp without time zone DEFAULT now() NOT NULL,
    ADD COLUMN updated_at timestamp without time zone DEFAULT now() NOT NULL;

ALTER TABLE chat.conversation_answer
    ADD COLUMN created_at timestamp without time zone DEFAULT now() NOT NULL,
    ADD COLUMN updated_at timestamp without time zone DEFAULT now() NOT NULL;
