-- Create function to check user permissions
CREATE OR REPLACE FUNCTION has_permission(permission text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  has_permission boolean;
BEGIN
  -- Check if user has the specified permission in their role
  SELECT EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    JOIN role_permissions rp ON r.id = rp.role_id
    JOIN permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = auth.uid()
    AND ur.company_id = current_company_id()
    AND p.name = permission
  ) INTO has_permission;
  
  RETURN has_permission;
END;
$$;

-- Enable RLS on all tables
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies for user_companies table
CREATE POLICY "Users can view their own company's users"
  ON user_companies
  FOR SELECT
  USING (
    company_id = current_company_id()
  );

CREATE POLICY "Admins can manage their company's users"
  ON user_companies
  FOR ALL
  USING (
    company_id = current_company_id()
    AND has_permission('users.manage')
  );

-- Policies for user_roles table
CREATE POLICY "Users can view their company's roles"
  ON user_roles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.user_id = user_roles.user_id
      AND user_companies.company_id = current_company_id()
    )
  );

CREATE POLICY "Admins can manage their company's roles"
  ON user_roles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.user_id = user_roles.user_id
      AND user_companies.company_id = current_company_id()
    )
    AND has_permission('users.manage')
  );

-- Policies for profiles table
CREATE POLICY "Users can view their company's profiles"
  ON profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.user_id = profiles.id
      AND user_companies.company_id = current_company_id()
    )
  );

CREATE POLICY "Admins can update their company's profiles"
  ON profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.user_id = profiles.id
      AND user_companies.company_id = current_company_id()
    )
    AND has_permission('users.manage')
  ); 