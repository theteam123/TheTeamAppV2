-- Update RLS policies for user_companies table
ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own company associations
CREATE POLICY "Users can read their own company associations"
ON user_companies
FOR SELECT
USING (
  auth.uid() = user_id
  OR EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.company_id = user_companies.company_id
    AND ur.role_id IN (
      SELECT id FROM roles 
      WHERE name IN ('SuperAdmin', 'Admin')
    )
  )
);

-- Allow users to update their own company associations
CREATE POLICY "Users can update their own company associations"
ON user_companies
FOR UPDATE
USING (
  auth.uid() = user_id
  OR EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.company_id = user_companies.company_id
    AND ur.role_id IN (
      SELECT id FROM roles 
      WHERE name IN ('SuperAdmin', 'Admin')
    )
  )
);

-- Update RLS policies for profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "Users can read their own profile"
ON profiles
FOR SELECT
USING (
  auth.uid() = id
  OR EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN user_companies uc ON ur.user_id = auth.uid() 
    AND ur.company_id = uc.company_id
    WHERE uc.user_id = profiles.id
    AND ur.role_id IN (
      SELECT id FROM roles 
      WHERE name IN ('SuperAdmin', 'Admin')
    )
  )
);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile"
ON profiles
FOR UPDATE
USING (
  auth.uid() = id
  OR EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN user_companies uc ON ur.user_id = auth.uid() 
    AND ur.company_id = uc.company_id
    WHERE uc.user_id = profiles.id
    AND ur.role_id IN (
      SELECT id FROM roles 
      WHERE name IN ('SuperAdmin', 'Admin')
    )
  )
); 