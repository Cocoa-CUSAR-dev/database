-- Merged backend (backend-hub) auth + multi-role.
--
-- backend-hub checks permission keys, never role names, and a person with
-- several roles gets the union of those roles' permissions. Two roles had
-- no permissions at all (mobile-backend only ever checked role names), so
-- without this they couldn't use anything on the hub:
--
--   hub_collector, processor -> read/update own profile, read assigned
--                               forms, read own responses (same as farmer)
--   farmer                   -> update:profile:own (PATCH /api/v1/me/profiles/farmer)
--   admin                    -> update:role:any    (grant/remove researcher, admin)
--
-- Idempotent, same pattern as V10/V23: safe on a DB that already has some rows.

INSERT INTO auth.permission (permission_key, description)
SELECT v.key, v.description
FROM (VALUES
    ('read:profile:own', 'Read the caller''s own profile'),
    ('update:profile:own', 'Update the caller''s own profile and password'),
    ('read:form:assigned', 'Read forms of tasks assigned to the caller'),
    ('read:response:own', 'Read the caller''s own form responses across tasks'),
    ('update:role:any', 'Grant or remove the researcher and admin roles')
) AS v(key, description)
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission p WHERE p.permission_key = v.key
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('hub_collector', 'read:profile:own'),
    ('hub_collector', 'update:profile:own'),
    ('hub_collector', 'read:form:assigned'),
    ('hub_collector', 'read:response:own'),
    ('processor', 'read:profile:own'),
    ('processor', 'update:profile:own'),
    ('processor', 'read:form:assigned'),
    ('processor', 'read:response:own'),
    ('farmer', 'update:profile:own'),
    ('admin', 'update:role:any')
) AS g(role_name, key)
JOIN auth.role r ON r.role_name = g.role_name
JOIN auth.permission p ON p.permission_key = g.key
WHERE NOT EXISTS (
    SELECT 1 FROM auth.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
