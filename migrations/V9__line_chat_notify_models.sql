-- ADR 0005: LINE account linking, chatbot conversations, reminder
-- notifications, and form versioning.
--
-- Verified before writing: V1-V8 already create all FK targets used below.
-- Existing form.task_form rows can default to version 1 / active.
-- form.response.task_form_id is nullable for old responses because V1-V8 have
-- no reliable historical form-version value to backfill.

CREATE SCHEMA IF NOT EXISTS chat;
CREATE SCHEMA IF NOT EXISTS notify;

ALTER TABLE form.task_form
    ADD COLUMN version integer NOT NULL DEFAULT 1,
    ADD COLUMN is_active boolean NOT NULL DEFAULT true;

ALTER TABLE form.response
    ADD COLUMN task_form_id uuid,
    ADD CONSTRAINT fk_response_task_form FOREIGN KEY (task_form_id) REFERENCES form.task_form (form_id);

CREATE INDEX idx_response_task_form_id ON form.response (task_form_id);

CREATE TABLE auth.line_identity (
    line_identity_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    line_user_id character varying NOT NULL,
    display_name character varying,
    linked_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_line_identity PRIMARY KEY (line_identity_id),
    CONSTRAINT uq_line_identity_user UNIQUE (user_id),
    CONSTRAINT uq_line_identity_line_user_id UNIQUE (line_user_id),
    CONSTRAINT fk_line_identity_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id)
);

CREATE TABLE auth.line_link_code (
    link_code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    code character varying(6) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used_at timestamp without time zone,
    CONSTRAINT pk_line_link_code PRIMARY KEY (link_code_id),
    CONSTRAINT fk_line_link_code_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id)
);

CREATE INDEX idx_line_link_code_user_id ON auth.line_link_code (user_id);
CREATE INDEX idx_line_link_code_code_active ON auth.line_link_code (code) WHERE used_at IS NULL;

CREATE TABLE chat.conversation (
    conversation_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    task_id uuid NOT NULL,
    task_form_id uuid NOT NULL,
    status character varying NOT NULL DEFAULT 'active',
    current_question_id uuid,
    CONSTRAINT pk_chat_conversation PRIMARY KEY (conversation_id),
    CONSTRAINT fk_chat_conversation_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id),
    CONSTRAINT fk_chat_conversation_task FOREIGN KEY (task_id) REFERENCES form.task (task_id),
    CONSTRAINT fk_chat_conversation_task_form FOREIGN KEY (task_form_id) REFERENCES form.task_form (form_id),
    CONSTRAINT fk_chat_conversation_current_question FOREIGN KEY (current_question_id) REFERENCES form.question (question_id),
    CONSTRAINT ck_chat_conversation_status CHECK (status IN ('active', 'paused', 'completed'))
);

CREATE INDEX idx_chat_conversation_user_id ON chat.conversation (user_id);
CREATE INDEX idx_chat_conversation_task_id ON chat.conversation (task_id);
CREATE INDEX idx_chat_conversation_task_form_id ON chat.conversation (task_form_id);
CREATE INDEX idx_chat_conversation_current_question_id ON chat.conversation (current_question_id);

CREATE TABLE chat.conversation_answer (
    conversation_answer_id uuid NOT NULL DEFAULT gen_random_uuid(),
    conversation_id uuid NOT NULL,
    question_id uuid NOT NULL,
    answer jsonb,
    source character varying NOT NULL,
    CONSTRAINT pk_chat_conversation_answer PRIMARY KEY (conversation_answer_id),
    CONSTRAINT fk_conversation_answer_conversation FOREIGN KEY (conversation_id) REFERENCES chat.conversation (conversation_id),
    CONSTRAINT fk_conversation_answer_question FOREIGN KEY (question_id) REFERENCES form.question (question_id),
    CONSTRAINT ck_conversation_answer_source CHECK (source IN ('guided_flow', 'llm_extracted'))
);

CREATE INDEX idx_conversation_answer_conversation_id ON chat.conversation_answer (conversation_id);
CREATE INDEX idx_conversation_answer_question_id ON chat.conversation_answer (question_id);

CREATE TABLE notify.reminder_schedule (
    schedule_id uuid NOT NULL DEFAULT gen_random_uuid(),
    task_id uuid NOT NULL,
    cadence character varying NOT NULL,
    time_of_day time without time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_by uuid NOT NULL,
    CONSTRAINT pk_reminder_schedule PRIMARY KEY (schedule_id),
    CONSTRAINT fk_reminder_schedule_task FOREIGN KEY (task_id) REFERENCES form.task (task_id),
    CONSTRAINT fk_reminder_schedule_created_by FOREIGN KEY (created_by) REFERENCES auth.user_account (user_id)
);

CREATE INDEX idx_reminder_schedule_task_id ON notify.reminder_schedule (task_id);
CREATE INDEX idx_reminder_schedule_created_by ON notify.reminder_schedule (created_by);

CREATE TABLE notify.reminder_log (
    log_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    task_id uuid NOT NULL,
    sent_at timestamp without time zone NOT NULL DEFAULT now(),
    channel character varying NOT NULL,
    status character varying NOT NULL,
    CONSTRAINT pk_reminder_log PRIMARY KEY (log_id),
    CONSTRAINT fk_reminder_log_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id),
    CONSTRAINT fk_reminder_log_task FOREIGN KEY (task_id) REFERENCES form.task (task_id),
    CONSTRAINT ck_reminder_log_channel CHECK (channel IN ('push', 'rich_menu_fallback'))
);

CREATE INDEX idx_reminder_log_user_id ON notify.reminder_log (user_id);
CREATE INDEX idx_reminder_log_task_id ON notify.reminder_log (task_id);
