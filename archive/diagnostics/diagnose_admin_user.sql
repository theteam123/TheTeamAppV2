-- Get user ID from email
WITH user_info AS (
    SELECT id, email, full_name, current_company_id
    FROM profiles
    WHERE email = 'paul+company_admin@theteam.net.au'
)
-- Check user's profile and all company associations
SELECT 
    'Profile & Companies' as check_type,
    p.id as user_id,
    p.email,
    p.full_name,
    p.current_company_id,
    c.name as company_name,
    uc.status as company_status,
    uc.last_login_at
FROM user_info p
LEFT JOIN companies c ON p.current_company_id = c.id
LEFT JOIN user_companies uc ON p.id = uc.user_id
LEFT JOIN companies c2 ON uc.company_id = c2.id

UNION ALL

-- Check all roles for this user
SELECT 
    'Roles' as check_type,
    p.id as user_id,
    p.email,
    r.name as full_name,
    NULL as current_company_id,
    NULL as company_name,
    NULL as company_status,
    NULL as last_login_at
FROM user_info p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id;

-- Check RLS is enabled
SELECT 
    'RLS Check' as check_type,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('companies', 'user_companies'); 