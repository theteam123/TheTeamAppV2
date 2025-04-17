/*
  # Add Role Management Policies

  1. New Policies
    - Enable RLS on user_roles and role_permissions tables
    - Add SELECT policy for user_roles to allow users to view roles in their company
    - Add SELECT policy for role_permissions to allow users to view permissions for their roles
    - Add INSERT, UPDATE, DELETE policies for role management

  2. Security
    - Ensure users can only access role data within their company context
    - Prevent unauthorized access to role and permission data
*/

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- User Roles Policies
CREATE POLICY "Users can view roles in their company"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can manage roles in their company"
  ON user_roles
  FOR ALL
  TO authenticated
  USING (
    company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
  )
  WITH CHECK (
    company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
  );

-- Role Permissions Policies
CREATE POLICY "Users can view role permissions in their company"
  ON role_permissions
  FOR SELECT
  TO authenticated
  USING (
    role_id IN (
      SELECT id FROM roles 
      WHERE id IN (
        SELECT role_id 
        FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
      )
    )
  );

CREATE POLICY "Users can manage role permissions in their company"
  ON role_permissions
  FOR ALL
  TO authenticated
  USING (
    role_id IN (
      SELECT id FROM roles 
      WHERE id IN (
        SELECT role_id 
        FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
      )
    )
  )
  WITH CHECK (
    role_id IN (
      SELECT id FROM roles 
      WHERE id IN (
        SELECT role_id 
        FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
      )
    )
  );

-- Roles Policies
CREATE POLICY "Users can view roles in their company"
  ON roles
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT role_id 
      FROM user_roles 
      WHERE user_id = auth.uid() 
      AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
    )
  );

CREATE POLICY "Users can manage roles in their company"
  ON roles
  FOR ALL
  TO authenticated
  USING (
    id IN (
      SELECT role_id 
      FROM user_roles 
      WHERE user_id = auth.uid() 
      AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    id IN (
      SELECT role_id 
      FROM user_roles 
      WHERE user_id = auth.uid() 
      AND company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
    )
  );