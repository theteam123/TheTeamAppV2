-- First, disable RLS temporarily to clean up
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;

-- Drop all functions that might be causing recursion
DROP FUNCTION IF EXISTS public.check_user_access(uuid);
DROP FUNCTION IF EXISTS public.get_user_roles(uuid);

-- Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create simple, direct policies without function calls
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

CREATE POLICY "Users can insert their own profile"
    ON profiles
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete their own profile"
    ON profiles
    FOR DELETE
    TO authenticated
    USING (auth.uid() = id);

-- Create a new get_user_roles function with SECURITY DEFINER
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

-- ROLLBACK SQL
DO $$
BEGIN
    -- Disable RLS
    ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
    
    -- Drop all policies
    DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;
    
    -- Drop functions
    DROP FUNCTION IF EXISTS public.get_user_roles(uuid);
    
    -- Re-enable RLS
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    
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