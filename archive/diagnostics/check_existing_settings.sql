-- Check existing schemas
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT LIKE 'pg_%' 
AND schema_name != 'information_schema';

-- Check existing tables in public schema
SELECT 
    table_name,
    table_type,
    is_insertable_into
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check existing functions
SELECT 
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
ORDER BY p.proname;

-- Check existing triggers
SELECT 
    tgname as trigger_name,
    tgrelid::regclass as table_name,
    pg_get_triggerdef(oid) as definition
FROM pg_trigger
WHERE tgisinternal = false
ORDER BY table_name, trigger_name;

-- Check existing policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
ORDER BY schemaname, tablename, policyname;

-- Check existing roles
SELECT 
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;

-- Check existing extensions
SELECT 
    extname,
    extversion,
    extrelocatable
FROM pg_extension
ORDER BY extname;

-- Check RLS status on tables
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check foreign key constraints
SELECT
    tc.table_schema, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_schema, tc.table_name;

-- Check indexes
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Check auth schema status
SELECT 
    'Auth Schema Status' as check,
    EXISTS(SELECT 1 FROM pg_namespace WHERE nspname = 'auth') as auth_schema_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'users') as auth_users_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'sessions') as auth_sessions_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE schemaname = 'auth' AND tablename = 'refresh_tokens') as auth_refresh_tokens_exists;

-- Check essential functions status
SELECT 
    'Essential Functions Status' as check,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') as is_app_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'get_user_companies') as get_user_companies_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_permission') as has_permission_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_system_role') as has_system_role_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_admin_user') as is_admin_user_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'current_company_id') as current_company_id_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') as update_updated_at_column_exists;

-- Check essential tables status
SELECT 
    'Essential Tables Status' as check,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'profiles') as profiles_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'companies') as companies_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'roles') as roles_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'role_permissions') as role_permissions_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'user_roles') as user_roles_exists,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'user_companies') as user_companies_exists;

-- Check system roles
SELECT 
    'System Roles Status' as check,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) as app_admin_exists,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'Company_Admin' AND is_system_role = true) as company_admin_exists,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'User' AND is_system_role = true) as user_exists;

-- Check system permissions
SELECT 
    'System Permissions Status' as check,
    EXISTS(SELECT 1 FROM public.role_permissions WHERE permission_key = 'manage_users') as manage_users_exists,
    EXISTS(SELECT 1 FROM public.role_permissions WHERE permission_key = 'manage_roles') as manage_roles_exists,
    EXISTS(SELECT 1 FROM public.role_permissions WHERE permission_key = 'manage_companies') as manage_companies_exists; 