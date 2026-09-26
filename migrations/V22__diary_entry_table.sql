-- US2-6 : daily diary generated from a farmer's own
-- submitted answers -- one row per farmer per calendar day, holding the
-- already-generated (template + LLM-polished) Thai prose text.
--
-- Generated once, at submit time (web-backend's diary-generation endpoint),
-- not re-generated on every page view -- keeps wording stable across
-- repeat reads and avoids paying for an LLM call per view. A farmer
-- submitting a second form the same day re-generates the whole day's text
-- (upsert on (user_id, entry_date)), since the diary summarizes everything
-- filled that day, not just the latest submission.
--
-- Deliberately NOT backfilled for days before this feature existed --
-- web-app's history page falls back to the raw form-list view for any
-- date with no row here.

CREATE TABLE form.diary_entry (
    diary_entry_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    entry_date date NOT NULL,
    diary_text text NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_diary_entry PRIMARY KEY (diary_entry_id),
    CONSTRAINT fk_diary_entry_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id),
    CONSTRAINT uq_diary_entry_user_date UNIQUE (user_id, entry_date)
);

CREATE INDEX idx_diary_entry_user_id ON form.diary_entry (user_id);
