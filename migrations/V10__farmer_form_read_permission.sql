-- Farmer-scoped form auth: lets the mobile backend forward a farmer's own
-- JWT to Kotlin's GET /forms/{formId} (previously researcher-only via
-- read:form:all). The farmer role already exists in auth.role but has no
-- permissions granted to it yet.

INSERT INTO auth.permission (permission_key, description)
SELECT 'read:form:assigned', 'Read a single form structure for a task assigned to the caller'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'read:form:assigned'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key = 'read:form:assigned'
WHERE r.role_name = 'farmer'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
