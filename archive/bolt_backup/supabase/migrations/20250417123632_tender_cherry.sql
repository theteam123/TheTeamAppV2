-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action TEXT NOT NULL,
  target_id UUID,
  target_type TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add RLS policy for audit_logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own audit logs"
  ON audit_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "System can insert audit logs"
  ON audit_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_audit_logs_updated_at
  BEFORE UPDATE ON audit_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- First verify all policies exist before dropping
DO $$
BEGIN
  -- Verify companies policies
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'companies' AND policyname = 'Users can read their companies') THEN
    RAISE WARNING 'Policy "Users can read their companies" does not exist';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'companies' AND policyname = 'Admins can read all companies') THEN
    RAISE WARNING 'Policy "Admins can read all companies" does not exist';
  END IF;

  -- Verify user_roles policies
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_roles' AND policyname = 'Users can view their roles') THEN
    RAISE WARNING 'Policy "Users can view their roles" does not exist';
  END IF;

  -- Verify audit_logs policies
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'audit_logs' AND policyname = 'Users can view their own audit logs') THEN
    RAISE WARNING 'Policy "Users can view their own audit logs" does not exist';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'audit_logs' AND policyname = 'Admins can view all audit logs') THEN
    RAISE WARNING 'Policy "Admins can view all audit logs" does not exist';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'audit_logs' AND policyname = 'System can insert audit logs') THEN
    RAISE WARNING 'Policy "System can insert audit logs" does not exist';
  END IF;
END;
$$;

-- Drop all policies with explicit names
DO $$
BEGIN
  -- Companies policies
  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Users can read their companies" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Users can read their companies": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Admins can read all companies" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Admins can read all companies": %', SQLERRM;
  END;

  -- User roles policies
  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Users can view their roles" ON user_roles';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Users can view their roles": %', SQLERRM;
  END;

  -- Audit logs policies
  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Users can view their own audit logs" ON audit_logs';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Users can view their own audit logs": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Admins can view all audit logs" ON audit_logs';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Admins can view all audit logs": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "System can insert audit logs" ON audit_logs';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "System can insert audit logs": %', SQLERRM;
  END;

  -- Drop any remaining policies
  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Enable read access for all users" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Enable read access for all users": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Enable insert for authenticated users only": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Enable update for users based on email" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Enable update for users based on email": %', SQLERRM;
  END;

  BEGIN
    EXECUTE 'DROP POLICY IF EXISTS "Enable delete for users based on email" ON companies';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error dropping "Enable delete for users based on email": %', SQLERRM;
  END;
END;
$$;

-- Verify all policies were dropped
DO $$
DECLARE
  policy_count integer;
  policy_record record;
BEGIN
  -- Check companies policies
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies 
  WHERE tablename = 'companies';
  
  IF policy_count > 0 THEN
    RAISE WARNING 'Found % remaining policies on companies table', policy_count;
    -- List remaining policies
    FOR policy_record IN 
      SELECT policyname 
      FROM pg_policies 
      WHERE tablename = 'companies'
    LOOP
      RAISE WARNING 'Remaining policy: %', policy_record.policyname;
      BEGIN
        EXECUTE format('DROP POLICY IF EXISTS %I ON companies', policy_record.policyname);
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error dropping policy %: %', policy_record.policyname, SQLERRM;
      END;
    END LOOP;
  END IF;

  -- Check user_roles policies
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies 
  WHERE tablename = 'user_roles';
  
  IF policy_count > 0 THEN
    RAISE WARNING 'Found % remaining policies on user_roles table', policy_count;
    -- List remaining policies
    FOR policy_record IN 
      SELECT policyname 
      FROM pg_policies 
      WHERE tablename = 'user_roles'
    LOOP
      RAISE WARNING 'Remaining policy: %', policy_record.policyname;
      BEGIN
        EXECUTE format('DROP POLICY IF EXISTS %I ON user_roles', policy_record.policyname);
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error dropping policy %: %', policy_record.policyname, SQLERRM;
      END;
    END LOOP;
  END IF;

  -- Check audit_logs policies
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies 
  WHERE tablename = 'audit_logs';
  
  IF policy_count > 0 THEN
    RAISE WARNING 'Found % remaining policies on audit_logs table', policy_count;
    -- List remaining policies
    FOR policy_record IN 
      SELECT policyname 
      FROM pg_policies 
      WHERE tablename = 'audit_logs'
    LOOP
      RAISE WARNING 'Remaining policy: %', policy_record.policyname;
      BEGIN
        EXECUTE format('DROP POLICY IF EXISTS %I ON audit_logs', policy_record.policyname);
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error dropping policy %: %', policy_record.policyname, SQLERRM;
      END;
    END LOOP;
  END IF;

  -- Final check
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies 
  WHERE tablename IN ('companies', 'user_roles', 'audit_logs');
  
  IF policy_count > 0 THEN
    RAISE EXCEPTION 'Could not drop all policies. % policies remain', policy_count;
  END IF;
END;
$$;

-- Now drop the functions with error handling
DO $$
BEGIN
  BEGIN
    DROP FUNCTION IF EXISTS has_company_access(uuid);
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping has_company_access(uuid): %', SQLERRM;
  END;

  BEGIN
    DROP FUNCTION IF EXISTS has_company_access(uuid, uuid);
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping has_company_access(uuid, uuid): %', SQLERRM;
  END;

  BEGIN
    DROP FUNCTION IF EXISTS has_role(uuid, text);
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping has_role(uuid, text): %', SQLERRM;
  END;

  BEGIN
    DROP FUNCTION IF EXISTS is_app_admin();
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping is_app_admin(): %', SQLERRM;
  END;

  BEGIN
    DROP FUNCTION IF EXISTS has_permission(uuid, text);
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping has_permission(uuid, text): %', SQLERRM;
  END;

  BEGIN
    DROP FUNCTION IF EXISTS has_system_role(uuid);
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error dropping has_system_role(uuid): %', SQLERRM;
  END;
END;
$$;

-- Verify all functions were dropped
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'has_company_access') THEN
    RAISE EXCEPTION 'has_company_access function still exists';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'has_role') THEN
    RAISE EXCEPTION 'has_role function still exists';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_app_admin') THEN
    RAISE EXCEPTION 'is_app_admin function still exists';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'has_permission') THEN
    RAISE EXCEPTION 'has_permission function still exists';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'has_system_role') THEN
    RAISE EXCEPTION 'has_system_role function still exists';
  END IF;
END;
$$;

/*
  # Create SuperAdmin Role and Assignment

  1. New Role
    - Create SuperAdmin system role with all permissions
    - Set up role permissions for complete system access

  2. User Assignment
    - Assign SuperAdmin role to paul@theteam.net.au
    - Grant company management privileges

  3. Security
    - Role is marked as system role for special handling
    - Includes all available permissions
*/

-- First, ensure the user exists and get their ID
DO $$ 
DECLARE
  user_id uuid;
  role_id uuid;
BEGIN
  -- Get user ID from profiles table
  SELECT id INTO user_id 
  FROM profiles 
  WHERE email = 'paul@theteam.net.au';

  IF user_id IS NULL THEN
    RAISE EXCEPTION 'User with email paul@theteam.net.au not found';
  END IF;

  -- Create SuperAdmin role
  INSERT INTO roles (
    name,
    description,
    is_system_role,
    company_id
  ) VALUES (
    'SuperAdmin',
    'Super Administrator with complete system access',
    true,
    NULL -- System roles have no company_id
  ) RETURNING id INTO role_id;

  -- Add all permissions
  INSERT INTO role_permissions (role_id, permission_key) VALUES
    -- User Management
    (role_id, 'users.view'),
    (role_id, 'users.create'),
    (role_id, 'users.edit'),
    (role_id, 'users.delete'),
    -- Company Management
    (role_id, 'companies.view'),
    (role_id, 'companies.create'),
    (role_id, 'companies.edit'),
    (role_id, 'companies.delete'),
    -- Role Management
    (role_id, 'roles.view'),
    (role_id, 'roles.create'),
    (role_id, 'roles.edit'),
    (role_id, 'roles.delete'),
    -- Content Management
    (role_id, 'content.view'),
    (role_id, 'content.create'),
    (role_id, 'content.edit'),
    (role_id, 'content.delete'),
    -- System Management
    (role_id, 'system.manage'),
    (role_id, 'system.audit'),
    (role_id, 'system.settings');

  -- Update user profile to enable company management
  UPDATE profiles 
  SET can_manage_companies = true
  WHERE id = user_id;

  -- Insert audit log entry directly
  INSERT INTO audit_logs (
    action,
    target_id,
    target_type,
    user_id,
    details
  ) VALUES (
    'CREATE',
    role_id,
    'role',
    user_id,
    jsonb_build_object(
      'role_name', 'SuperAdmin',
      'permissions', ARRAY[
        'users.view', 'users.create', 'users.edit', 'users.delete',
        'companies.view', 'companies.create', 'companies.edit', 'companies.delete',
        'roles.view', 'roles.create', 'roles.edit', 'roles.delete',
        'content.view', 'content.create', 'content.edit', 'content.delete',
        'system.manage', 'system.audit', 'system.settings'
      ]
    )
  );
END $$;

-- Ensure App_Admin role exists and is assigned to the admin user
DO $$ 
DECLARE
  user_id uuid := '9dcfbee0-4f72-472d-8c9b-d4bd2de90abe';
  role_id uuid;
BEGIN
  -- Get or create App_Admin role
  SELECT id INTO role_id
  FROM roles
  WHERE name = 'App_Admin';

  IF role_id IS NULL THEN
    -- Create App_Admin role if it doesn't exist
    INSERT INTO roles (
      name,
      description,
      is_system_role,
      company_id
    ) VALUES (
      'App_Admin',
      'Application Administrator with full access',
      true,
      NULL
    ) RETURNING id INTO role_id;
  END IF;

  -- Assign App_Admin role to user
  INSERT INTO user_roles (
    user_id,
    role_id,
    company_id
  ) VALUES (
    user_id,
    role_id,
    NULL
  ) ON CONFLICT (user_id, role_id, company_id) DO NOTHING;

  -- Add all permissions to App_Admin role
  INSERT INTO role_permissions (role_id, permission_key) VALUES
    -- User Management
    (role_id, 'users.view'),
    (role_id, 'users.create'),
    (role_id, 'users.edit'),
    (role_id, 'users.delete'),
    -- Company Management
    (role_id, 'companies.view'),
    (role_id, 'companies.create'),
    (role_id, 'companies.edit'),
    (role_id, 'companies.delete'),
    -- Role Management
    (role_id, 'roles.view'),
    (role_id, 'roles.create'),
    (role_id, 'roles.edit'),
    (role_id, 'roles.delete'),
    -- Content Management
    (role_id, 'content.view'),
    (role_id, 'content.create'),
    (role_id, 'content.edit'),
    (role_id, 'content.delete'),
    -- System Management
    (role_id, 'system.manage'),
    (role_id, 'system.audit'),
    (role_id, 'system.settings')
  ON CONFLICT (role_id, permission_key) DO NOTHING;

  -- Update user profile to enable company management
  UPDATE profiles 
  SET can_manage_companies = true
  WHERE id = user_id;

  -- Insert audit log entry
  INSERT INTO audit_logs (
    action,
    target_id,
    target_type,
    user_id,
    details
  ) VALUES (
    'CREATE',
    role_id,
    'role',
    user_id,
    jsonb_build_object(
      'role_name', 'App_Admin',
      'permissions', ARRAY[
        'users.view', 'users.create', 'users.edit', 'users.delete',
        'companies.view', 'companies.create', 'companies.edit', 'companies.delete',
        'roles.view', 'roles.create', 'roles.edit', 'roles.delete',
        'content.view', 'content.create', 'content.edit', 'content.delete',
        'system.manage', 'system.audit', 'system.settings'
      ]
    )
  );
END $$; 