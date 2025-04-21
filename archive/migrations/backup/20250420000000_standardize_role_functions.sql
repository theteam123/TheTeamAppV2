-- Create standardized role checking functions
BEGIN;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS has_role(text);
DROP FUNCTION IF EXISTS has_permission(text);
DROP FUNCTION IF EXISTS has_system_role(text);

-- Function to check if a user has a specific role
CREATE OR REPLACE FUNCTION has_role(role_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    role_id uuid;
BEGIN
    -- Get the role ID for the given role name
    SELECT id INTO role_id
    FROM roles
    WHERE name = role_name;

    -- If role doesn't exist, return false
    IF role_id IS NULL THEN
        RETURN false;
    END IF;

    -- Check if user has the role
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        WHERE ur.user_id = auth.uid()
        AND ur.role_id = role_id
    );
END;
$$;

-- Function to check if a user has a specific permission
CREATE OR REPLACE FUNCTION has_permission(permission_key text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if user has the permission through any of their roles
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN role_permissions rp ON ur.role_id = rp.role_id
        WHERE ur.user_id = auth.uid()
        AND rp.permission_key = permission_key
    );
END;
$$;

-- Function to check if a user has a specific system role
CREATE OR REPLACE FUNCTION has_system_role(role_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if user has the system role
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = role_name
        AND r.is_system_role = true
    );
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION has_role(text) TO authenticated;
GRANT EXECUTE ON FUNCTION has_permission(text) TO authenticated;
GRANT EXECUTE ON FUNCTION has_system_role(text) TO authenticated;

COMMIT;

-- Update policies to use standardized role checking functions
BEGIN;

-- Drop existing policies with both old and new names
DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can read companies they belong to" ON companies;
DROP POLICY IF EXISTS "Users can view companies they belong to" ON companies;
DROP POLICY IF EXISTS "Users can read roles" ON roles;
DROP POLICY IF EXISTS "Users can view roles" ON roles;
DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can view role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can read their role assignments" ON user_roles;
DROP POLICY IF EXISTS "Users can view their role assignments" ON user_roles;
DROP POLICY IF EXISTS "Users can read their company assignments" ON user_companies;
DROP POLICY IF EXISTS "Users can view their company assignments" ON user_companies;

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

-- Remove test policies
DROP POLICY IF EXISTS "Test has_role function" ON roles;
DROP POLICY IF EXISTS "Test has_permission function" ON role_permissions;
DROP POLICY IF EXISTS "Test has_system_role function" ON roles; 