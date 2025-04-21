-- Rollback script for 20250420000002_fix_profile_policies.sql
-- This will revert all changes made in the migration and restore the original state

-- First, disable RLS on all affected tables
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions DISABLE ROW LEVEL SECURITY;

-- Drop all policies from all affected tables
DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;

DROP POLICY IF EXISTS "Users can read their own roles" ON user_roles;
DROP POLICY IF EXISTS "Users can update their own roles" ON user_roles;
DROP POLICY IF EXISTS "Users can insert their own roles" ON user_roles;
DROP POLICY IF EXISTS "Users can delete their own roles" ON user_roles;

DROP POLICY IF EXISTS "Users can read roles" ON roles;
DROP POLICY IF EXISTS "Users can update roles" ON roles;
DROP POLICY IF EXISTS "Users can insert roles" ON roles;
DROP POLICY IF EXISTS "Users can delete roles" ON roles;

DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can update role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can insert role permissions" ON role_permissions;
DROP POLICY IF EXISTS "Users can delete role permissions" ON role_permissions;

-- Drop all functions created in the migration
DROP FUNCTION IF EXISTS public.get_user_roles(uuid);
DROP FUNCTION IF EXISTS public.check_user_access(uuid);

-- Re-enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- Recreate the original policies for profiles
CREATE POLICY "Users can read their own profile"
    ON profiles
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Recreate the original policies for user_roles
CREATE POLICY "Users can read their own roles"
    ON user_roles
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can update their own roles"
    ON user_roles
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Recreate the original policies for roles
CREATE POLICY "Users can read roles"
    ON roles
    FOR SELECT
    TO authenticated
    USING (true);

-- Recreate the original policies for role_permissions
CREATE POLICY "Users can read role permissions"
    ON role_permissions
    FOR SELECT
    TO authenticated
    USING (true);

-- Verify the rollback
DO $$
BEGIN
    -- Check if policies were recreated
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Users can read their own profile'
    ) THEN
        RAISE EXCEPTION 'Rollback failed: Policy "Users can read their own profile" not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_roles' 
        AND policyname = 'Users can read their own roles'
    ) THEN
        RAISE EXCEPTION 'Rollback failed: Policy "Users can read their own roles" not found';
    END IF;

    -- Check if functions were dropped
    IF EXISTS (
        SELECT 1 FROM pg_proc 
        WHERE proname = 'get_user_roles'
    ) THEN
        RAISE EXCEPTION 'Rollback failed: Function get_user_roles still exists';
    END IF;

    -- Check if RLS is enabled
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'profiles' 
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'Rollback failed: RLS not enabled on profiles table';
    END IF;

    RAISE NOTICE 'Rollback completed successfully';
END $$; 