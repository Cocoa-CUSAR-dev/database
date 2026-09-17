-- US2-6: AuthenticationController's GET /auth/me (gated by
-- read:profile:own) is what web-app's AuthWrapper calls to learn a
-- session's roles before deciding access to any authenticated page --
-- including /history, which farmer sessions now reach via SSO. Confirmed
-- live 2026-09-17: a farmer's own SSO-issued session got 403 on /auth/me
-- and was redirected away from /history as "not allowed role", because the
-- permission it actually needed was read:profile:own, not read:response:own
-- -- farmer never had this granted since nothing farmer-facing existed in
-- web-app before this feature. Same pattern as V10/V23: a narrowly-scoped
-- permission granted only to the role this feature actually serves.

-- Idempotent even though this permission is expected to already exist
-- (used by /auth/me since before this migration) -- guards against this
-- migration running against a database where it was never seeded.
INSERT INTO auth.permission (permission_key, description)
SELECT 'read:profile:own', 'Read the caller''s own user profile'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'read:profile:own'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key = 'read:profile:own'
WHERE r.role_name = 'farmer'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
