-- Add archived_at column to companies table
ALTER TABLE companies
ADD COLUMN archived_at TIMESTAMPTZ DEFAULT NULL;

-- Create index for better performance on archived filtering
CREATE INDEX idx_companies_archived_at ON companies(archived_at);

-- Update the companies policies to handle archived companies
DROP POLICY IF EXISTS "Users can view companies they belong to" ON companies;
CREATE POLICY "Users can view companies they belong to"
  ON companies
  FOR SELECT
  TO authenticated
  USING (
    (archived_at IS NULL AND (
      has_system_role(auth.uid()) OR
      EXISTS (
        SELECT 1 FROM user_companies uc
        WHERE uc.company_id = id
        AND uc.user_id = auth.uid()
      )
    )) OR
    (archived_at IS NOT NULL AND has_system_role(auth.uid()))
  );

-- Create function to archive company
CREATE OR REPLACE FUNCTION archive_company(company_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE companies
  SET archived_at = NOW()
  WHERE id = company_id;
END;
$$;

-- Create function to restore company
CREATE OR REPLACE FUNCTION restore_company(company_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE companies
  SET archived_at = NULL
  WHERE id = company_id;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION archive_company(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION restore_company(UUID) TO authenticated; 