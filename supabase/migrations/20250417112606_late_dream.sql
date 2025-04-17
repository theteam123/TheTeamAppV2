/*
  # Fix Content Table Structure

  1. Changes
    - Add updated_by column to content table
    - Enable RLS on content table
    - Add appropriate RLS policies
    - Add performance indexes

  2. Security
    - Enable RLS
    - Add policies for authenticated users
    - Ensure proper foreign key relationships
*/

-- First ensure the content table exists
CREATE TABLE IF NOT EXISTS content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  url text,
  description text,
  content_type text,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add updated_by column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'content' AND column_name = 'updated_by'
  ) THEN
    ALTER TABLE content ADD COLUMN updated_by uuid REFERENCES profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Enable RLS
ALTER TABLE content ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can view content in their company"
  ON content
  FOR SELECT
  TO authenticated
  USING (
    company_id = (
      SELECT current_company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can manage content in their company"
  ON content
  FOR ALL
  TO authenticated
  USING (
    company_id = (
      SELECT current_company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
  )
  WITH CHECK (
    company_id = (
      SELECT current_company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
  );

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_content_updated_by ON content(updated_by);
CREATE INDEX IF NOT EXISTS idx_content_company_id ON content(company_id);
CREATE INDEX IF NOT EXISTS idx_content_updated_at ON content(updated_at DESC);