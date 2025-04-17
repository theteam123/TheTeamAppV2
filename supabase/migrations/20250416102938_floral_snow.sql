/*
  # Fix foreign key relationships for documents and categories

  1. Changes
    - Add foreign key relationship between documents and profiles
    - Add category_tags junction table for categories and tags
    - Add appropriate RLS policies

  2. Security
    - Enable RLS on category_tags table
    - Add policies for authenticated users
*/

-- Create category_tags junction table
CREATE TABLE IF NOT EXISTS category_tags (
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (category_id, tag_id)
);

-- Enable RLS
ALTER TABLE category_tags ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can manage category tags"
  ON category_tags
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM categories c
      JOIN user_companies uc ON uc.company_id = c.company_id
      WHERE c.id = category_tags.category_id
      AND uc.user_id = auth.uid()
    )
  );

-- Ensure documents.uploaded_by references profiles.id
ALTER TABLE documents
  DROP CONSTRAINT IF EXISTS documents_uploaded_by_fkey,
  ADD CONSTRAINT documents_uploaded_by_fkey
  FOREIGN KEY (uploaded_by)
  REFERENCES profiles(id)
  ON DELETE SET NULL;