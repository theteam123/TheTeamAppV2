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
  INSERT INTO audit_log (
    action,
    performed_by,
    target_id,
    target_type,
    details
  ) VALUES (
    'ASSIGN_SUPERADMIN',
    user_id,
    user_id,
    'profiles',
    jsonb_build_object(
      'role_id', role_id,
      'action', 'Created and assigned SuperAdmin role'
    )
  );

END $$;