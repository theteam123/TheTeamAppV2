-- First, create a function to check if a user has system role
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

-- Create a function to get user roles with proper system role handling
CREATE OR REPLACE FUNCTION public.get_user_roles(user_id uuid)
RETURNS TABLE (
    role_id uuid,
    role_name text,
    is_system_role boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id as role_id,
        r.name as role_name,
        r.is_system_role
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = get_user_roles.user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_user_roles(uuid) TO authenticated;

-- Drop ALL existing policies on all tables
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
END $$;

-- Create new policies that handle both regular users and system roles
CREATE POLICY "Users can read profiles"
    ON profiles
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id OR 
        has_system_role(auth.uid())
    );

CREATE POLICY "Users can update profiles"
    ON profiles
    FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = id OR 
        has_system_role(auth.uid())
    )
    WITH CHECK (
        auth.uid() = id OR 
        has_system_role(auth.uid())
    );

-- Create policies for user_roles
CREATE POLICY "Users can read user roles"
    ON user_roles
    FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid() OR 
        has_system_role(auth.uid())
    );

CREATE POLICY "Users can update user roles"
    ON user_roles
    FOR UPDATE
    TO authenticated
    USING (
        user_id = auth.uid() OR 
        has_system_role(auth.uid())
    )
    WITH CHECK (
        user_id = auth.uid() OR 
        has_system_role(auth.uid())
    );

-- Create policies for roles
CREATE POLICY "Users can read roles"
    ON roles
    FOR SELECT
    TO authenticated
    USING (true);

-- Create policies for role_permissions
CREATE POLICY "Users can read role permissions"
    ON role_permissions
    FOR SELECT
    TO authenticated
    USING (true);

-- ROLLBACK SQL
DO $$
BEGIN
    -- First drop all policies that depend on the functions
    DROP POLICY IF EXISTS "Users can read profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can update profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can read user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;
    
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
END $$; 