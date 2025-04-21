-- Start a transaction
BEGIN;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.is_app_admin() CASCADE;
DROP FUNCTION IF EXISTS public.is_admin_user() CASCADE;
DROP FUNCTION IF EXISTS public.has_permission(text) CASCADE;
DROP FUNCTION IF EXISTS public.has_system_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.log_user_status_change() CASCADE;
DROP FUNCTION IF EXISTS public.refresh_user_role_permissions_view() CASCADE;

-- Create or replace is_app_admin function
CREATE OR REPLACE FUNCTION public.is_app_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    );
END;
$$;

-- Create or replace is_admin_user function
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    );
END;
$$;

-- Create or replace has_permission function
CREATE OR REPLACE FUNCTION public.has_permission(permission text)
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
        WHERE ur.user_id = auth.uid()
        AND rp.permission_key = has_permission.permission
    );
END;
$$;

-- Create or replace has_system_role function
CREATE OR REPLACE FUNCTION public.has_system_role(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = has_system_role.user_id
        AND r.is_system_role = true
    );
END;
$$;

-- Create or replace handle_new_user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Create profile for new user
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
    );

    -- Assign default User role if it exists
    INSERT INTO public.user_roles (user_id, role_id)
    SELECT NEW.id, r.id
    FROM public.roles r
    WHERE r.name = 'User' AND r.is_system_role = true;

    RETURN NEW;
END;
$$;

-- Create or replace log_user_status_change function
CREATE OR REPLACE FUNCTION public.log_user_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO public.audit_logs (
            user_id,
            action,
            details,
            company_id
        )
        VALUES (
            NEW.user_id,
            'user_status_change',
            jsonb_build_object(
                'old_status', OLD.status,
                'new_status', NEW.status
            ),
            current_company_id()
        );
    END IF;
    RETURN NEW;
END;
$$;

-- Create or replace refresh_user_role_permissions_view function
CREATE OR REPLACE FUNCTION public.refresh_user_role_permissions_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.user_role_permissions;
END;
$$;

-- Verify functions were created
SELECT 
    'User Functions Status' as check,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') as is_app_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_admin_user') as is_admin_user_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_permission') as has_permission_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'has_system_role') as has_system_role_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user') as handle_new_user_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'log_user_status_change') as log_user_status_change_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'refresh_user_role_permissions_view') as refresh_user_role_permissions_view_exists;

-- Commit the transaction
COMMIT; 