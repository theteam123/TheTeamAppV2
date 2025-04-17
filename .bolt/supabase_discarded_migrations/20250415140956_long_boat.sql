/*
  # Initial Database Schema Setup

  1. Core Tables
    - profiles: User profiles with personal information
    - companies: Organization details
    - user_companies: Many-to-many relationship between users and companies
    - roles: User roles (Admin, Manager, etc.)
    - user_roles: Role assignments for users in companies
    - role_permissions: Permissions associated with roles

  2. Content Management
    - documents: Document storage and metadata
    - forms: Form definitions and configuration
    - form_submissions: Form response data
    - public_submitters: Anonymous form submitter information
    - tags: Content organization tags
    - categories: Content categorization

  3. Security
    - Row Level Security (RLS) policies for all tables
    - Default admin role and permissions
*/

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text,
  avatar_url text,
  current_company_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  website text,
  settings jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- User-Company relationship
CREATE TABLE IF NOT EXISTS user_companies (
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, company_id)
);

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  is_system_role boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- User-Role assignments
CREATE TABLE IF NOT EXISTS user_roles (
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, role_id, company_id)
);

-- Role permissions
CREATE TABLE IF NOT EXISTS role_permissions (
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  permission_key text NOT NULL,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (role_id, permission_key)
);

-- Documents table
CREATE TABLE IF NOT EXISTS documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  file_path text NOT NULL,
  size bigint NOT NULL,
  category text,
  tags text[],
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  uploaded_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Forms table
CREATE TABLE IF NOT EXISTS forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  fields jsonb NOT NULL,
  category text,
  is_public boolean DEFAULT false,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Form submissions
CREATE TABLE IF NOT EXISTS form_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id uuid REFERENCES forms(id) ON DELETE CASCADE,
  submitted_by uuid REFERENCES auth.users(id),
  public_submitter_id uuid REFERENCES public_submitters(id),
  data jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Public submitters
CREATE TABLE IF NOT EXISTS public_submitters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  color text NOT NULL,
  categories text[],
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  color text NOT NULL,
  parent_id uuid REFERENCES categories(id),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public_submitters ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Policies for companies
CREATE POLICY "Users can view companies they belong to"
  ON companies FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for user_companies
CREATE POLICY "Users can view their company associations"
  ON user_companies FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Policies for documents
CREATE POLICY "Users can view company documents"
  ON documents FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = documents.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for forms
CREATE POLICY "Users can view company forms"
  ON forms FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = forms.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Public users can view public forms"
  ON forms FOR SELECT
  TO anon
  USING (is_public = true);

-- Policies for form submissions
CREATE POLICY "Users can view company form submissions"
  ON form_submissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM forms
      JOIN user_companies ON user_companies.company_id = forms.company_id
      WHERE forms.id = form_submissions.form_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Insert default admin role
INSERT INTO roles (id, name, description, is_system_role)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Admin',
  'System administrator with full access',
  true
);

-- Insert default permissions for admin role
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
  ('00000000-0000-0000-0000-000000000001', 'roles.delete');