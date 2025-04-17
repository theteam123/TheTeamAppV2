/*
  # Add company_id to roles table

  1. Changes
    - Add `company_id` column to `roles` table
    - Add foreign key constraint to reference companies table
    - Add index on company_id for better query performance
    - Update RLS policies to ensure proper company-based access

  2. Security
    - Maintain existing RLS policies
    - Add company-based filtering to ensure roles are only accessible within their company
*/

-- Add company_id column
ALTER TABLE roles 
ADD COLUMN IF NOT EXISTS company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_roles_company_id ON roles(company_id);

-- Update RLS policies
DROP POLICY IF EXISTS "Allow all access to authenticated users" ON roles;

CREATE POLICY "Users can access roles in their companies"
ON roles
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_companies
    WHERE user_companies.company_id = roles.company_id
    AND user_companies.user_id = auth.uid()
  )
);