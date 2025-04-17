/*
  # Employee Feedback Schema

  1. New Tables
    - employee_feedback
      - Stores employee feedback records
      - Links to profiles for employee and reviewer
      - Includes rating, status, and comments

  2. Security
    - Enable RLS
    - Add policies for company-based access control
    - Add role-based permissions
*/

-- Create employee_feedback table if it doesn't exist
CREATE TABLE IF NOT EXISTS employee_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  reviewer_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  rating integer CHECK (rating >= 1 AND rating <= 5),
  status text CHECK (status IN ('Pending', 'In Review', 'Completed')),
  recommendation text,
  comments text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE employee_feedback ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can view feedback in their company"
  ON employee_feedback
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies uc
      JOIN role_permissions rp ON rp.role_id IN (
        SELECT role_id FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = employee_feedback.company_id
      )
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = employee_feedback.company_id
      AND rp.permission_key IN ('VIEW_RECORDS', 'VIEW_EMPLOYEE_FEEDBACK')
    )
  );

CREATE POLICY "Users can manage feedback in their company"
  ON employee_feedback
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies uc
      JOIN role_permissions rp ON rp.role_id IN (
        SELECT role_id FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = employee_feedback.company_id
      )
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = employee_feedback.company_id
      AND rp.permission_key = 'MANAGE_EMPLOYEE_FEEDBACK'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies uc
      JOIN role_permissions rp ON rp.role_id IN (
        SELECT role_id FROM user_roles 
        WHERE user_id = auth.uid() 
        AND company_id = employee_feedback.company_id
      )
      WHERE uc.user_id = auth.uid()
      AND uc.company_id = employee_feedback.company_id
      AND rp.permission_key = 'MANAGE_EMPLOYEE_FEEDBACK'
    )
  );

-- Insert new permissions into role_permissions for the specified user's role
DO $$
DECLARE
  user_role_id uuid;
BEGIN
  -- Get the role ID for the user paul@theteam.net.au
  SELECT role_id INTO user_role_id
  FROM user_roles ur
  JOIN profiles p ON p.id = ur.user_id
  WHERE p.email = 'paul@theteam.net.au'
  LIMIT 1;

  -- Insert permissions if role found
  IF user_role_id IS NOT NULL THEN
    -- Insert VIEW_RECORDS permission
    INSERT INTO role_permissions (role_id, permission_key)
    VALUES (user_role_id, 'VIEW_RECORDS')
    ON CONFLICT (role_id, permission_key) DO NOTHING;

    -- Insert VIEW_EMPLOYEE_FEEDBACK permission
    INSERT INTO role_permissions (role_id, permission_key)
    VALUES (user_role_id, 'VIEW_EMPLOYEE_FEEDBACK')
    ON CONFLICT (role_id, permission_key) DO NOTHING;

    -- Insert MANAGE_EMPLOYEE_FEEDBACK permission
    INSERT INTO role_permissions (role_id, permission_key)
    VALUES (user_role_id, 'MANAGE_EMPLOYEE_FEEDBACK')
    ON CONFLICT (role_id, permission_key) DO NOTHING;
  END IF;
END $$;