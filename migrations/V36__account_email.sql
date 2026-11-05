-- An account's email, separate from its username (docs-and-plan#296).
--
-- username stays what it is: a phone number for people from the app, usually
-- an email address for researchers from the web. email is optional, and an
-- account can sign in with either. Stored in lower case, so one unique index
-- covers every spelling.
--
-- Accounts whose username already is an email address get it copied over. If
-- two usernames differ only by case, neither is copied: nobody can tell which
-- person owns the address.

ALTER TABLE auth.user_account
    ADD COLUMN IF NOT EXISTS email character varying
    CONSTRAINT ck_user_account_email_lower CHECK (email = lower(email));

UPDATE auth.user_account u
SET email = lower(u.username)
WHERE u.email IS NULL
  AND u.username ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'
  AND NOT EXISTS (
      SELECT 1 FROM auth.user_account other
      WHERE other.user_id <> u.user_id
        AND lower(other.username) = lower(u.username)
  );

CREATE UNIQUE INDEX IF NOT EXISTS uq_user_account_email
    ON auth.user_account (email);
