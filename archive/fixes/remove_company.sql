-- First, remove any user_company associations
DELETE FROM user_companies
WHERE company_id = 'db6d4487-c7c8-4840-b7c7-ed1f463a8783';

-- Then remove the company
DELETE FROM companies
WHERE id = 'db6d4487-c7c8-4840-b7c7-ed1f463a8783';

-- Verify the company is removed
SELECT 
    c.id,
    c.name,
    c.description
FROM companies c
WHERE c.id = 'db6d4487-c7c8-4840-b7c7-ed1f463a8783'; 