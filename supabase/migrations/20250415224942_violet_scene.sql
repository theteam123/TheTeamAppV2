/*
  # Simplify permissions for testing
  
  1. Changes
    - Drop existing policies
    - Create simplified policies that grant full access to authenticated users
    
  2. Security Note
    - This is for testing only
    - Not suitable for production use
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view roles in their company" ON user_roles;
DROP POLICY IF EXISTS "Users can manage roles in their company" ON user_roles;
DROP POLICY IF EXISTS "Users can view role permissions in their company" ON role_permissions;
DROP POLICY IF EXISTS "Users can manage role permissions in their company" ON role_permissions;
DROP POLICY IF EXISTS "Users can view roles in their company" ON roles;
DROP POLICY IF EXISTS "Users can manage roles in their company" ON roles;

-- Create simplified policies
CREATE POLICY "Allow all access to authenticated users"
  ON user_roles
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access to authenticated users"
  ON role_permissions
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access to authenticated users"
  ON roles
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);