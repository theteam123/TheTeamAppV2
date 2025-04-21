DO $$
DECLARE
    v_user_id UUID := '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78';
    v_company_id UUID := '33333333-3333-3333-3333-333333333333';
    profile_exists BOOLEAN;
    company_exists BOOLEAN;
    user_company_exists BOOLEAN;
    user_role_exists BOOLEAN;
    current_company_id UUID;
BEGIN
    -- Check if profile exists
    SELECT EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = v_user_id
    ) INTO profile_exists;

    -- Check if company exists
    SELECT EXISTS (
        SELECT 1 FROM companies c
        WHERE c.id = v_company_id
    ) INTO company_exists;

    -- Check if user-company association exists
    SELECT EXISTS (
        SELECT 1 FROM user_companies uc
        WHERE uc.user_id = v_user_id AND uc.company_id = v_company_id
    ) INTO user_company_exists;

    -- Check if user has any roles
    SELECT EXISTS (
        SELECT 1 FROM user_roles ur
        WHERE ur.user_id = v_user_id
    ) INTO user_role_exists;

    -- Get current company ID from profile
    SELECT p.current_company_id 
    INTO current_company_id
    FROM profiles p
    WHERE p.id = v_user_id;

    -- Output current state
    RAISE NOTICE 'Profile exists: %', profile_exists;
    RAISE NOTICE 'Company exists: %', company_exists;
    RAISE NOTICE 'User-Company association exists: %', user_company_exists;
    RAISE NOTICE 'User has roles: %', user_role_exists;
    RAISE NOTICE 'Current company ID in profile: %', current_company_id;

    -- Output detailed information if profile exists
    IF profile_exists THEN
        RAISE NOTICE 'Profile details:';
        RAISE NOTICE '  Email: %', (SELECT email FROM profiles WHERE id = v_user_id);
        RAISE NOTICE '  Full Name: %', (SELECT full_name FROM profiles WHERE id = v_user_id);
    END IF;

    -- Output company details if company exists
    IF company_exists THEN
        RAISE NOTICE 'Company details:';
        RAISE NOTICE '  Name: %', (SELECT name FROM companies WHERE id = v_company_id);
    END IF;

    -- Output user-company details if association exists
    IF user_company_exists THEN
        RAISE NOTICE 'User-Company details:';
        RAISE NOTICE '  Status: %', (SELECT status FROM user_companies WHERE user_id = v_user_id AND company_id = v_company_id);
        RAISE NOTICE '  Last Login: %', (SELECT last_login_at FROM user_companies WHERE user_id = v_user_id AND company_id = v_company_id);
    END IF;

    -- Output user roles if they exist
    IF user_role_exists THEN
        RAISE NOTICE 'User Roles:';
        FOR role_rec IN 
            SELECT r.name, r.is_system_role 
            FROM user_roles ur 
            JOIN roles r ON ur.role_id = r.id 
            WHERE ur.user_id = v_user_id
        LOOP
            RAISE NOTICE '  Role: % (System Role: %)', role_rec.name, role_rec.is_system_role;
        END LOOP;
    END IF;
END $$; 