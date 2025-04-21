-- First, remove the company reference from the admin profile
UPDATE profiles
SET current_company_id = NULL
WHERE email = 'paul+app_admin@theteam.net.au';

-- Then, remove the company if it exists
DELETE FROM companies
WHERE id = 'db6d4487-c7c8-4840-b7c7-ed1f463a8783';

-- Verify the changes
SELECT 
    p.id,
    p.email,
    p.full_name,
    p.current_company_id,
    c.id as company_id
FROM profiles p
LEFT JOIN companies c ON p.current_company_id = c.id
WHERE p.email = 'paul+app_admin@theteam.net.au'; 