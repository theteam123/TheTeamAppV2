-- Check auth schema and tables
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'auth') THEN
        RAISE EXCEPTION 'Auth schema does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'users') THEN
        RAISE EXCEPTION 'Auth users table does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'sessions') THEN
        RAISE EXCEPTION 'Auth sessions table does not exist';
    END IF;
END $$;

-- Check essential functions
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') THEN
        RAISE EXCEPTION 'is_app_admin function does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_user_companies') THEN
        RAISE EXCEPTION 'get_user_companies function does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'has_permission') THEN
        RAISE EXCEPTION 'has_permission function does not exist';
    END IF;
END $$;

-- Check system roles and permissions
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) THEN
        RAISE EXCEPTION 'App_Admin system role does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM public.role_permissions rp
        JOIN public.roles r ON rp.role_id = r.id
        WHERE r.name = 'App_Admin'
        AND rp.permission_key IN ('manage_users', 'manage_roles', 'manage_companies')
    ) THEN
        RAISE EXCEPTION 'App_Admin role is missing required permissions';
    END IF;
END $$;

-- Check user_roles table and policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'user_roles') THEN
        RAISE EXCEPTION 'user_roles table does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE tablename = 'user_roles' 
        AND policyname = 'Enable read access for users based on role'
    ) THEN
        RAISE EXCEPTION 'Missing RLS policy on user_roles table';
    END IF;
END $$;

-- Check profiles table and policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'profiles') THEN
        RAISE EXCEPTION 'profiles table does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Users can view their own profile'
    ) THEN
        RAISE EXCEPTION 'Missing RLS policy on profiles table';
    END IF;
END $$;

-- Check auth.users triggers
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_trigger 
        WHERE tgname = 'on_auth_user_created' 
        AND tgrelid = 'auth.users'::regclass
    ) THEN
        RAISE EXCEPTION 'Missing trigger on_auth_user_created on auth.users';
    END IF;
END $$;

-- Output verification results
SELECT 
    'Auth Setup Verification' as check,
    EXISTS(SELECT 1 FROM pg_namespace WHERE nspname = 'auth') as auth_schema_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'users') as auth_users_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'sessions') as auth_sessions_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') as is_app_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'get_user_companies') as get_user_companies_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_permission') as has_permission_exists,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) as app_admin_role_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'user_roles') as user_roles_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'profiles') as profiles_exists,
    EXISTS(
        SELECT 1 
        FROM pg_trigger 
        WHERE tgname = 'on_auth_user_created' 
        AND tgrelid = 'auth.users'::regclass
    ) as user_created_trigger_exists; 