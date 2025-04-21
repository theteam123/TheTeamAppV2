-- Start transaction
BEGIN;

-- Store existing triggers that use this function (only in public schema)
CREATE TEMP TABLE affected_triggers AS
SELECT 
    tgname as trigger_name,
    tgrelid::regclass as table_name,
    pg_get_triggerdef(t.oid) as trigger_definition
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE proname = 'update_updated_at_column'
AND NOT tgisinternal
AND p.pronamespace = 'public'::regnamespace;

-- Drop existing triggers that use this function
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM affected_triggers) LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON ' || r.table_name;
    END LOOP;
END $$;

-- Recreate the function with SECURITY DEFINER (only in public schema)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- Recreate all triggers that were using this function
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT * FROM affected_triggers) LOOP
        EXECUTE r.trigger_definition;
    END LOOP;
END $$;

-- Drop temporary table
DROP TABLE affected_triggers;

-- Verify the function
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    p.prosrc as function_definition,
    p.provolatile,
    p.proisstrict,
    p.prosecdef as security_definer
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'update_updated_at_column'
AND n.nspname = 'public';

-- Verify all triggers using this function
SELECT 
    n.nspname as schema_name,
    tgname as trigger_name,
    tgrelid::regclass as table_name,
    pg_get_triggerdef(t.oid) as trigger_definition
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'update_updated_at_column'
AND n.nspname = 'public'
AND NOT tgisinternal;

COMMIT; 