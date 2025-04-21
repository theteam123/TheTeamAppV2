-- Start a transaction
BEGIN;

-- Set session replication role to replica to disable triggers and constraints temporarily
SET session_replication_role = replica;

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.user_companies CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.companies CASCADE;
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.content CASCADE;
DROP TABLE IF EXISTS public.content_tags CASCADE;
DROP TABLE IF EXISTS public.content_content_tags CASCADE;
DROP TABLE IF EXISTS public.menu_sections CASCADE;
DROP TABLE IF EXISTS public.public_submitters CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS public.has_permission(text) CASCADE;
DROP FUNCTION IF EXISTS public.has_permission(uuid, text, uuid) CASCADE;
DROP FUNCTION IF EXISTS public.has_system_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.is_admin_user() CASCADE;
DROP FUNCTION IF EXISTS public.current_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_companies() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.log_user_status_change() CASCADE;
DROP FUNCTION IF EXISTS public.refresh_user_role_permissions_view() CASCADE;
DROP FUNCTION IF EXISTS public.set_audit_log_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.update_last_login() CASCADE;

-- Restore the backup
\i backup-202504181106.sql

-- Reset session replication role to default
SET session_replication_role = DEFAULT;

-- Verify the restoration
DO $$
BEGIN
    -- Check if all required tables exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        RAISE EXCEPTION 'profiles table not restored';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'companies') THEN
        RAISE EXCEPTION 'companies table not restored';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_companies') THEN
        RAISE EXCEPTION 'user_companies table not restored';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'roles') THEN
        RAISE EXCEPTION 'roles table not restored';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_roles') THEN
        RAISE EXCEPTION 'user_roles table not restored';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_permissions') THEN
        RAISE EXCEPTION 'role_permissions table not restored';
    END IF;
    
    -- Check if App_Admin role exists
    IF NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) THEN
        RAISE EXCEPTION 'App_Admin role not restored';
    END IF;
    
    -- Check if RLS is enabled on key tables
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_tables 
        WHERE tablename = 'profiles' 
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'RLS not enabled on profiles table';
    END IF;
END $$;

-- Output restoration status
SELECT 
    'Restoration Status' as check,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') as profiles_restored,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'companies') as companies_restored,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_companies') as user_companies_restored,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'roles') as roles_restored,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_roles') as user_roles_restored,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_permissions') as role_permissions_restored,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) as app_admin_restored,
    EXISTS(SELECT 1 FROM pg_tables WHERE tablename = 'profiles' AND rowsecurity = true) as rls_enabled;

-- Commit the transaction
COMMIT; 