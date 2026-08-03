-- DB-3: no UNIQUE constraints anywhere on identity-like columns -- duplicate
-- logins, duplicate roles, duplicate permission keys were all possible.
--
-- Verified before writing: zero NULLs and zero duplicates today in all three
-- columns below -- safe to add NOT NULL + UNIQUE without any data cleanup.
--
-- Deliberately NOT touching auth.user_account.password_hash here. The
-- original DB-3 writeup suggested making it NOT NULL too, but that's now
-- wrong: LINE-only accounts (ADR 0002) legitimately have no password. The
-- correct invariant ("password OR a linked LINE identity") is enforced at
-- the application layer, not via a blanket NOT NULL on this column.

ALTER TABLE auth.user_account
    ALTER COLUMN username SET NOT NULL,
    ADD CONSTRAINT uq_user_account_username UNIQUE (username);

ALTER TABLE auth.role
    ALTER COLUMN role_name SET NOT NULL,
    ADD CONSTRAINT uq_role_role_name UNIQUE (role_name);

ALTER TABLE auth.permission
    ALTER COLUMN permission_key SET NOT NULL,
    ADD CONSTRAINT uq_permission_permission_key UNIQUE (permission_key);
