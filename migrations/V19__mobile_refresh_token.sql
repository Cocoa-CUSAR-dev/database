-- GO-3: the mobile backend's JWT is delivered as a cookie with no
-- refresh-token flow, pushing toward long-lived static tokens as a
-- workaround. This table backs a real refresh flow -- same shape as the
-- existing auth.line_link_code (single-use, expiring, DB-backed token),
-- since that's the established pattern in this schema for "a secret the
-- server hands out, then validates on a later request" rather than a
-- second self-contained JWT.
--
-- Only the hash is stored, not the raw token -- a DB leak shouldn't hand
-- out working session credentials directly. used_at supports rotation
-- (an old refresh token is marked used the moment it's exchanged, so a
-- stolen-and-replayed one is caught); revoked_at is separate from used_at
-- so a token can be revoked (e.g. logout) without pretending it was
-- redeemed for a new session.
CREATE TABLE auth.refresh_token (
    refresh_token_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    token_hash character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used_at timestamp without time zone,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_refresh_token PRIMARY KEY (refresh_token_id),
    CONSTRAINT fk_refresh_token_user FOREIGN KEY (user_id) REFERENCES auth.user_account (user_id),
    CONSTRAINT uq_refresh_token_hash UNIQUE (token_hash)
);

CREATE INDEX idx_refresh_token_user_id ON auth.refresh_token (user_id);

-- Partial index: the hot lookup path (validating a presented token) only
-- ever cares about not-yet-used, not-yet-revoked rows.
CREATE INDEX idx_refresh_token_hash_active ON auth.refresh_token (token_hash)
    WHERE used_at IS NULL AND revoked_at IS NULL;
