DO $$
DECLARE
    admin_role_id UUID;
    admin_user_id UUID;
    has_manage_users BOOLEAN;
    has_manage_roles BOOLEAN;
    has_manage_companies BOOLEAN;
    is_system_role_flag BOOLEAN;
BEGIN
    -- Get App_Admin role ID
    SELECT id INTO admin_role_id
    FROM roles
    WHERE name = 'App_Admin';
    
    IF admin_role_id IS NULL THEN
        RAISE EXCEPTION 'App_Admin role not found';
    END IF;
    
    -- Verify role is a system role
    SELECT is_system_role INTO is_system_role_flag
    FROM roles
    WHERE id = admin_role_id;
    
    IF NOT is_system_role_flag THEN
        RAISE EXCEPTION 'App_Admin role is not marked as a system role';
    END IF;
    
    -- Verify role permissions
    SELECT 
        EXISTS(SELECT 1 FROM role_permissions WHERE role_id = admin_role_id AND permission = 'manage_users'),
        EXISTS(SELECT 1 FROM role_permissions WHERE role_id = admin_role_id AND permission = 'manage_roles'),
        EXISTS(SELECT 1 FROM role_permissions WHERE role_id = admin_role_id AND permission = 'manage_companies')
    INTO has_manage_users, has_manage_roles, has_manage_companies;
    
    IF NOT (has_manage_users AND has_manage_roles AND has_manage_companies) THEN
        RAISE EXCEPTION 'App_Admin role missing required permissions. Current permissions: manage_users=%, manage_roles=%, manage_companies=%',
            has_manage_users, has_manage_roles, has_manage_companies;
    END IF;
    
    -- Get admin user ID (assuming it's the first user with App_Admin role)
    SELECT user_id INTO admin_user_id
    FROM user_roles
    WHERE role_id = admin_role_id
    LIMIT 1;
    
    IF admin_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found with App_Admin role';
    END IF;
    
    -- Verify user has a profile
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = admin_user_id) THEN
        RAISE EXCEPTION 'Admin user does not have a profile';
    END IF;
    
    -- Verify user has a company assignment
    IF NOT EXISTS (SELECT 1 FROM user_companies WHERE user_id = admin_user_id) THEN
        RAISE EXCEPTION 'Admin user is not assigned to any company';
    END IF;
    
    -- Output verification results
    RAISE NOTICE 'Verification successful:';
    RAISE NOTICE '  - App_Admin role ID: %', admin_role_id;
    RAISE NOTICE '  - Admin user ID: %', admin_user_id;
    RAISE NOTICE '  - Is system role: %', is_system_role_flag;
    RAISE NOTICE '  - Has manage_users permission: %', has_manage_users;
    RAISE NOTICE '  - Has manage_roles permission: %', has_manage_roles;
    RAISE NOTICE '  - Has manage_companies permission: %', has_manage_companies;
    
    -- Output user details
    RAISE NOTICE 'Admin user details:';
    RAISE NOTICE '  - Email: %', (SELECT email FROM profiles WHERE id = admin_user_id);
    RAISE NOTICE '  - Full name: %', (SELECT full_name FROM profiles WHERE id = admin_user_id);
    RAISE NOTICE '  - Current company: %', (
        SELECT c.name 
        FROM companies c 
        JOIN user_companies uc ON c.id = uc.company_id 
        WHERE uc.user_id = admin_user_id 
        LIMIT 1
    );
END $$; 