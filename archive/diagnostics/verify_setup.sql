DO $$
DECLARE
    table_count INTEGER;
    trigger_count INTEGER;
    policy_count INTEGER;
    role_count INTEGER;
    permission_count INTEGER;
BEGIN
    -- Check tables
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_name IN ('profiles', 'companies', 'roles', 'role_permissions', 'user_roles', 'user_companies');
    
    IF table_count != 6 THEN
        RAISE EXCEPTION 'Missing tables. Expected 6, found %', table_count;
    END IF;
    
    -- Check triggers
    SELECT COUNT(*) INTO trigger_count
    FROM pg_trigger
    WHERE tgname IN ('update_profiles_updated_at', 'update_companies_updated_at', 'update_roles_updated_at');
    
    IF trigger_count != 3 THEN
        RAISE EXCEPTION 'Missing triggers. Expected 3, found %', trigger_count;
    END IF;
    
    -- Check policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename IN ('profiles', 'companies', 'roles', 'role_permissions', 'user_roles', 'user_companies');
    
    IF policy_count != 7 THEN
        RAISE EXCEPTION 'Missing policies. Expected 7, found %', policy_count;
    END IF;
    
    -- Check App_Admin role
    SELECT COUNT(*) INTO role_count
    FROM roles
    WHERE name = 'App_Admin' AND is_system_role = true;
    
    IF role_count != 1 THEN
        RAISE EXCEPTION 'App_Admin role not found or not properly configured';
    END IF;
    
    -- Check App_Admin permissions
    SELECT COUNT(*) INTO permission_count
    FROM roles r
    JOIN role_permissions rp ON r.id = rp.role_id
    WHERE r.name = 'App_Admin'
    AND rp.permission IN ('manage_users', 'manage_roles', 'manage_companies');
    
    IF permission_count != 3 THEN
        RAISE EXCEPTION 'App_Admin role missing permissions. Expected 3, found %', permission_count;
    END IF;
    
    -- Check RLS status
    IF NOT EXISTS (
        SELECT 1
        FROM pg_tables
        WHERE tablename IN ('profiles', 'companies', 'roles', 'role_permissions', 'user_roles', 'user_companies')
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'Row Level Security not enabled on all tables';
    END IF;
    
    -- Check foreign key constraints
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_name = 'profiles_current_company_id_fkey'
        AND table_name = 'profiles'
    ) THEN
        RAISE EXCEPTION 'Missing foreign key constraint on profiles.current_company_id';
    END IF;
    
    -- Check indexes
    IF NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE indexname IN (
            'idx_profiles_email',
            'idx_user_roles_user_id',
            'idx_user_roles_role_id',
            'idx_user_companies_user_id',
            'idx_user_companies_company_id'
        )
    ) THEN
        RAISE EXCEPTION 'Missing required indexes';
    END IF;
    
    RAISE NOTICE 'Verification completed successfully. All components are properly configured.';
END $$; 