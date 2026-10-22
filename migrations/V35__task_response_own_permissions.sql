-- Merged backend (backend-hub): submitting and editing your own answer
-- (API migration map rows TASK-06 and TASK-07; the LINE chatbot submits the
-- same way once it calls tasks.service instead of mobile-backend).
--
-- mobile-backend let any signed-in user submit an answer and edit it (it only
-- checked the JWT, never a role or a permission). The chatbot did the same
-- through Go's /service/tasks. backend-hub checks permission keys, so the two
-- things a person does with their own answers need keys, and the roles that
-- fill in forms need to hold them:
--
--   farmer, hub_collector, processor
--     -> create:response:own  (submit an answer; same function for the app,
--                              LINE and LIFF)
--        update:response:own  (edit one of my answers)
--
-- Reading tasks needs nothing new: the hub's task list and form routes use
-- read:form:assigned and read:response:own, which these roles already hold
-- (V10, V23, V32).
--
-- Not granted to researcher or admin: they read and correct other people's
-- answers (read:response:all, update:response:all), they don't file their own.
--
-- Apply this before backend-hub starts requiring create:response:own or
-- update:response:own, or people who can submit today would be turned away.
--
-- Idempotent, same pattern as V10/V23/V32/V33: only inserts keys and grants
-- that are missing. A role that does not exist yet is skipped, not an error.

INSERT INTO auth.permission (permission_key, description)
SELECT v.key, v.description
FROM (VALUES
    ('create:response:own', 'Submit the caller''s own answer to a task'),
    ('update:response:own', 'Edit one of the caller''s own answers to a task')
) AS v(key, description)
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission p WHERE p.permission_key = v.key
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('farmer', 'create:response:own'),
    ('farmer', 'update:response:own'),
    ('hub_collector', 'create:response:own'),
    ('hub_collector', 'update:response:own'),
    ('processor', 'create:response:own'),
    ('processor', 'update:response:own')
) AS g(role_name, key)
JOIN auth.role r ON r.role_name = g.role_name
JOIN auth.permission p ON p.permission_key = g.key
WHERE NOT EXISTS (
    SELECT 1 FROM auth.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
