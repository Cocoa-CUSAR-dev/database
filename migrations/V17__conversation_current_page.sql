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
