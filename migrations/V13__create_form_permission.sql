-- Backend fix proposal, Part 2 (Authoring): Kotlin's PUT /forms/{formId}/edit
-- only toggles is_active/is_mandatory -- there is no way to create a form at
-- all today (all 82 task_form rows were inserted by hand via SQL). The new
-- POST /forms endpoint needs a permission to gate on, matching the existing
-- read:form:all / update:form:all pattern.

INSERT INTO auth.permission (permission_key, description)
SELECT 'create:form:all', 'Create a new form (task, sections, and questions)'
WHERE NOT EXISTS (
    SELECT 1 FROM auth.permission WHERE permission_key = 'create:form:all'
);

INSERT INTO auth.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM auth.role r
JOIN auth.permission p ON p.permission_key = 'create:form:all'
WHERE r.role_name = 'researcher'
  AND NOT EXISTS (
      SELECT 1 FROM auth.role_permission rp
      WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
