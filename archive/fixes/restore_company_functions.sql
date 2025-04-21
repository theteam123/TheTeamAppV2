-- Start a transaction
BEGIN;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.current_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.set_audit_log_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_companies() CASCADE;
DROP FUNCTION IF EXISTS public.is_company_admin(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.has_company_permission(text, uuid) CASCADE;
DROP FUNCTION IF EXISTS public.update_last_login() CASCADE;

-- Create or replace current_company_id function
CREATE OR REPLACE FUNCTION public.current_company_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    company_id uuid;
BEGIN
    -- Get company_id from JWT claims
    SELECT (current_setting('request.jwt.claims', true)::json->>'company_id')::uuid INTO company_id;
    
    -- If no company_id in JWT, try to get it from user_companies table
    IF company_id IS NULL THEN
        SELECT uc.company_id INTO company_id
        FROM user_companies uc
        WHERE uc.user_id = auth.uid()
        LIMIT 1;
    END IF;
    
    RETURN company_id;
END;
$$;

-- Create or replace set_audit_log_company_id function
CREATE OR REPLACE FUNCTION public.set_audit_log_company_id()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.company_id := (
        SELECT current_company_id
        FROM profiles
        WHERE id = auth.uid()
    );
    RETURN NEW;
END;
$$;

-- Create or replace get_user_companies function
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

-- Create or replace is_company_admin function
CREATE OR REPLACE FUNCTION public.is_company_admin(company_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.user_companies uc ON ur.user_id = uc.user_id
        WHERE ur.user_id = auth.uid()
        AND uc.company_id = is_company_admin.company_id
        AND r.name = 'Company_Admin'
    );
END;
$$;

-- Create or replace has_company_permission function
CREATE OR REPLACE FUNCTION public.has_company_permission(permission text, company_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.role_permissions rp ON r.id = rp.role_id
        JOIN public.user_companies uc ON ur.user_id = uc.user_id
        WHERE ur.user_id = auth.uid()
        AND uc.company_id = has_company_permission.company_id
        AND rp.permission_key = has_company_permission.permission
    );
END;
$$;

-- Create or replace update_last_login function
CREATE OR REPLACE FUNCTION public.update_last_login()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_companies
    SET last_login_at = now()
    WHERE user_id = NEW.user_id
    AND company_id = NEW.company_id;
    RETURN NEW;
END;
$$;

-- Verify functions were created
SELECT 
    'Company Functions Status' as check,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'current_company_id') as current_company_id_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'set_audit_log_company_id') as set_audit_log_company_id_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'get_user_companies') as get_user_companies_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_company_admin') as is_company_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_company_permission') as has_company_permission_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'update_last_login') as update_last_login_exists;

-- Commit the transaction
COMMIT; 