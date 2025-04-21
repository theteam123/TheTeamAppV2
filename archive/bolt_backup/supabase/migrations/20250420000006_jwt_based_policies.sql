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
    DROP POLICY IF EXISTS "Users can view profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can create profiles" ON profiles;
    
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
DROP FUNCTION IF EXISTS public.has_system_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_roles(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.check_user_access(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.is_admin_user() CASCADE;

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

-- Create a function to check if user is admin (using JWT)
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN (auth.jwt() ->> 'role') = 'App_Admin';
END;
$$;

-- Create a function to get user roles
CREATE OR REPLACE FUNCTION public.get_user_roles(user_id uuid)
RETURNS TABLE (
    role_id uuid,
    role_name text,
    is_system_role boolean,
    permissions jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id as role_id,
        r.name as role_name,
        r.is_system_role,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'permission_key', rp.permission_key
            ))
            FROM user_role_permissions_view rp
            WHERE rp.role_id = r.id
            AND rp.user_id = get_user_roles.user_id
        ) as permissions
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = get_user_roles.user_id;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.has_system_role(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_roles(uuid) TO authenticated;

-- Create new policies for profiles using JWT-based checks
CREATE POLICY "Users can read profiles"
    ON profiles
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id
        OR is_admin_user()
        OR EXISTS (
            SELECT 1
            FROM user_roles ur
            JOIN roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid()
            AND r.name = 'Company_Admin'
            AND EXISTS (
                SELECT 1
                FROM user_companies uc
                WHERE uc.user_id = profiles.id
                AND uc.company_id = ((auth.jwt() ->> 'current_company_id')::uuid)
            )
        )
    );

CREATE POLICY "Users can update profiles"
    ON profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Create policies for user_roles
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

-- Create policies for user_companies
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

    -- Drop all policies on all tables
    DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can read profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can update profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can view profiles" ON profiles;
    DROP POLICY IF EXISTS "Users can create profiles" ON profiles;
    
    DROP POLICY IF EXISTS "Users can read their own roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update their own roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can read user roles" ON user_roles;
    DROP POLICY IF EXISTS "Users can update user roles" ON user_roles;
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
    
    DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;

    -- Drop functions
    DROP FUNCTION IF EXISTS public.has_system_role(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.is_admin_user() CASCADE;

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