DO $$
DECLARE
    admin_user_id UUID;
    admin_role_id UUID;
    admin_company_id UUID;
    status_message TEXT;
BEGIN
    -- Create the user in auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        email_change_token_new,
        recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000', -- instance_id
        gen_random_uuid(), -- id
        'authenticated', -- aud
        'authenticated', -- role
        'paul+app_admin@theteam.net.au', -- email
        crypt('LGKi2fQb3Q$%sjg$', gen_salt('bf')), -- encrypted_password
        NOW(), -- email_confirmed_at
        NOW(), -- created_at
        NOW(), -- updated_at
        '', -- confirmation_token
        '', -- email_change_token_new
        '' -- recovery_token
    )
    RETURNING id INTO admin_user_id;

    -- Get the App_Admin role ID
    SELECT id INTO admin_role_id
    FROM roles
    WHERE name = 'App_Admin';
    
    IF admin_role_id IS NULL THEN
        RAISE EXCEPTION 'App_Admin role not found';
    END IF;
    
    -- Create a default company for the admin
    INSERT INTO companies (name, description)
    VALUES ('System Admin Company', 'Default company for system administrator')
    RETURNING id INTO admin_company_id;
    
    -- Create admin's profile
    INSERT INTO profiles (id, email, full_name, current_company_id)
    VALUES (
        admin_user_id,
        'paul+app_admin@theteam.net.au',
        'System Administrator',
        admin_company_id
    )
    ON CONFLICT (id) DO UPDATE
    SET current_company_id = admin_company_id;
    
    -- Assign the admin role to the user
    INSERT INTO user_roles (user_id, role_id)
    VALUES (admin_user_id, admin_role_id)
    ON CONFLICT (user_id, role_id) DO NOTHING;
    
    -- Assign the user to the admin company
    INSERT INTO user_companies (user_id, company_id)
    VALUES (admin_user_id, admin_company_id)
    ON CONFLICT (user_id, company_id) DO NOTHING;
    
    -- Verify the setup
    IF EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = admin_user_id
        AND r.name = 'App_Admin'
    ) THEN
        status_message := 'Admin user created and setup completed successfully';
    ELSE
        status_message := 'Warning: Admin role assignment might not have been successful';
    END IF;
    
    RAISE NOTICE 'Admin user created with ID: %', admin_user_id;
    RAISE NOTICE '%', status_message;
END $$; 