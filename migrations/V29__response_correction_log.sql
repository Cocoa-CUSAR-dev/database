-- US2-8 (docs-and-plan#173): a persistent audit trail of every field a
-- researcher corrects on a submission, so nothing is silently overwritten.
-- The review/correct endpoint (#217) previously only wrote a stopgap log line;
-- this is the durable record that replaces it (one row per corrected field).
--
-- old_value / new_value are stored as text (the displayed form of the answer
-- value) -- an audit trail is read by a human, and the stored kind is already
-- preserved on form.response.answer itself.
--
-- Numbered V29: V27 is reserved by sec/sso-hardening (not yet on dev) and V28
-- adds the researcher update permission.

CREATE TABLE form.response_correction_log (
    correction_log_id uuid NOT NULL DEFAULT gen_random_uuid(),
    response_id uuid NOT NULL,
    field_name character varying NOT NULL,
    old_value text,
    new_value text,
    corrected_by uuid NOT NULL,
    reason text,
    corrected_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_response_correction_log PRIMARY KEY (correction_log_id),
    CONSTRAINT fk_response_correction_log_response FOREIGN KEY (response_id) REFERENCES form.response (response_id),
    CONSTRAINT fk_response_correction_log_user FOREIGN KEY (corrected_by) REFERENCES auth.user_account (user_id)
);

-- Hot path: show the correction history of one submission.
CREATE INDEX idx_response_correction_log_response ON form.response_correction_log (response_id);
