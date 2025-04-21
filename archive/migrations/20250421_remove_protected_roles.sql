-- Migration to remove protected_roles and simplify role protection
BEGIN;

-- Drop existing objects that will be replaced
DROP POLICY IF EXISTS "App admins can view protected roles" ON protected_roles;
DROP POLICY IF EXISTS "App admins can manage custom roles" ON roles;
DROP TRIGGER IF EXISTS prevent_protected_role_deletion_trigger ON roles;
DROP TRIGGER IF EXISTS prevent_protected_role_modification_trigger ON roles;
DROP FUNCTION IF EXISTS prevent_protected_role_deletion() CASCADE;
DROP FUNCTION IF EXISTS prevent_protected_role_modification() CASCADE;
DROP VIEW IF EXISTS roles_view;

-- Add is_protected column to roles table
ALTER TABLE roles ADD COLUMN IF NOT EXISTS is_protected BOOLEAN DEFAULT false;

-- Update existing system roles to be protected
UPDATE roles 
SET is_protected = true 
WHERE name IN ('App_Admin', 'Company_Admin');

-- Create simplified protection trigger
CREATE OR REPLACE FUNCTION prevent_system_role_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_system_role = true OR OLD.is_protected = true THEN
        RAISE EXCEPTION 'Cannot modify or delete system/protected roles';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for role protection
CREATE TRIGGER prevent_system_role_changes
BEFORE UPDATE OR DELETE ON roles
FOR EACH ROW
EXECUTE FUNCTION prevent_system_role_changes();

-- Create simplified role management policy
CREATE POLICY "App admins can manage roles"
ON roles
FOR ALL TO authenticated
USING (
    has_system_role('App_Admin') 
    AND NOT (roles.is_system_role OR roles.is_protected)
)
WITH CHECK (
    has_system_role('App_Admin')
    AND NOT (roles.is_system_role OR roles.is_protected)
);

-- Drop the protected_roles table last (after all dependencies are removed)
DROP TABLE IF EXISTS protected_roles CASCADE;

COMMIT; 