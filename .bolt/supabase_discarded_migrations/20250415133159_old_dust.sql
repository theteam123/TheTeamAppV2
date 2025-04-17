/*
  # Seed Initial Data

  1. Initial Data
    - Create default roles (Admin, Manager, User)
    - Create basic permissions
    - Assign permissions to roles
*/

-- Insert default roles
INSERT INTO roles (id, name, description) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Admin', 'Full system access'),
  ('00000000-0000-0000-0000-000000000002', 'Manager', 'Company management access'),
  ('00000000-0000-0000-0000-000000000003', 'User', 'Basic user access')
ON CONFLICT (id) DO NOTHING;

-- Insert basic permissions
INSERT INTO permissions (key, description) VALUES
  ('users:read', 'View users'),
  ('users:write', 'Create and update users'),
  ('users:delete', 'Delete users'),
  ('companies:read', 'View companies'),
  ('companies:write', 'Create and update companies'),
  ('companies:delete', 'Delete companies'),
  ('roles:read', 'View roles'),
  ('roles:write', 'Create and update roles'),
  ('roles:delete', 'Delete roles'),
  ('documents:read', 'View documents'),
  ('documents:write', 'Create and update documents'),
  ('documents:delete', 'Delete documents')
ON CONFLICT (key) DO NOTHING;

-- Assign permissions to roles
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
  '00000000-0000-0000-0000-000000000001', -- Admin role
  id 
FROM permissions
ON CONFLICT DO NOTHING;

-- Manager permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
  '00000000-0000-0000-0000-000000000002', -- Manager role
  id 
FROM permissions 
WHERE key IN (
  'users:read',
  'users:write',
  'companies:read',
  'documents:read',
  'documents:write'
)
ON CONFLICT DO NOTHING;

-- User permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT 
  '00000000-0000-0000-0000-000000000003', -- User role
  id 
FROM permissions 
WHERE key IN (
  'documents:read',
  'documents:write'
)
ON CONFLICT DO NOTHING;