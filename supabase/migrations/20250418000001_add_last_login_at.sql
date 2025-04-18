/*
  # Add Last Login Tracking

  1. Changes
    - Add last_login_at column to user_companies table
    - Add trigger to update last_login_at on login
    - Add index for better query performance
    - Add proper RLS policies
*/

-- Add last_login_at column
ALTER TABLE user_companies
ADD COLUMN IF NOT EXISTS last_login_at timestamptz;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_user_companies_last_login 
ON user_companies(company_id, last_login_at DESC);

-- Add function to update last login
CREATE OR REPLACE FUNCTION update_last_login()
RETURNS TRIGGER AS $$
BEGIN
  -- Update last_login_at for all companies the user belongs to
  -- Only update if the user has company associations
  IF EXISTS (
    SELECT 1 FROM user_companies
    WHERE user_id = NEW.id
  ) THEN
    UPDATE user_companies
    SET last_login_at = now()
    WHERE user_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add trigger for auth.users table
DROP TRIGGER IF EXISTS update_last_login_trigger ON auth.users;
CREATE TRIGGER update_last_login_trigger
  AFTER UPDATE OF last_sign_in_at
  ON auth.users
  FOR EACH ROW
  WHEN (NEW.last_sign_in_at IS DISTINCT FROM OLD.last_sign_in_at)
  EXECUTE FUNCTION update_last_login();

-- Add RLS policies for last_login_at
CREATE POLICY "Users can update their own last login"
ON user_companies
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Add comment to document the column
COMMENT ON COLUMN user_companies.last_login_at IS 'Timestamp of the user''s last login to this company'; 