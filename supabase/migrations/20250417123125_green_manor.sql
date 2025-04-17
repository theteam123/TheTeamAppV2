/*
  # Multi-Tenant Schema Updates

  1. New Columns
    - Add company_slug to companies table
    - Add can_manage_companies to profiles table
    - Add selected_company_id to profiles table

  2. New Tables
    - Create audit_log table for tracking system changes
    - Add appropriate indexes and foreign key constraints

  3. Security
    - Enable RLS on audit_log table
    - Add policies for audit log access
*/

-- Add new columns to companies table
ALTER TABLE companies ADD COLUMN IF NOT EXISTS slug text UNIQUE;
CREATE INDEX IF NOT EXISTS idx_companies_slug ON companies(slug);

-- Add company management columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS can_manage_companies boolean DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS selected_company_id uuid REFERENCES companies(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_selected_company ON profiles(selected_company_id);

-- Create audit_log table
CREATE TABLE IF NOT EXISTS audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  performed_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  target_id uuid,
  target_type text NOT NULL,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  details jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  ip_address text,
  user_agent text
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_audit_log_company ON audit_log(company_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_performed_by ON audit_log(performed_by);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action);

-- Enable RLS
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can view audit logs for their company"
ON audit_log
FOR SELECT
TO authenticated
USING (
  company_id IN (
    SELECT company_id FROM user_companies
    WHERE user_id = auth.uid()
  )
);

-- Add trigger to automatically set company_id on audit_log entries
CREATE OR REPLACE FUNCTION set_audit_log_company_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.company_id := (
    SELECT current_company_id
    FROM profiles
    WHERE id = auth.uid()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER set_audit_log_company_id_trigger
  BEFORE INSERT ON audit_log
  FOR EACH ROW
  EXECUTE FUNCTION set_audit_log_company_id();

-- Add function to create audit log entries
CREATE OR REPLACE FUNCTION create_audit_log_entry(
  action text,
  target_id uuid,
  target_type text,
  details jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
  log_id uuid;
BEGIN
  INSERT INTO audit_log (
    action,
    performed_by,
    target_id,
    target_type,
    details,
    ip_address,
    user_agent
  )
  VALUES (
    action,
    auth.uid(),
    target_id,
    target_type,
    details,
    current_setting('request.headers')::json->>'x-forwarded-for',
    current_setting('request.headers')::json->>'user-agent'
  )
  RETURNING id INTO log_id;

  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;