-- Run setup in sequence
BEGIN;

-- 1. Create helper functions
SELECT has_system_role('00000000-0000-0000-0000-000000000000'); -- Dummy UUID to create function
SELECT is_app_admin();
SELECT get_user_companies();

-- 2. Create tables (this will also create the trigger function and attach it)
SELECT create_tables();

-- 3. Enable RLS
SELECT enable_rls();

-- 4. Create policies
SELECT create_policies();

-- 5. Create indexes
SELECT create_indexes();

-- 6. Create App_Admin role
DROP FUNCTION IF EXISTS create_app_admin_role();
SELECT create_app_admin_role();

COMMIT;

-- Verify setup
DO $$
BEGIN
    -- Check if tables exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'profiles') THEN
        RAISE EXCEPTION 'Table profiles not created';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'companies') THEN
        RAISE EXCEPTION 'Table companies not created';
    END IF;
    
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'roles') THEN
        RAISE EXCEPTION 'Table roles not created';
    END IF;
    
    -- Check if App_Admin role exists
    IF NOT EXISTS (SELECT FROM roles WHERE name = 'App_Admin') THEN
        RAISE EXCEPTION 'App_Admin role not created';
    END IF;
    
    -- Check if triggers exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_profiles_updated_at'
    ) THEN
        RAISE EXCEPTION 'Trigger update_profiles_updated_at not created';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_companies_updated_at'
    ) THEN
        RAISE EXCEPTION 'Trigger update_companies_updated_at not created';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_roles_updated_at'
    ) THEN
        RAISE EXCEPTION 'Trigger update_roles_updated_at not created';
    END IF;
    
    RAISE NOTICE 'Setup completed successfully';
END $$; 