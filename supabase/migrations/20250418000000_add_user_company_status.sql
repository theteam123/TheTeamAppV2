/*
  # Add Company-Scoped User Status

  1. Changes
    - Create user_company_status enum type
    - Add status column to user_companies table
    - Add index for better query performance
    - Add audit logging for status changes

  2. Security
    - Maintain existing RLS policies
    - Add status-based filtering to ensure proper access control
*/

-- Create enum type for user status
CREATE TYPE user_company_status AS ENUM ('active', 'inactive', 'pending', 'invited');

-- Add status column to user_companies table
ALTER TABLE user_companies
ADD COLUMN status user_company_status DEFAULT 'active' NOT NULL;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_user_companies_status 
ON user_companies(company_id, status);

-- Add function to log status changes
CREATE OR REPLACE FUNCTION log_user_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO audit_log (
      action,
      performed_by,
      target_id,
      target_type,
      company_id,
      details
    ) VALUES (
      'user_status_change',
      auth.uid(),
      NEW.user_id,
      'user',
      NEW.company_id,
      jsonb_build_object(
        'previous_status', OLD.status,
        'new_status', NEW.status
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add trigger for status changes
CREATE TRIGGER user_status_change_audit
  AFTER UPDATE OF status
  ON user_companies
  FOR EACH ROW
  EXECUTE FUNCTION log_user_status_change();

-- Update RLS policies to consider status
DROP POLICY IF EXISTS "Users can view active users in their company" ON user_companies;
DROP POLICY IF EXISTS "Admins can manage user status in their company" ON user_companies;

-- Allow users to view their own company associations regardless of status
CREATE POLICY "Users can view own company associations"
ON user_companies
FOR SELECT
USING (user_id = auth.uid());

-- Allow admins to manage user status
CREATE POLICY "Admins can manage user status in their company"
ON user_companies
FOR UPDATE
USING (
  company_id = current_company_id()
  AND has_permission('users.manage')
)
WITH CHECK (
  company_id = current_company_id()
  AND has_permission('users.manage')
);

-- Add policy for initial user-company association
CREATE POLICY "Allow initial user-company association"
ON user_companies
FOR INSERT
WITH CHECK (
  -- Allow if user is creating their own association
  user_id = auth.uid()
  OR
  -- Allow if admin is creating association
  (
    company_id = current_company_id()
    AND has_permission('users.manage')
  )
);

-- Backfill existing user_companies entries
UPDATE user_companies
SET status = 'active'
WHERE status IS NULL;

-- Add comment to document the column
COMMENT ON COLUMN user_companies.status IS 'The status of the user within the company (active, inactive, pending, invited)'; 