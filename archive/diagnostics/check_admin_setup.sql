-- Get user's profile and current company
WITH user_profile AS (
    SELECT id, email, full_name, current_company_id
    FROM profiles
    WHERE email = 'paul+company_admin@theteam.net.au'
)
SELECT 
    'Profile Info' as section,
    p.id::text as user_id,
    p.email,
    p.full_name,
    p.current_company_id
FROM user_profile p

UNION ALL

-- Check user-company associations
SELECT 
    'Company Associations' as section,
    p.id::text as user_id,
    uc.status::text as email,
    c.name as full_name,
    uc.company_id as current_company_id
FROM user_profile p
LEFT JOIN user_companies uc ON p.id = uc.user_id
LEFT JOIN companies c ON uc.company_id = c.id

UNION ALL

-- Check user roles
SELECT 
    'User Roles' as section,
    p.id::text as user_id,
    r.name as email,
    CASE WHEN r.is_system_role THEN 'System Role' ELSE 'Regular Role' END as full_name,
    ur.company_id as current_company_id
FROM user_profile p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id

UNION ALL

-- Check RLS policies
SELECT 
    'RLS Status' as section,
    tablename as user_id,
    CASE WHEN rowsecurity THEN 'Enabled' ELSE 'Disabled' END as email,
    NULL as full_name,
    NULL as current_company_id
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('companies', 'user_companies', 'user_roles'); 