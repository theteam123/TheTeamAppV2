/*
  # Content Management Schema

  1. New Tables
    - content
      - Basic content information
      - Links to company, tags, and role permissions
    - content_tags
      - Junction table for content-tag relationships
    - content_role_permissions
      - Stores role-specific permissions for content items

  2. Security
    - Enable RLS on all tables
    - Add policies for company-based access control
*/

-- Create content table
CREATE TABLE IF NOT EXISTS content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  url text NOT NULL,
  description text,
  content_type text NOT NULL,
  search_terms text[] DEFAULT '{}',
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create content_tags junction table
CREATE TABLE IF NOT EXISTS content_tags (
  content_id uuid REFERENCES content(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (content_id, tag_id)
);

-- Create content_role_permissions table
CREATE TABLE IF NOT EXISTS content_role_permissions (
  content_id uuid REFERENCES content(id) ON DELETE CASCADE,
  role_id uuid REFERENCES roles(id) ON DELETE CASCADE,
  can_view boolean DEFAULT false,
  can_edit boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (content_id, role_id)
);

-- Enable RLS
ALTER TABLE content ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_role_permissions ENABLE ROW LEVEL SECURITY;

-- Content policies
CREATE POLICY "Users can view content in their company"
  ON content
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies uc
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = content.company_id
    )
  );

CREATE POLICY "Users can manage content in their company"
  ON content
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies uc
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = content.company_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies uc
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = content.company_id
    )
  );

-- Content tags policies
CREATE POLICY "Users can view content tags in their company"
  ON content_tags
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_tags.content_id
      AND uc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage content tags in their company"
  ON content_tags
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_tags.content_id
      AND uc.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_tags.content_id
      AND uc.user_id = auth.uid()
    )
  );

-- Content role permissions policies
CREATE POLICY "Users can view content role permissions in their company"
  ON content_role_permissions
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_role_permissions.content_id
      AND uc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage content role permissions in their company"
  ON content_role_permissions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_role_permissions.content_id
      AND uc.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM content c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = content_role_permissions.content_id
      AND uc.user_id = auth.uid()
    )
  );

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_content_updated_at
  BEFORE UPDATE ON content
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();