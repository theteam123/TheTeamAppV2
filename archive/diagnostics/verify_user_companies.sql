DO $$
DECLARE
    v_user_id UUID := '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78';
    v_company_id UUID := '33333333-3333-3333-3333-333333333333';
    profile_exists BOOLEAN;
    company_exists BOOLEAN;
    user_company_exists BOOLEAN;
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

    -- Output current state
    RAISE NOTICE 'Profile exists: %', profile_exists;
    RAISE NOTICE 'Company exists: %', company_exists;
    RAISE NOTICE 'User-Company association exists: %', user_company_exists;

    -- Fix if needed
    IF NOT profile_exists THEN
        RAISE EXCEPTION 'Profile does not exist for user %', v_user_id;
    END IF;

    IF NOT company_exists THEN
        RAISE EXCEPTION 'Company does not exist with ID %', v_company_id;
    END IF;

    IF NOT user_company_exists THEN
        -- Create user-company association
        INSERT INTO user_companies (user_id, company_id, status, last_login_at)
        VALUES (
            v_user_id,
            v_company_id,
            'active',
            NOW()
        );
        RAISE NOTICE 'Created user-company association';
    END IF;

    -- Verify fix
    SELECT EXISTS (
        SELECT 1 FROM user_companies uc
        WHERE uc.user_id = v_user_id AND uc.company_id = v_company_id
    ) INTO user_company_exists;

    RAISE NOTICE 'Final state - User-Company association exists: %', user_company_exists;
END $$; 