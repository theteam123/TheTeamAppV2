-- First, disable RLS on all tables
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_companies DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DO $$
BEGIN
    -- Drop all policies on profiles
    DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can read profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can update profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;
    
    -- Drop all policies on user_roles
    DROP POLICY IF EXISTS "Users can read their own roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update their own roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can read user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can insert their own roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can delete their own roles" ON user_roles;
    
    -- Drop all policies on roles
    DROP POLICY IF EXISTS "Users can read roles" ON roles;
    DROP POLICY IF EXISTS "Users can update roles" ON roles;
    DROP POLICY IF EXISTS "Users can insert roles" ON roles;
    DROP POLICY IF EXISTS "Users can delete roles" ON roles;
    
    -- Drop all policies on role_permissions
    DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
    DROP POLICY IF EXISTS "Users can update role permissions" ON role_permissions;
    DROP POLICY IF EXISTS "Users can insert role permissions" ON role_permissions;
    DROP POLICY IF EXISTS "Users can delete role permissions" ON role_permissions;
    
    -- Drop all policies on user_companies
    DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;
END $$;

-- Drop all functions
DROP FUNCTION IF EXISTS public.has_system_role(uuid);
DROP FUNCTION IF EXISTS public.get_user_roles(uuid);
DROP FUNCTION IF EXISTS public.check_user_access(uuid);

-- Create a simple function to check system role
CREATE OR REPLACE FUNCTION public.has_system_role(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = has_system_role.user_id
        AND r.is_system_role = true
    );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.has_system_role(uuid) TO authenticated;

-- Create simple policies for profiles
CREATE POLICY "Users can read profiles"
    ON profiles
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update profiles"
    ON profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Create simple policies for user_roles
CREATE POLICY "Users can read user roles"
    ON user_roles
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can update user roles"
    ON user_roles
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Create simple policies for roles
CREATE POLICY "Users can read roles"
    ON roles
    FOR SELECT
    TO authenticated
    USING (true);

-- Create simple policies for role_permissions
CREATE POLICY "Users can read role permissions"
    ON role_permissions
    FOR SELECT
    TO authenticated
    USING (true);

-- Create simple policies for user_companies
CREATE POLICY "Users can view their company associations"
    ON user_companies
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Re-enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;

-- ROLLBACK SQL
DO $$
BEGIN
    -- Disable RLS
    ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
    ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;
    ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
    ALTER TABLE role_permissions DISABLE ROW LEVEL SECURITY;
    ALTER TABLE user_companies DISABLE ROW LEVEL SECURITY;

    -- Drop all policies
    DROP POLICY IF EXISTS "Users can read profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can update profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can read user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can read roles" ON roles;
    DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
    DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;

    -- Drop functions
    DROP FUNCTION IF EXISTS public.has_system_role(uuid);

    -- Re-enable RLS
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;

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
END $$; 