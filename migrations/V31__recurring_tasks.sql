-- US4-4 (docs-and-plan#233): a task that is re-assigned automatically every
-- period (#234).
--
-- Model: the task a researcher creates is round #1 AND the template. A
-- recurrence row says how it repeats; each later round is a fresh copy of
-- the template (form.task + task_form + sections + questions) created by a
-- job, with its own open_at/close_at.
--
--   form.task_recurrence  how a template repeats (DAILY, or WEEKLY on chosen
--                         weekdays) and until when
--   form.task.recurrence_id / period_date
--                         which recurrence a round belongs to and which day
--                         it is the round for. The UNIQUE index on the pair
--                         is what stops a round being created twice, however
--                         often the job runs -- the guarantee lives in the
--                         database, not in the job's memory (same reasoning
--                         as notify.reminder_log, ADR 0006).
--   form.task_recipient   who a task is aimed at: same ROLE / USER shape as
--                         notify.reminder_recipient (V26), but per task.
--                         Rules are kept on the template; the job turns them
--                         into one form.assignment row per person for each
--                         round it creates.
--
-- Visibility rule (applied by the task lists in mobile-backend and the
-- chatbot, NOT here): a task with NO form.assignment rows is shown to
-- everyone, exactly as today; a task that has assignment rows is shown only
-- to those people. That is deliberate, like V26's "no rows = old behaviour":
-- every task that exists now keeps working, nothing is backfilled.
--
-- Periods are calendar days in Asia/Bangkok (the farmers' day). weekdays use
-- ISO numbering: 1 = Monday ... 7 = Sunday.

CREATE TABLE form.task_recurrence (
    recurrence_id uuid NOT NULL DEFAULT gen_random_uuid(),
    template_task_id uuid NOT NULL,
    frequency character varying NOT NULL,
    weekdays smallint[],
    start_date date NOT NULL,
    until_date date,
    is_active boolean NOT NULL DEFAULT true,
    created_by uuid NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_task_recurrence PRIMARY KEY (recurrence_id),
    CONSTRAINT uq_task_recurrence_template UNIQUE (template_task_id),
    CONSTRAINT fk_task_recurrence_template FOREIGN KEY (template_task_id)
        REFERENCES form.task (task_id),
    CONSTRAINT fk_task_recurrence_created_by FOREIGN KEY (created_by)
        REFERENCES auth.user_account (user_id),
    CONSTRAINT ck_task_recurrence_frequency CHECK (frequency IN ('DAILY', 'WEEKLY')),
    -- DAILY has no weekday list; WEEKLY needs at least one valid weekday.
    CONSTRAINT ck_task_recurrence_weekdays CHECK (
        (frequency = 'DAILY' AND weekdays IS NULL)
        OR (
            frequency = 'WEEKLY'
            AND weekdays IS NOT NULL
            AND cardinality(weekdays) BETWEEN 1 AND 7
            AND weekdays <@ ARRAY[1, 2, 3, 4, 5, 6, 7]::smallint[]
        )
    ),
    CONSTRAINT ck_task_recurrence_until CHECK (until_date IS NULL OR until_date >= start_date)
);

CREATE INDEX idx_task_recurrence_created_by ON form.task_recurrence (created_by);
-- The job only ever looks at recurrences that are still running.
CREATE INDEX idx_task_recurrence_active ON form.task_recurrence (is_active) WHERE is_active;

ALTER TABLE form.task
    ADD COLUMN recurrence_id uuid,
    ADD COLUMN period_date date,
    ADD CONSTRAINT fk_task_recurrence FOREIGN KEY (recurrence_id)
        REFERENCES form.task_recurrence (recurrence_id),
    -- A round has both or neither: a recurrence without a day (or the other
    -- way round) would escape the uniqueness guarantee below.
    ADD CONSTRAINT ck_task_period CHECK ((recurrence_id IS NULL) = (period_date IS NULL));

-- One round per recurrence per day. Plain one-off tasks (recurrence_id NULL)
-- are not affected.
CREATE UNIQUE INDEX uq_task_recurrence_period
    ON form.task (recurrence_id, period_date)
    WHERE recurrence_id IS NOT NULL;

CREATE TABLE form.task_recipient (
    recipient_id uuid NOT NULL DEFAULT gen_random_uuid(),
    task_id uuid NOT NULL,
    recipient_type character varying NOT NULL,
    role_id uuid,
    user_id uuid,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_task_recipient PRIMARY KEY (recipient_id),
    CONSTRAINT fk_task_recipient_task FOREIGN KEY (task_id)
        REFERENCES form.task (task_id) ON DELETE CASCADE,
    CONSTRAINT fk_task_recipient_role FOREIGN KEY (role_id)
        REFERENCES auth.role (role_id),
    CONSTRAINT fk_task_recipient_user FOREIGN KEY (user_id)
        REFERENCES auth.user_account (user_id),
    CONSTRAINT ck_task_recipient_type CHECK (recipient_type IN ('ROLE', 'USER')),
    -- Exactly the column matching the type is filled -- a half-filled row
    -- would silently match nobody.
    CONSTRAINT ck_task_recipient_target CHECK (
        (recipient_type = 'ROLE' AND role_id IS NOT NULL AND user_id IS NULL)
        OR (recipient_type = 'USER' AND user_id IS NOT NULL AND role_id IS NULL)
    ),
    CONSTRAINT uq_task_recipient_role UNIQUE (task_id, role_id),
    CONSTRAINT uq_task_recipient_user UNIQUE (task_id, user_id)
);

CREATE INDEX idx_task_recipient_task_id ON form.task_recipient (task_id);
CREATE INDEX idx_task_recipient_user_id ON form.task_recipient (user_id);
CREATE INDEX idx_task_recipient_role_id ON form.task_recipient (role_id);

-- form.assignment has existed since V1 but nothing wrote to it (0 rows on the
-- live database when this was written), so this cannot fail on existing data.
-- One row per person per task lets the job insert with ON CONFLICT DO NOTHING
-- and keeps a person from being listed twice on the same task.
CREATE UNIQUE INDEX uq_assignment_task_user ON form.assignment (task_id, user_id);
