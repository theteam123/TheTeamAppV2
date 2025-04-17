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

-- Create companies table
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  website text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  permission_key text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, role_id)
);

-- Create user_companies table
CREATE TABLE IF NOT EXISTS user_companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, company_id)
);

-- Create categories table first (since content references it)
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create content table (after categories)
CREATE TABLE IF NOT EXISTS content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  url text,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  company_ids uuid[] NOT NULL DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create content_tags table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS content_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id uuid REFERENCES content(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(content_id, tag_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE content ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_tags ENABLE ROW LEVEL SECURITY;

-- Create updated has_permission function with company_id parameter
CREATE OR REPLACE FUNCTION has_permission(user_id uuid, permission_key text, company_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN role_permissions rp ON ur.role_id = rp.role_id
    JOIN user_companies uc ON ur.user_id = uc.user_id
    WHERE ur.user_id = $1
    AND rp.permission_key = $2
    AND uc.company_id = $3;
  );
END;
$$;

-- Create RLS Policies

-- Profiles policies
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Companies policies
CREATE POLICY "Users can read companies they belong to"
  ON companies FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_id = auth.uid()
      AND company_id = id
    )
  );

-- Categories policies
CREATE POLICY "Users can read categories in their company"
  ON categories FOR SELECT
  TO authenticated
  USING (
    has_permission(auth.uid(), 'categories_read', company_id)
  );

CREATE POLICY "Users can create categories in their company"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    has_permission(auth.uid(), 'categories_write', company_id)
  );

CREATE POLICY "Users can update categories in their company"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    has_permission(auth.uid(), 'categories_write', company_id)
  )
  WITH CHECK (
    has_permission(auth.uid(), 'categories_write', company_id)
  );

-- Tags policies
CREATE POLICY "Users can read tags in their company"
  ON tags FOR SELECT
  TO authenticated
  USING (
    has_permission(auth.uid(), 'tags_read', company_id)
  );

CREATE POLICY "Users can create tags in their company"
  ON tags FOR INSERT
  TO authenticated
  WITH CHECK (
    has_permission(auth.uid(), 'tags_write', company_id)
  );

CREATE POLICY "Users can update tags in their company"
  ON tags FOR UPDATE
  TO authenticated
  USING (
    has_permission(auth.uid(), 'tags_write', company_id)
  )
  WITH CHECK (
    has_permission(auth.uid(), 'tags_write', company_id)
  );

-- Content policies
CREATE POLICY "Users can read content in their company"
  ON content FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM unnest(company_ids) company_id
      WHERE has_permission(auth.uid(), 'content_read', company_id)
    )
  );

CREATE POLICY "Users can create content in their company"
  ON content FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM unnest(company_ids) company_id
      WHERE has_permission(auth.uid(), 'content_write', company_id)
    )
  );

CREATE POLICY "Users can update content in their company"
  ON content FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM unnest(company_ids) company_id
      WHERE has_permission(auth.uid(), 'content_write', company_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM unnest(company_ids) company_id
      WHERE has_permission(auth.uid(), 'content_write', company_id)
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_current_company_id ON profiles(current_company_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_content_category_id ON content(category_id);
CREATE INDEX IF NOT EXISTS idx_content_tags_content_id ON content_tags(content_id);
CREATE INDEX IF NOT EXISTS idx_content_tags_tag_id ON content_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_categories_company_id ON categories(company_id);
CREATE INDEX IF NOT EXISTS idx_tags_company_id ON tags(company_id);
CREATE INDEX IF NOT EXISTS idx_user_companies_user_id ON user_companies(user_id);
CREATE INDEX IF NOT EXISTS idx_user_companies_company_id ON user_companies(company_id);