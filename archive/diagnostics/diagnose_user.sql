-- Check user's profile and company associations
SELECT 
    p.id as user_id,
    p.email,
    p.full_name,
    p.current_company_id,
    c.name as company_name,
    uc.status as company_status,
    uc.last_login_at,
    r.name as role_name,
    r.is_system_role
FROM profiles p
LEFT JOIN companies c ON p.current_company_id = c.id
LEFT JOIN user_companies uc ON p.id = uc.user_id AND p.current_company_id = uc.company_id
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE p.id = '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78';

-- Check if the company exists
SELECT 
    id,
    name,
    website,
    settings,
    created_at,
    updated_at
FROM companies
WHERE id = '33333333-3333-3333-3333-333333333333';

-- Check all user-company associations for this user
SELECT 
    uc.user_id,
    uc.company_id,
    c.name as company_name,
    uc.status,
    uc.last_login_at
FROM user_companies uc
JOIN companies c ON uc.company_id = c.id
WHERE uc.user_id = '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78';

-- Check all roles for this user
SELECT 
    ur.user_id,
    ur.role_id,
    r.name as role_name,
    r.is_system_role
FROM user_roles ur
JOIN roles r ON ur.role_id = r.id
WHERE ur.user_id = '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78'; 