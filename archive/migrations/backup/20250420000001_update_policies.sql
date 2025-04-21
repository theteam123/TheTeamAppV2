-- Update policies to use standardized role checking functions
BEGIN;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can read companies they belong to" ON companies;
DROP POLICY IF EXISTS "Users can read roles" ON roles;
DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can read their role assignments" ON user_roles;
DROP POLICY IF EXISTS "Users can read their company assignments" ON user_companies;

-- Create new policies using standardized functions
-- Profiles
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT TO authenticated
    USING (id = auth.uid());

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE TO authenticated
    USING (id = auth.uid());

-- Companies
CREATE POLICY "Users can view companies they belong to" ON companies
    FOR SELECT TO authenticated
    USING (
        has_system_role('App_Admin') OR
        EXISTS (
            SELECT 1 FROM user_companies uc
            WHERE uc.user_id = auth.uid()
            AND uc.company_id = companies.id
        )
    );

-- Roles
CREATE POLICY "Users can view roles" ON roles
    FOR SELECT TO authenticated
    USING (
        has_system_role('App_Admin') OR
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role_id = roles.id
        )
    );

-- Role Permissions
CREATE POLICY "Users can view role permissions" ON role_permissions
    FOR SELECT TO authenticated
    USING (
        has_system_role('App_Admin') OR
        EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE ur.user_id = auth.uid()
            AND ur.role_id = role_permissions.role_id
        )
    );

-- User Roles
CREATE POLICY "Users can view their role assignments" ON user_roles
    FOR SELECT TO authenticated
    USING (
        has_system_role('App_Admin') OR
        user_id = auth.uid()
    );

-- User Companies
CREATE POLICY "Users can view their company assignments" ON user_companies
    FOR SELECT TO authenticated
    USING (
        has_system_role('App_Admin') OR
        user_id = auth.uid()
    );

-- Verify the changes
DO $$
DECLARE
    policy_count integer;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public'
    AND policyname LIKE '%view%';

    RAISE NOTICE 'Migration complete. Found % view policies.', policy_count;
END $$;

COMMIT; 