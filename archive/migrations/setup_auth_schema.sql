-- First, ensure we have the auth schema
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth.users table with our required fields
CREATE TABLE IF NOT EXISTS auth.users (
    id uuid PRIMARY KEY,
    email text UNIQUE,
    encrypted_password text,
    email_confirmed_at timestamp with time zone,
    raw_user_meta_data jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_sign_in_at timestamp with time zone,
    is_system_admin boolean DEFAULT false
);

-- Create auth.sessions table
CREATE TABLE IF NOT EXISTS auth.sessions (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create auth.refresh_tokens table
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
    id bigint PRIMARY KEY,
    token text,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    revoked boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    session_id uuid REFERENCES auth.sessions(id) ON DELETE CASCADE
);

-- Create auth.schema_migrations table
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
    version text PRIMARY KEY,
    dirty boolean NOT NULL DEFAULT false
);

-- Create necessary indexes
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);
CREATE INDEX IF NOT EXISTS sessions_user_id_idx ON auth.sessions(user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens(token);
CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON auth.refresh_tokens(user_id);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION auth.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION auth.update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON auth.sessions
    FOR EACH ROW
    EXECUTE FUNCTION auth.update_updated_at_column();

CREATE TRIGGER update_refresh_tokens_updated_at
    BEFORE UPDATE ON auth.refresh_tokens
    FOR EACH ROW
    EXECUTE FUNCTION auth.update_updated_at_column();

-- Enable Row Level Security on auth tables
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

-- Create policies for auth tables
CREATE POLICY "Users can view their own data"
    ON auth.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
    ON auth.users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "System admins can view all user data"
    ON auth.users FOR SELECT
    USING (is_system_admin = true);

CREATE POLICY "System admins can update all user data"
    ON auth.users FOR UPDATE
    USING (is_system_admin = true);

-- Insert initial migration
INSERT INTO auth.schema_migrations (version, dirty)
VALUES ('20240101000000', false)
ON CONFLICT (version) DO NOTHING;

-- Output status
SELECT 
    'Auth Schema Setup Status' as check,
    EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') as schema_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') as users_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'sessions') as sessions_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'refresh_tokens') as refresh_tokens_table_exists,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'schema_migrations') as schema_migrations_table_exists,
    (SELECT COUNT(*) > 0 FROM auth.schema_migrations) as has_migrations,
    EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') as users_trigger_exists,
    EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'update_sessions_updated_at') as sessions_trigger_exists,
    EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'update_refresh_tokens_updated_at') as refresh_tokens_trigger_exists;

-- New query to find missing users or profiles
SELECT 
    au.id as auth_user_id,
    au.email as auth_email,
    au.raw_user_meta_data->>'full_name' as auth_full_name,
    p.id as profile_id,
    p.email as profile_email,
    p.full_name as profile_full_name,
    CASE 
        WHEN au.id IS NULL THEN 'Missing Auth User'
        WHEN p.id IS NULL THEN 'Missing Profile'
        WHEN au.id = p.id THEN 'Matched'
        ELSE 'Mismatch'
    END as status
FROM auth.users au
FULL OUTER JOIN profiles p ON au.id = p.id
WHERE au.id IS NULL OR p.id IS NULL
ORDER BY status, auth_email NULLS LAST; 