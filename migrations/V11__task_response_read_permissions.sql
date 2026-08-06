-- BE-2 (M5): TaskController and FormResponseController in web-backend had no
-- @PreAuthorize at all — any authenticated account, not just researchers,
-- could list every task and read every farmer's form responses. Gating those
-- endpoints needs two permissions that don't exist yet.

INSERT INTO auth.permission (permission_key, description)
SELECT 'read:task:all', 'Read all data-collection tasks'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'read:task:all'
);

INSERT INTO auth.permission (permission_key, description)
SELECT 'read:response:all', 'Read all farmers'' form responses for a task'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'read:response:all'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key IN ('read:task:all', 'read:response:all')
WHERE r.role_name = 'researcher'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
