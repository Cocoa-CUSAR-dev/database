-- Merged backend (backend-hub): hub, harvest, processing station and batch
-- routes (docs-and-plan#266).
--
-- mobile-backend gated these on the hub_collector / processor role names.
-- backend-hub checks permission keys instead:
--
--   hub_collector -> create:hub:own      (register my hub)
--                    read:hub:own        (my hub, the harvests received there)
--   processor     -> create:station:own  (register my processing station)
--                    read:station:own    (my stations and their batches)
--   researcher    -> read:hub:all, read:station:all
--   admin         -> read:hub:all, read:station:all
--
-- Idempotent, same pattern as V10/V23/V32/V33: only inserts keys and grants
-- that are missing.

INSERT INTO auth.permission (permission_key, description)
SELECT v.key, v.description
FROM (VALUES
    ('create:hub:own', 'Register the caller''s collection hub'),
    ('read:hub:own', 'Read the caller''s hub and the harvests received there'),
    ('read:hub:all', 'Read every hub and harvest'),
    ('create:station:own', 'Register a processing station run by the caller'),
    ('read:station:own', 'Read the caller''s processing stations and their batches'),
    ('read:station:all', 'Read every processing station and batch')
) AS v(key, description)
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission p WHERE p.permission_key = v.key
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('hub_collector', 'create:hub:own'),
    ('hub_collector', 'read:hub:own'),
    ('processor', 'create:station:own'),
    ('processor', 'read:station:own'),
    ('researcher', 'read:hub:all'),
    ('researcher', 'read:station:all'),
    ('admin', 'read:hub:all'),
    ('admin', 'read:station:all')
) AS g(role_name, key)
JOIN auth.role r ON r.role_name = g.role_name
JOIN auth.permission p ON p.permission_key = g.key
WHERE NOT EXISTS (
    SELECT 1 FROM auth.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
