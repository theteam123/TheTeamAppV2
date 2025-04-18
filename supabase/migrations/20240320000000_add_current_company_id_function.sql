-- Create function to get current company ID from JWT
CREATE OR REPLACE FUNCTION current_company_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  company_id uuid;
BEGIN
  -- Get company_id from JWT claims
  SELECT (current_setting('request.jwt.claims', true)::json->>'company_id')::uuid INTO company_id;
  
  -- If no company_id in JWT, try to get it from user_companies table
  IF company_id IS NULL THEN
    SELECT uc.company_id INTO company_id
    FROM user_companies uc
    WHERE uc.user_id = auth.uid()
    LIMIT 1;
  END IF;
  
  RETURN company_id;
END;
$$; 