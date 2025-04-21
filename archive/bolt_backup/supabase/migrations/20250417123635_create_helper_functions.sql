-- Create helper functions for RLS policies
BEGIN;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS has_system_role(uuid);
DROP FUNCTION IF EXISTS is_app_admin();
DROP FUNCTION IF EXISTS get_user_companies();

-- Create has_system_role function
CREATE OR REPLACE FUNCTION has_system_role(user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = has_system_role.user_id
    AND r.is_system_role = true
  );
$$;

-- Create is_app_admin function
CREATE OR REPLACE FUNCTION is_app_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = auth.uid()
    AND r.name = 'App_Admin'
  );
$$;

-- Create get_user_companies function
CREATE OR REPLACE FUNCTION get_user_companies()
RETURNS TABLE (
  id uuid,
  name text,
  website text,
  created_at timestamptz,
  updated_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT c.*
  FROM companies c
  WHERE is_app_admin() 
     OR EXISTS (
       SELECT 1 
       FROM user_companies uc 
       WHERE uc.user_id = auth.uid() 
       AND uc.company_id = c.id
     );
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION has_system_role(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_app_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_companies() TO authenticated;

COMMIT; 