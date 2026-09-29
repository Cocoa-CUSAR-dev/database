-- US2-6/US5-1 : farmer-scoped submission history needs a
-- farmer to read their own form.response rows across every task, grouped
-- by date. read:response:all (V11) is researcher-only and scoped to "every
-- farmer's responses for a task" -- wrong shape and wrong role for this.
-- Same pattern as V10's read:form:assigned: a new, narrowly-scoped
-- permission granted only to the role this feature actually serves.

INSERT INTO auth.permission (permission_key, description)
SELECT 'read:response:own', 'Read the caller''s own form responses across tasks'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'read:response:own'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key = 'read:response:own'
WHERE r.role_name = 'farmer'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
