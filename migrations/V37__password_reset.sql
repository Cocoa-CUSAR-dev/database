-- Forgot password (docs-and-plan#321): a short code that backend-hub sends to
-- the person through LINE or email, and the permission an admin needs to reset
-- someone else's password.
--
-- The code is a 6-digit number, valid for 15 minutes. Only an HMAC of it is
-- stored (never the code), with a count of wrong tries so a code can be
-- guessed at most a few times. A row is "used" (used_at set) once the password
-- was reset with it, or when a newer code replaced it. Rows are kept for a
-- while so the hub can limit how many codes one account may ask for per hour.
--
-- update:password:any
--     -> admin only: set a temporary password for any account when the person
--        has no email and no LINE to receive a code. The account then has to
--        pick its own password at the next sign-in (must_reset_password).
--        Not granted to researcher: a researcher who could reset any password
--        could reset an admin's and take the account over.
--
-- Apply this before backend-hub is deployed with the forgot-password routes.
--
-- Idempotent, same pattern as V35/V36: only creates what is missing.

CREATE TABLE IF NOT EXISTS auth.password_reset_code (
    password_reset_code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    code_hash character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    attempts integer NOT NULL DEFAULT 0,
    used_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_password_reset_code PRIMARY KEY (password_reset_code_id),
    CONSTRAINT fk_password_reset_code_user FOREIGN KEY (user_id)
        REFERENCES auth.user_account (user_id) ON DELETE CASCADE
);

-- Hot paths: the newest live code of one account, and the count of codes
-- asked for in the last hour.
CREATE INDEX IF NOT EXISTS idx_password_reset_code_user_created
    ON auth.password_reset_code (user_id, created_at DESC);

INSERT INTO auth.permission (permission_key, description)
SELECT v.key, v.description
FROM (VALUES
    ('update:password:any', 'Set a temporary password for any account')
) AS v(key, description)
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission p WHERE p.permission_key = v.key
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('admin', 'update:password:any')
) AS g(role_name, key)
JOIN auth.role r ON r.role_name = g.role_name
JOIN auth.permission p ON p.permission_key = g.key
WHERE NOT EXISTS (
    SELECT 1 FROM auth.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
