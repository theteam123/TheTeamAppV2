-- Check RLS policies for companies table
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename IN ('companies', 'user_companies')
ORDER BY tablename, policyname;

-- Check if user has App_Admin role
SELECT EXISTS (
    SELECT 1 
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = (
        SELECT id FROM profiles 
        WHERE email = 'paul+company_admin@theteam.net.au'
    )
    AND r.name = 'App_Admin'
    AND r.is_system_role = true
) as is_app_admin;

-- Check user-company associations
SELECT 
    uc.user_id,
    uc.company_id,
    uc.status,
    c.name as company_name,
    p.email as user_email
FROM user_companies uc
JOIN companies c ON uc.company_id = c.id
JOIN profiles p ON uc.user_id = p.id
WHERE p.email = 'paul+company_admin@theteam.net.au';

-- Check get_user_companies function result
SELECT * FROM get_user_companies(); 