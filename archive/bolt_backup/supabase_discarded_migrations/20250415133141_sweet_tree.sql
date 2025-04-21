/*
  # Initial Schema Setup for Multi-tenant System

  1. New Tables
    - `companies`
      - Core company information
      - Fields for name, website, settings
    - `profiles`
      - Extended user profile information
      - Links to current company
    - `roles`
      - Role definitions (e.g., Admin, User)
    - `permissions`
      - Permission definitions
    - `role_permissions`
      - Maps roles to permissions
    - `user_roles`
      - Maps users to roles within companies
    - `user_companies`
      - Maps users to companies they have access to

  2. Security
    - Enable RLS on all tables
    - Add policies for data access based on company membership
    - Ensure users can only access data from their companies

  3. Relationships
    - Users can belong to multiple companies
    - Users have roles within each company
    - Roles have multiple permissions
*/

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  website text,
  settings jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text,
  avatar_url text,
  current_company_id uuid REFERENCES companies(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- Permissions table
CREATE TABLE IF NOT EXISTS permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  description text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

-- Role permissions junction table
CREATE TABLE IF NOT EXISTS role_permissions (
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  permission_id uuid REFERENCES permissions(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (role_id, permission_id)
);

ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- User roles junction table (company-specific roles)
CREATE TABLE IF NOT EXISTS user_roles (
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, role_id, company_id)
);

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- User companies junction table
CREATE TABLE IF NOT EXISTS user_companies (
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, company_id)
);

ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Companies: Users can read companies they belong to
CREATE POLICY "Users can view their companies"
  ON companies
  FOR SELECT
  USING (
    id IN (
      SELECT company_id 
      FROM user_companies 
      WHERE user_id = auth.uid()
    )
  );

-- Profiles: Users can read their own profile
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (id = auth.uid());

-- Profiles: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (id = auth.uid());

-- Roles: Users can read roles
CREATE POLICY "Users can view roles"
  ON roles
  FOR SELECT
  TO authenticated
  USING (true);

-- Permissions: Users can read permissions
CREATE POLICY "Users can view permissions"
  ON permissions
  FOR SELECT
  TO authenticated
  USING (true);

-- Role permissions: Users can read role permissions
CREATE POLICY "Users can view role permissions"
  ON role_permissions
  FOR SELECT
  TO authenticated
  USING (true);

-- User roles: Users can read their own roles
CREATE POLICY "Users can view own roles"
  ON user_roles
  FOR SELECT
  USING (user_id = auth.uid());

-- User companies: Users can read their own company associations
CREATE POLICY "Users can view own company associations"
  ON user_companies
  FOR SELECT
  USING (user_id = auth.uid());

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_profiles_current_company ON profiles(current_company_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_company_id ON user_roles(company_id);
CREATE INDEX IF NOT EXISTS idx_user_companies_user_id ON user_companies(user_id);
CREATE INDEX IF NOT EXISTS idx_user_companies_company_id ON user_companies(company_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_companies_updated_at
  BEFORE UPDATE ON companies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();