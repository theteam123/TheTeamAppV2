-- Standardize company policies by removing duplicate policies and using consistent naming
BEGIN;

-- Drop existing policies to ensure clean slate
DROP POLICY IF EXISTS "Users can read companies they belong to" ON companies;
DROP POLICY IF EXISTS "Users can view companies they belong to" ON companies;
DROP POLICY IF EXISTS "Users can view their companies" ON companies;
DROP POLICY IF EXISTS "Users can read their companies" ON companies;

-- Create standardized read policy
CREATE POLICY "Users can read companies they belong to"
  ON companies FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = id
      AND user_companies.user_id = auth.uid()
    )
  );

COMMIT; 