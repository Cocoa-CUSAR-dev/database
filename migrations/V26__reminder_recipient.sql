-- Who a reminder schedule is aimed at (issue #147).
--
-- One row = one targeting rule for a notify.reminder_schedule, and a
-- schedule can have several (e.g. "every farmer" + "this one processor").
-- Two kinds of rule:
--   ROLE -> everyone holding that role (auth.user_role), via role_id
--   USER -> exactly that one person, via user_id (even if they do not hold
--           the role a sibling ROLE rule names)
--
-- A schedule with NO rows here keeps the old behavior: remind everyone who
-- still owes the task. That is deliberate so every schedule created before
-- this migration is unaffected -- nothing is backfilled.
--
-- The chatbot's reminder job still narrows these rules down to people who
-- are LINE-linked and have not submitted yet (src/reminders/queries.py);
-- this table only says who is *eligible*.

CREATE TABLE notify.reminder_recipient (
    recipient_id uuid NOT NULL DEFAULT gen_random_uuid(),
    schedule_id uuid NOT NULL,
    recipient_type character varying NOT NULL,
    role_id uuid,
    user_id uuid,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_reminder_recipient PRIMARY KEY (recipient_id),
    CONSTRAINT fk_reminder_recipient_schedule FOREIGN KEY (schedule_id)
        REFERENCES notify.reminder_schedule (schedule_id) ON DELETE CASCADE,
    CONSTRAINT fk_reminder_recipient_role FOREIGN KEY (role_id)
        REFERENCES auth.role (role_id),
    CONSTRAINT fk_reminder_recipient_user FOREIGN KEY (user_id)
        REFERENCES auth.user_account (user_id),
    CONSTRAINT ck_reminder_recipient_type CHECK (recipient_type IN ('ROLE', 'USER')),
    -- Exactly the column matching the type is filled, the other is NULL --
    -- rules out half-filled rows that would silently match nobody.
    CONSTRAINT ck_reminder_recipient_target CHECK (
        (recipient_type = 'ROLE' AND role_id IS NOT NULL AND user_id IS NULL)
        OR (recipient_type = 'USER' AND user_id IS NOT NULL AND role_id IS NULL)
    ),
    CONSTRAINT uq_reminder_recipient_role UNIQUE (schedule_id, role_id),
    CONSTRAINT uq_reminder_recipient_user UNIQUE (schedule_id, user_id)
);

CREATE INDEX idx_reminder_recipient_schedule_id ON notify.reminder_recipient (schedule_id);
CREATE INDEX idx_reminder_recipient_user_id ON notify.reminder_recipient (user_id);
CREATE INDEX idx_reminder_recipient_role_id ON notify.reminder_recipient (role_id);
