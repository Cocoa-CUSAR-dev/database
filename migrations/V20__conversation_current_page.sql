-- Renumbered from V17. This landed as V17__conversation_current_page.sql
-- via the pagination PR at the same time a separate branch landed
-- V17__chat_conversation_timestamps.sql -- two migrations sharing a
-- version, which Flyway refuses outright ("Found more than one migration
-- with version 17"). Each branch passed migrate-check on its own; the
-- collision only exists once both are merged, so nothing caught it.
--
-- The timestamps one keeps V17 because the dev database's
-- flyway_schema_history already records V17 as timestamps. This one was
-- applied to dev by hand and never recorded, so moving it changes no
-- history anywhere. It stays safe to run on a database that already has the
-- column because it was always written IF NOT EXISTS: a no-op on dev,
-- creates the column on a fresh database.
--
-- Quick Reply pagination: a farmer picking from a real OPTION field with
-- more choices than fit in one LINE Quick Reply message (13 items, minus
-- whatever's already reserved for pause/skip/nav buttons -- see chatbot's
-- src/conversation/service.py) now pages through them instead of silently
-- losing the overflow. This column tracks which page of the CURRENTLY open
-- question the farmer is viewing.
--
-- Reset to 0 whenever current_question_id changes to a genuinely different
-- question (chatbot's _advance_to helper) -- it's only ever meaningful
-- relative to whichever question is currently open.

ALTER TABLE chat.conversation
    ADD COLUMN IF NOT EXISTS current_page INTEGER NOT NULL DEFAULT 0;
