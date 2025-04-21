-- Create trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create helper functions
CREATE OR REPLACE FUNCTION has_system_role(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = has_system_role.user_id
        AND r.is_system_role = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_app_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_user_companies()
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    IF is_app_admin() THEN
        RETURN QUERY
        SELECT c.id, c.name, c.description, c.created_at, c.updated_at
        FROM companies c;
    ELSE
        RETURN QUERY
        SELECT c.id, c.name, c.description, c.created_at, c.updated_at
        FROM companies c
        JOIN user_companies uc ON c.id = uc.company_id
        WHERE uc.user_id = auth.uid();
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create tables
CREATE OR REPLACE FUNCTION create_tables()
RETURNS void AS $$
DECLARE
    constraint_exists BOOLEAN;
BEGIN
    -- Create tables first
    CREATE TABLE IF NOT EXISTS profiles (
        id UUID PRIMARY KEY REFERENCES auth.users(id),
        email TEXT UNIQUE,
        full_name TEXT,
        avatar_url TEXT,
        current_company_id UUID,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS companies (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name TEXT NOT NULL,
        description TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS roles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        is_system_role BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS role_permissions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
        permission TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(role_id, permission)
    );

    CREATE TABLE IF NOT EXISTS user_roles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(user_id, role_id)
    );

    CREATE TABLE IF NOT EXISTS user_companies (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
        company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(user_id, company_id)
    );

    -- Check if foreign key constraint exists
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_name = 'profiles_current_company_id_fkey'
        AND table_name = 'profiles'
    ) INTO constraint_exists;

    -- Add foreign key constraint for current_company_id if it doesn't exist
    IF NOT constraint_exists THEN
        ALTER TABLE profiles
        ADD CONSTRAINT profiles_current_company_id_fkey
        FOREIGN KEY (current_company_id) REFERENCES companies(id);
    END IF;

    -- Create triggers for updated_at after tables are created
    DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
    CREATE TRIGGER update_profiles_updated_at
        BEFORE UPDATE ON profiles
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
    CREATE TRIGGER update_companies_updated_at
        BEFORE UPDATE ON companies
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    DROP TRIGGER IF EXISTS update_roles_updated_at ON roles;
    CREATE TRIGGER update_roles_updated_at
        BEFORE UPDATE ON roles
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
END;
$$ LANGUAGE plpgsql;

-- Enable RLS
CREATE OR REPLACE FUNCTION enable_rls()
RETURNS void AS $$
BEGIN
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
    ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_companies ENABLE ROW LEVEL SECURITY;
END;
$$ LANGUAGE plpgsql;

-- Create policies
CREATE OR REPLACE FUNCTION create_policies()
RETURNS void AS $$
BEGIN
    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can read companies they belong to" ON companies;
    DROP POLICY IF EXISTS "Users can read roles" ON roles;
    DROP POLICY IF EXISTS "Users can read role permissions" ON role_permissions;
    DROP POLICY IF EXISTS "Users can read their role assignments" ON user_roles;
    DROP POLICY IF EXISTS "Users can read their company assignments" ON user_companies;

    -- Create new policies
    CREATE POLICY "Users can read their own profile"
        ON profiles FOR SELECT
        USING (auth.uid() = id);

    CREATE POLICY "Users can update their own profile"
        ON profiles FOR UPDATE
        USING (auth.uid() = id);

    CREATE POLICY "Users can read companies they belong to"
        ON companies FOR SELECT
        USING (
            id IN (SELECT company_id FROM user_companies WHERE user_id = auth.uid())
            OR is_app_admin()
        );

    CREATE POLICY "Users can read roles"
        ON roles FOR SELECT
        USING (true);

    CREATE POLICY "Users can read role permissions"
        ON role_permissions FOR SELECT
        USING (true);

    CREATE POLICY "Users can read their role assignments"
        ON user_roles FOR SELECT
        USING (user_id = auth.uid() OR is_app_admin());

    CREATE POLICY "Users can read their company assignments"
        ON user_companies FOR SELECT
        USING (user_id = auth.uid() OR is_app_admin());
END;
$$ LANGUAGE plpgsql;

-- Create indexes
CREATE OR REPLACE FUNCTION create_indexes()
RETURNS void AS $$
BEGIN
    CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
    CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
    CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);
    CREATE INDEX IF NOT EXISTS idx_user_companies_user_id ON user_companies(user_id);
    CREATE INDEX IF NOT EXISTS idx_user_companies_company_id ON user_companies(company_id);
END;
$$ LANGUAGE plpgsql;

-- Create App_Admin role
CREATE OR REPLACE FUNCTION create_app_admin_role()
RETURNS TEXT AS $$
DECLARE
    admin_role_id UUID;
    role_exists BOOLEAN;
    status_message TEXT;
BEGIN
    -- Check if App_Admin role already exists
    SELECT EXISTS (
        SELECT 1 FROM roles WHERE name = 'App_Admin'
    ) INTO role_exists;

    IF role_exists THEN
        status_message := 'App_Admin role already exists, updating...';
        -- Update existing role
        UPDATE roles 
        SET is_system_role = true
        WHERE name = 'App_Admin'
        RETURNING id INTO admin_role_id;
    ELSE
        status_message := 'Creating new App_Admin role...';
        -- Create new role
        INSERT INTO roles (name, description, is_system_role)
        VALUES ('App_Admin', 'System administrator with full access', true)
        RETURNING id INTO admin_role_id;
    END IF;

    -- Add permissions for App_Admin
    status_message := status_message || ' Adding permissions...';
    INSERT INTO role_permissions (role_id, permission)
    SELECT admin_role_id, 'manage_users'
    ON CONFLICT DO NOTHING;

    INSERT INTO role_permissions (role_id, permission)
    SELECT admin_role_id, 'manage_roles'
    ON CONFLICT DO NOTHING;

    INSERT INTO role_permissions (role_id, permission)
    SELECT admin_role_id, 'manage_companies'
    ON CONFLICT DO NOTHING;

    -- Verify the setup
    IF EXISTS (
        SELECT 1 
        FROM roles r
        JOIN role_permissions rp ON r.id = rp.role_id
        WHERE r.name = 'App_Admin'
        AND rp.permission IN ('manage_users', 'manage_roles', 'manage_companies')
        GROUP BY r.id
        HAVING COUNT(*) = 3
    ) THEN
        status_message := status_message || ' Setup completed successfully';
    ELSE
        status_message := status_message || ' Warning: Some permissions might be missing';
    END IF;

    RETURN status_message;
END;
$$ LANGUAGE plpgsql; 