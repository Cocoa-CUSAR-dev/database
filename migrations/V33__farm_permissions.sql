-- Merged backend (backend-hub): farm and plot routes (docs-and-plan#265).
--
-- mobile-backend gated POST/GET /farms, /plots and the farm photo upload on
-- the farmer role name. backend-hub checks permission keys instead, so the
-- farmer role needs keys for them:
--
--   farmer     -> create:farm:own  (register a farm, or a plot on your own farm)
--                 read:farm:own    (your farms and their plots)
--                 update:farm:own  (your farm's photo)
--   researcher -> read:farm:all    (every farm and plot, e.g. the web map)
--   admin      -> read:farm:all
--
-- Idempotent, same pattern as V10/V23/V32: only inserts keys and grants
-- that are missing.

INSERT INTO auth.permission (permission_key, description)
SELECT v.key, v.description
FROM (VALUES
    ('create:farm:own', 'Register a farm, or a plot on one of the caller''s farms'),
    ('read:farm:own', 'Read the caller''s own farms and their plots'),
    ('update:farm:own', 'Update the caller''s own farm (e.g. its photo)'),
    ('read:farm:all', 'Read every farm and plot')
) AS v(key, description)
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission p WHERE p.permission_key = v.key
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('farmer', 'create:farm:own'),
    ('farmer', 'read:farm:own'),
    ('farmer', 'update:farm:own'),
    ('researcher', 'read:farm:all'),
    ('admin', 'read:farm:all')
) AS g(role_name, key)
JOIN auth.role r ON r.role_name = g.role_name
JOIN auth.permission p ON p.permission_key = g.key
WHERE NOT EXISTS (
    SELECT 1 FROM auth.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
