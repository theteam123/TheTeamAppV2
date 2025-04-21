-- Start a transaction
BEGIN;

-- First, ensure the roles table exists and has the correct structure
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'roles') THEN
        CREATE TABLE public.roles (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            name text NOT NULL UNIQUE,
            description text,
            is_system_role boolean DEFAULT false,
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now()
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'user_roles') THEN
        CREATE TABLE public.user_roles (
            user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
            role_id uuid REFERENCES public.roles(id) ON DELETE CASCADE,
            created_at timestamptz DEFAULT now(),
            PRIMARY KEY (user_id, role_id)
        );
    END IF;
END $$;

-- Create or replace the is_app_admin function
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

-- Create or replace the is_admin_user function (often used together)
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

-- Ensure the App_Admin role exists
DO $$
DECLARE
    app_admin_id uuid;
BEGIN
    -- Check if App_Admin role exists
    SELECT id INTO app_admin_id
    FROM public.roles
    WHERE name = 'App_Admin' AND is_system_role = true;

    -- If not, create it
    IF app_admin_id IS NULL THEN
        INSERT INTO public.roles (name, description, is_system_role)
        VALUES ('App_Admin', 'System administrator with full access', true)
        RETURNING id INTO app_admin_id;
    END IF;
END $$;

-- Verify the function was created
SELECT 
    'Function Restoration Status' as check,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') as is_app_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_admin_user') as is_admin_user_exists,
    EXISTS(SELECT 1 FROM public.roles WHERE name = 'App_Admin' AND is_system_role = true) as app_admin_role_exists;

-- Commit the transaction
COMMIT; 