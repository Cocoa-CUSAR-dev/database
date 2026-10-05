-- US2-8 (docs-and-plan#171/#172): a researcher reviewing a chatbot
-- submission needs to correct a wrong field on form.response.answer.
-- read:response:all (V11) only lets them READ every farmer's responses; a
-- write is a different capability and must not ride on a read permission.
-- Same pattern as V23's read:response:own: a new, narrowly-scoped
-- permission granted only to the role this feature actually serves
-- (researcher -- the same role that already holds read:response:all).
--
-- Numbered V28, not V27: sec/sso-hardening already reserves V27
-- (V27__sso_single_use_token.sql) and has not landed on dev yet.

INSERT INTO auth.permission (permission_key, description)
SELECT 'update:response:all', 'Correct a field on any farmer''s form response'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'update:response:all'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key = 'update:response:all'
WHERE r.role_name = 'researcher'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
