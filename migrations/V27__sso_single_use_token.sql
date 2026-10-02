-- US3-2 (docs-and-plan#125, F3): SSO mint tokens must be single-use.
--
-- The SSO deep link rides in a LINE push message that can be screenshotted or
-- forwarded, so a short TTL alone (SsoService.TOKEN_TTL_MS) still lets anyone
-- holding the token redeem it repeatedly within that window. This table lets
-- web-backend's /auth/sso/exchange record each redeemed token's `jti` and
-- refuse a `jti` it has already seen, making every mint token good for exactly
-- one exchange.
--
-- Verified before writing: `auth` schema already exists (V9) and pgcrypto is
-- available (V1 baseline). Additive only -- no existing table or row touched,
-- so this cannot fail against current data.

CREATE TABLE auth.sso_used_token (
    -- The token's own `jti` claim (a UUID minted per SSO token), not a
    -- surrogate key -- the uniqueness we enforce is exactly "this token".
    jti uuid NOT NULL,
    used_at timestamp without time zone NOT NULL DEFAULT now(),
    -- The token's own expiry. A used row is only meaningful until the token
    -- would have expired on its own anyway, so a later janitor can safely
    -- purge rows past this instant.
    expires_at timestamp without time zone NOT NULL,
    CONSTRAINT pk_sso_used_token PRIMARY KEY (jti)
);

CREATE INDEX idx_sso_used_token_expires_at ON auth.sso_used_token (expires_at);
