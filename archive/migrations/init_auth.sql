-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth.users table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE,
    encrypted_password TEXT,
    email_confirmed_at TIMESTAMPTZ,
    invited_at TIMESTAMPTZ,
    confirmation_token TEXT,
    confirmation_sent_at TIMESTAMPTZ,
    recovery_token TEXT,
    recovery_sent_at TIMESTAMPTZ,
    email_change_token_new TEXT,
    email_change TEXT,
    email_change_sent_at TIMESTAMPTZ,
    last_sign_in_at TIMESTAMPTZ,
    raw_app_meta_data JSONB,
    raw_user_meta_data JSONB,
    is_super_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    phone TEXT UNIQUE,
    phone_confirmed_at TIMESTAMPTZ,
    phone_change TEXT,
    phone_change_token TEXT,
    phone_change_sent_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ,
    email_change_token_current TEXT,
    banned_until TIMESTAMPTZ,
    reauthentication_token TEXT,
    reauthentication_sent_at TIMESTAMPTZ,
    is_sso_user BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ
);

-- Create auth.sessions table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    factor_id UUID,
    aal AUTHENTICATION_ASSURANCE_LEVEL,
    not_after TIMESTAMPTZ
);

-- Create auth.refresh_tokens table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
    id BIGINT PRIMARY KEY,
    token TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    revoked BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    parent TEXT,
    session_id UUID REFERENCES auth.sessions(id) ON DELETE CASCADE
);

-- Create auth.mfa_factors table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.mfa_factors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    friendly_name TEXT,
    factor_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    secret TEXT
);

-- Create auth.mfa_challenges table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.mfa_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factor_id UUID REFERENCES auth.mfa_factors(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ,
    ip_address INET
);

-- Create auth.audit_log_entries table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.audit_log_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payload JSON,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create auth.schema_migrations table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
    version TEXT PRIMARY KEY
);

-- Insert initial schema migration
INSERT INTO auth.schema_migrations (version)
VALUES ('20240101000000')
ON CONFLICT (version) DO NOTHING;

-- Enable Row Level Security on auth tables
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies for auth tables
CREATE POLICY "Users can view their own data"
    ON auth.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
    ON auth.users FOR UPDATE
    USING (auth.uid() = id);

-- Create function to get current user ID
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS UUID AS $$
BEGIN
    RETURN current_setting('request.jwt.claims', true)::json->>'sub'::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 