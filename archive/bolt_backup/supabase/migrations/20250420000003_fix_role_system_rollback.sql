-- Rollback script for 20250420000003_fix_role_system.sql
DO $$
BEGIN
    -- First, drop all policies that depend on the functions
    DROP POLICY IF EXISTS "Users can read profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can update profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can read user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;
    DROP POLICY IF EXISTS "Users can read roles" ON roles;
    DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;

    -- Then drop the functions
    DROP FUNCTION IF EXISTS public.has_system_role(uuid);
    DROP FUNCTION IF EXISTS public.get_user_roles(uuid);

    -- Recreate original policies
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

    -- Verify rollback was successful
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Users can read their own profile'
    ) THEN
        RAISE EXCEPTION 'Failed to recreate original profile read policy';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Users can update their own profile'
    ) THEN
        RAISE EXCEPTION 'Failed to recreate original profile update policy';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'has_system_role'
    ) THEN
        RAISE EXCEPTION 'Failed to drop has_system_role function';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'get_user_roles'
    ) THEN
        RAISE EXCEPTION 'Failed to drop get_user_roles function';
    END IF;

    RAISE NOTICE 'Rollback completed successfully';
END $$; 