/*
  # Fix SuperAdmin Role Setup

  1. Ensure SuperAdmin role exists with correct flags
  2. Assign proper permissions
  3. Assign role to paul@theteam.net.au
  4. Fix RLS policies to allow system role access
*/

-- First ensure the roles table has is_system_role column
ALTER TABLE roles ADD COLUMN IF NOT EXISTS is_system_role boolean DEFAULT false;

-- Modify user_roles table to allow NULL company_id for system roles
ALTER TABLE user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE user_roles ALTER COLUMN company_id DROP NOT NULL;
ALTER TABLE user_roles ADD PRIMARY KEY (user_id, role_id);

-- Create or update the SuperAdmin role
INSERT INTO roles (
  id,
  name,
  description,
  is_system_role
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'SuperAdmin',
  'Super Administrator with complete system access',
  true
)
ON CONFLICT (id) DO UPDATE
SET 
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  is_system_role = EXCLUDED.is_system_role;

-- Add all permissions for SuperAdmin
INSERT INTO role_permissions (role_id, permission_key)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'users.view'),
  ('00000000-0000-0000-0000-000000000001', 'users.create'),
  ('00000000-0000-0000-0000-000000000001', 'users.edit'),
  ('00000000-0000-0000-0000-000000000001', 'users.delete'),
  ('00000000-0000-0000-0000-000000000001', 'companies.view'),
  ('00000000-0000-0000-0000-000000000001', 'companies.create'),
  ('00000000-0000-0000-0000-000000000001', 'companies.edit'),
  ('00000000-0000-0000-0000-000000000001', 'companies.delete'),
  ('00000000-0000-0000-0000-000000000001', 'roles.view'),
  ('00000000-0000-0000-0000-000000000001', 'roles.create'),
  ('00000000-0000-0000-0000-000000000001', 'roles.edit'),
  ('00000000-0000-0000-0000-000000000001', 'roles.delete'),
  ('00000000-0000-0000-0000-000000000001', 'content.view'),
  ('00000000-0000-0000-0000-000000000001', 'content.create'),
  ('00000000-0000-0000-0000-000000000001', 'content.edit'),
  ('00000000-0000-0000-0000-000000000001', 'content.delete'),
  ('00000000-0000-0000-0000-000000000001', 'system.manage'),
  ('00000000-0000-0000-0000-000000000001', 'system.audit'),
  ('00000000-0000-0000-0000-000000000001', 'system.settings')
ON CONFLICT (role_id, permission_key) DO NOTHING;

-- Ensure paul@theteam.net.au has the SuperAdmin role
DO $$ 
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM profiles 
  WHERE email = 'paul@theteam.net.au';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User with email paul@theteam.net.au not found';
  END IF;

  -- Assign SuperAdmin role with NULL company_id (system-wide)
  INSERT INTO user_roles (user_id, role_id, company_id)
  VALUES (v_user_id, '00000000-0000-0000-0000-000000000001', NULL)
  ON CONFLICT (user_id, role_id) DO NOTHING;
END $$;

-- Update RLS policies to allow system role access
DROP POLICY IF EXISTS "Users can view roles in their company" ON roles;
DROP POLICY IF EXISTS "Users can view roles" ON roles;
CREATE POLICY "Users can view roles"
  ON roles
  FOR SELECT
  TO authenticated
  USING (
    is_system_role = true OR
    id IN (
      SELECT role_id 
      FROM user_roles 
      WHERE user_id = auth.uid() 
      AND (company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
           OR company_id IS NULL)
    )
  );

-- Allow viewing system role permissions
DROP POLICY IF EXISTS "Users can view role permissions in their company" ON role_permissions;
DROP POLICY IF EXISTS "Users can view role permissions" ON role_permissions;
CREATE POLICY "Users can view role permissions"
  ON role_permissions
  FOR SELECT
  TO authenticated
  USING (
    role_id IN (
      SELECT id FROM roles WHERE is_system_role = true
      UNION
      SELECT role_id 
      FROM user_roles 
      WHERE user_id = auth.uid() 
      AND (company_id = (SELECT current_company_id FROM profiles WHERE id = auth.uid())
           OR company_id IS NULL)
    )
  );