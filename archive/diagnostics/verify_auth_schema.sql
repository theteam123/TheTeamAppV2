-- Check if auth schema exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') THEN
        RAISE EXCEPTION 'Auth schema does not exist';
    END IF;
END $$;

-- Check if auth.users table exists and has required columns
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'auth' 
        AND table_name = 'users'
    ) THEN
        RAISE EXCEPTION 'auth.users table does not exist';
    END IF;
END $$;

-- Check if auth.sessions table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'auth' 
        AND table_name = 'sessions'
    ) THEN
        RAISE EXCEPTION 'auth.sessions table does not exist';
    END IF;
END $$;

-- Check if auth.refresh_tokens table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'auth' 
        AND table_name = 'refresh_tokens'
    ) THEN
        RAISE EXCEPTION 'auth.refresh_tokens table does not exist';
    END IF;
END $$;

-- Check if auth.schema_migrations table exists and has data
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'auth' 
        AND table_name = 'schema_migrations'
    ) THEN
        RAISE EXCEPTION 'auth.schema_migrations table does not exist';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM auth.schema_migrations) THEN
        RAISE EXCEPTION 'auth.schema_migrations table is empty';
    END IF;
END $$;

-- Output current auth schema status
SELECT 
    'Auth Schema Status' as check,
    EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') as schema_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') as users_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'sessions') as sessions_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'refresh_tokens') as refresh_tokens_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'schema_migrations') as schema_migrations_table_exists,
    (SELECT COUNT(*) > 0 FROM auth.schema_migrations) as has_migrations; 