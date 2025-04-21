-- Start a transaction
BEGIN;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.is_app_admin() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_companies() CASCADE;
DROP FUNCTION IF EXISTS public.has_permission(text) CASCADE;
DROP FUNCTION IF EXISTS public.has_permission(uuid, text, uuid) CASCADE;
DROP FUNCTION IF EXISTS public.has_system_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.is_admin_user() CASCADE;
DROP FUNCTION IF EXISTS public.current_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.log_user_status_change() CASCADE;
DROP FUNCTION IF EXISTS public.refresh_user_role_permissions_view() CASCADE;
DROP FUNCTION IF EXISTS public.set_audit_log_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.update_last_login() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- Create is_app_admin function
CREATE OR REPLACE FUNCTION public.is_app_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    );
END;
$$;

-- Create get_user_companies function
CREATE OR REPLACE FUNCTION public.get_user_companies()
RETURNS TABLE (
    company_id uuid,
    company_name text,
    status text,
    last_login_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as company_id,
        c.name as company_name,
        uc.status::text,
        uc.last_login_at
    FROM public.user_companies uc
    JOIN public.companies c ON uc.company_id = c.id
    WHERE uc.user_id = auth.uid();
END;
$$;

-- Create has_permission function
CREATE OR REPLACE FUNCTION public.has_permission(permission text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.role_permissions rp ON r.id = rp.role_id
        WHERE ur.user_id = auth.uid()
        AND rp.permission_key = permission
    );
END;
$$;

-- Create has_system_role function
CREATE OR REPLACE FUNCTION public.has_system_role(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = user_id
        AND r.is_system_role = true
    );
END;
$$;

-- Create is_admin_user function
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    );
END;
$$;

-- Create current_company_id function
CREATE OR REPLACE FUNCTION public.current_company_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    company_id uuid;
BEGIN
    SELECT current_company_id INTO company_id
    FROM public.profiles
    WHERE id = auth.uid();
    
    RETURN company_id;
END;
$$;

-- Create update_updated_at_column function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- Verify functions were created
SELECT 
    'Function Restoration Status' as check,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') as is_app_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'get_user_companies') as get_user_companies_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_permission') as has_permission_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_system_role') as has_system_role_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_admin_user') as is_admin_user_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'current_company_id') as current_company_id_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') as update_updated_at_column_exists;

-- Commit the transaction
COMMIT; 