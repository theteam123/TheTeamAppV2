-- Insert sample companies
INSERT INTO companies (id, name, website, created_at) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Acme Corporation', 'https://acme.example.com', now()),
  ('22222222-2222-2222-2222-222222222222', 'Tech Innovators', 'https://tech-innovators.example.com', now()),
  ('33333333-3333-3333-3333-333333333333', 'Global Solutions', 'https://global-solutions.example.com', now());

-- Insert roles
INSERT INTO roles (id, name, description, created_at) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Admin', 'System administrator with full access', now()),
  ('00000000-0000-0000-0000-000000000002', 'Manager', 'Company manager with limited admin access', now()),
  ('00000000-0000-0000-0000-000000000003', 'User', 'Regular user with basic access', now());

-- Insert role permissions
INSERT INTO role_permissions (role_id, permission_key, created_at) VALUES
  -- Admin permissions
  ('00000000-0000-0000-0000-000000000001', 'users.view', now()),
  ('00000000-0000-0000-0000-000000000001', 'users.create', now()),
  ('00000000-0000-0000-0000-000000000001', 'users.edit', now()),
  ('00000000-0000-0000-0000-000000000001', 'users.delete', now()),
  ('00000000-0000-0000-0000-000000000001', 'companies.view', now()),
  ('00000000-0000-0000-0000-000000000001', 'companies.create', now()),
  ('00000000-0000-0000-0000-000000000001', 'companies.edit', now()),
  ('00000000-0000-0000-0000-000000000001', 'companies.delete', now()),
  ('00000000-0000-0000-0000-000000000001', 'roles.view', now()),
  ('00000000-0000-0000-0000-000000000001', 'roles.create', now()),
  ('00000000-0000-0000-0000-000000000001', 'roles.edit', now()),
  ('00000000-0000-0000-0000-000000000001', 'roles.delete', now()),
  ('00000000-0000-0000-0000-000000000001', 'content.view', now()),
  ('00000000-0000-0000-0000-000000000001', 'content.create', now()),
  ('00000000-0000-0000-0000-000000000001', 'content.edit', now()),
  ('00000000-0000-0000-0000-000000000001', 'content.delete', now()),
  -- Manager permissions
  ('00000000-0000-0000-0000-000000000002', 'users.view', now()),
  ('00000000-0000-0000-0000-000000000002', 'users.create', now()),
  ('00000000-0000-0000-0000-000000000002', 'content.view', now()),
  ('00000000-0000-0000-0000-000000000002', 'content.create', now()),
  ('00000000-0000-0000-0000-000000000002', 'content.edit', now()),
  -- User permissions
  ('00000000-0000-0000-0000-000000000003', 'content.view', now()),
  ('00000000-0000-0000-0000-000000000003', 'content.create', now());

-- Insert categories
INSERT INTO categories (id, name, description, created_at) VALUES
  ('44444444-4444-4444-4444-444444444444', 'Documentation', 'Company documentation and guides', now()),
  ('55555555-5555-5555-5555-555555555555', 'Policies', 'Company policies and procedures', now()),
  ('66666666-6666-6666-6666-666666666666', 'Training', 'Training materials and resources', now());

-- Insert tags
INSERT INTO tags (id, name, created_at) VALUES
  ('77777777-7777-7777-7777-777777777777', 'Important', now()),
  ('88888888-8888-8888-8888-888888888888', 'Draft', now()),
  ('99999999-9999-9999-9999-999999999999', 'Archived', now());

-- Insert content
INSERT INTO content (id, title, description, category_id, company_ids, created_at) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Employee Handbook', 'Complete guide for employees', '55555555-5555-5555-5555-555555555555', ARRAY['11111111-1111-1111-1111-111111111111'], now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Security Policy', 'IT security guidelines', '55555555-5555-5555-5555-555555555555', ARRAY['22222222-2222-2222-2222-222222222222'], now()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Onboarding Guide', 'New employee onboarding process', '44444444-4444-4444-4444-444444444444', ARRAY['33333333-3333-3333-3333-333333333333'], now());

-- Insert content tags
INSERT INTO content_tags (content_id, tag_id, created_at) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '77777777-7777-7777-7777-777777777777', now()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '77777777-7777-7777-7777-777777777777', now()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '88888888-8888-8888-8888-888888888888', now());

-- Insert sample user profiles
-- Note: These users need to be created in auth.users first through the authentication system
DO $$
DECLARE
    user_id1 uuid := '12345678-1234-1234-1234-123456789012';
    user_id2 uuid := '23456789-2345-2345-2345-234567890123';
    user_id3 uuid := '34567890-3456-3456-3456-345678901234';
BEGIN
    -- Insert profiles
    INSERT INTO profiles (id, email, full_name, current_company_id, created_at) VALUES
      (user_id1, 'admin@example.com', 'Admin User', '11111111-1111-1111-1111-111111111111', now()),
      (user_id2, 'manager@example.com', 'Manager User', '22222222-2222-2222-2222-222222222222', now()),
      (user_id3, 'user@example.com', 'Regular User', '33333333-3333-3333-3333-333333333333', now());

    -- Insert user companies
    INSERT INTO user_companies (user_id, company_id, created_at) VALUES
      (user_id1, '11111111-1111-1111-1111-111111111111', now()),
      (user_id2, '22222222-2222-2222-2222-222222222222', now()),
      (user_id3, '33333333-3333-3333-3333-333333333333', now());

    -- Insert user roles
    INSERT INTO user_roles (user_id, role_id, created_at) VALUES
      (user_id1, '00000000-0000-0000-0000-000000000001', now()),
      (user_id2, '00000000-0000-0000-0000-000000000002', now()),
      (user_id3, '00000000-0000-0000-0000-000000000003', now());
END $$;