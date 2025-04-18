/*
  # Company Selection and Management Policies

  1. Updates
    - Add policies for company management
    - Add super user access controls
    - Add audit logging for company switches
    - Update profile policies for company selection

  2. Security
    - Ensure proper access control for company management
    - Add super user capabilities
    - Track company switches in audit log
*/

-- Add policy for super users to manage companies
CREATE POLICY "Super users can manage all companies"
  ON companies
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND can_manage_companies = true
    )
  );

-- Add policy for updating current company
CREATE POLICY "Users can update their current company"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND (
      -- Allow setting current_company_id only to companies user belongs to
      (
        NEW.current_company_id IS NULL OR
        EXISTS (
          SELECT 1 FROM user_companies
          WHERE user_id = auth.uid()
          AND company_id = NEW.current_company_id
        )
      )
    )
  );

-- Add policy for audit logging company switches
CREATE POLICY "Log company switches"
  ON audit_log
  FOR INSERT
  TO authenticated
  WITH CHECK (
    action = 'company_switch' AND
    performed_by = auth.uid() AND
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_id = auth.uid()
      AND company_id = NEW.company_id
    )
  );

-- Add function to log company switches
CREATE OR REPLACE FUNCTION log_company_switch()
RETURNS trigger AS $$
BEGIN
  IF OLD.current_company_id IS DISTINCT FROM NEW.current_company_id THEN
    INSERT INTO audit_log (
      action,
      performed_by,
      target_id,
      target_type,
      company_id,
      details
    ) VALUES (
      'company_switch',
      NEW.id,
      NEW.current_company_id,
      'company',
      NEW.current_company_id,
      jsonb_build_object(
        'previous_company_id', OLD.current_company_id,
        'new_company_id', NEW.current_company_id
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add trigger for company switches
DROP TRIGGER IF EXISTS company_switch_audit ON profiles;
CREATE TRIGGER company_switch_audit
  AFTER UPDATE OF current_company_id
  ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION log_company_switch();

-- Add index for company management
CREATE INDEX IF NOT EXISTS idx_profiles_can_manage_companies
  ON profiles(can_manage_companies)
  WHERE can_manage_companies = true; 