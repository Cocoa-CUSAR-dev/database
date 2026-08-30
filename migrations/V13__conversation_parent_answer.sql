-- CB-6 (docs/plans/chatbot-child-handler-design.md): the 5 previously-
-- blocked handlers (farm_activity_fertilizer, farm_activity_chemical,
-- harvest_grade_detail, fermentation_batch, drying_batch) need a parent
-- row ID that isn't part of the form's own questions -- the chatbot asks
-- for it as one extra picker step before the real questions, but can't
-- store that answer in chat.conversation_answer: that table's question_id
-- has a real FK to form.question, and the picker step has no corresponding
-- row there (it's synthesized client-side, not part of any form
-- definition -- see src/line/parent_picker.py). This column holds it
-- instead, as a single JSONB pair ({"field_name": ..., "value": ...})
-- merged into the submission payload at confirm time -- see
-- src/conversation/service.py's confirm_conversation.

ALTER TABLE chat.conversation
    ADD COLUMN IF NOT EXISTS parent_answer JSONB;
