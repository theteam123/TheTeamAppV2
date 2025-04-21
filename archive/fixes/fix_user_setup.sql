DO $$
DECLARE
    v_user_id UUID := '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78';
    v_company_id UUID := '33333333-3333-3333-3333-333333333333';
    v_role_id UUID;
BEGIN
    -- Get the Company_Manager role ID
    SELECT id INTO v_role_id FROM roles WHERE name = 'Company_Manager';
    
    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Company_Manager role not found';
    END IF;

    -- Add user-company association if it doesn't exist
    INSERT INTO user_companies (user_id, company_id, status, last_login_at)
    VALUES (v_user_id, v_company_id, 'active', NOW())
    ON CONFLICT (user_id, company_id) DO UPDATE
    SET status = 'active',
        last_login_at = NOW();

    -- Add Company_Manager role if not already assigned
    INSERT INTO user_roles (user_id, role_id)
    VALUES (v_user_id, v_role_id)
    ON CONFLICT (user_id, role_id) DO NOTHING;

    -- Update user's current_company_id if not set
    UPDATE profiles
    SET current_company_id = v_company_id
    WHERE id = v_user_id
    AND current_company_id IS NULL;

    -- Output the changes made
    RAISE NOTICE 'User-company association created/updated';
    RAISE NOTICE 'Company_Manager role assigned';
    RAISE NOTICE 'Current company ID updated if needed';
END $$; 