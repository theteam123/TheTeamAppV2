-- Create profiles table and related tables
BEGIN;

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  email text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  current_company_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create companies table if it doesn't exist
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  website text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  is_system_role boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create role_permissions table if it doesn't exist
CREATE TABLE IF NOT EXISTS role_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  permission_key text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create user_roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, role_id)
);

-- Create user_companies table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, company_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_current_company_id ON profiles(current_company_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);

-- Create helper functions for RLS policies
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

-- Create policies for profiles table
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create policies for companies table
DROP POLICY IF EXISTS "Users can view companies they belong to" ON companies;
CREATE POLICY "Users can view companies they belong to"
  ON companies
  FOR SELECT
  TO authenticated
  USING (
    has_system_role(auth.uid()) OR
    EXISTS (
      SELECT 1 FROM user_companies uc
      WHERE uc.company_id = id
      AND uc.user_id = auth.uid()
    )
  );

-- Create policies for roles table
DROP POLICY IF EXISTS "Users can view roles" ON roles;
CREATE POLICY "Users can view roles"
  ON roles
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policies for role_permissions table
DROP POLICY IF EXISTS "Users can view role permissions" ON role_permissions;
CREATE POLICY "Users can view role permissions"
  ON role_permissions
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policies for user_roles table
DROP POLICY IF EXISTS "Users can view their roles" ON user_roles;
CREATE POLICY "Users can view their roles"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    has_system_role(auth.uid()) OR
    user_id = auth.uid()
  );

-- Create policies for user_companies table
DROP POLICY IF EXISTS "Users can view their company associations" ON user_companies;
CREATE POLICY "Users can view their company associations"
  ON user_companies
  FOR SELECT
  TO authenticated
  USING (
    has_system_role(auth.uid()) OR
    user_id = auth.uid()
  );

-- Create trigger for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for timestamp updates
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_roles_updated_at ON roles;
CREATE TRIGGER update_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Insert App_Admin role if it doesn't exist
INSERT INTO roles (name, description, is_system_role)
VALUES ('App_Admin', 'System administrator with full access', true)
ON CONFLICT (name) DO NOTHING;

-- Insert permissions for App_Admin role
DO $$
DECLARE
    admin_role_id uuid;
BEGIN
    SELECT id INTO admin_role_id FROM roles WHERE name = 'App_Admin';
    
    INSERT INTO role_permissions (role_id, permission_key)
    VALUES 
        (admin_role_id, 'can_manage_companies'),
        (admin_role_id, 'can_manage_users'),
        (admin_role_id, 'can_manage_roles'),
        (admin_role_id, 'can_manage_content'),
        (admin_role_id, 'can_manage_categories'),
        (admin_role_id, 'can_manage_tags')
    ON CONFLICT DO NOTHING;
END $$;

-- Add foreign key constraint for current_company_id
ALTER TABLE profiles
ADD CONSTRAINT fk_profiles_current_company_id
FOREIGN KEY (current_company_id)
REFERENCES companies(id)
ON DELETE SET NULL;

COMMIT; 