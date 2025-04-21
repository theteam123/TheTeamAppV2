-- Drop and recreate get_user_companies function
CREATE OR REPLACE FUNCTION public.get_user_companies()
RETURNS TABLE (
    id uuid,
    name text,
    website text,
    settings jsonb,
    created_at timestamptz,
    updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- First check if user is App_Admin
    IF EXISTS (
        SELECT 1 
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    ) THEN
        -- App_Admin can see all companies
        RETURN QUERY
        SELECT 
            c.id,
            c.name,
            c.website,
            c.settings,
            c.created_at,
            c.updated_at
        FROM companies c;
    ELSE
        -- Regular users can only see companies they belong to with active status
        RETURN QUERY
        SELECT 
            c.id,
            c.name,
            c.website,
            c.settings,
            c.created_at,
            c.updated_at
        FROM companies c
        JOIN user_companies uc ON c.id = uc.company_id
        WHERE uc.user_id = auth.uid()
        AND uc.status = 'active';
    END IF;
END;
$$; 