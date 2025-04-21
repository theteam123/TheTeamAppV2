-- Start transaction
BEGIN;

-- Add function documentation
COMMENT ON FUNCTION public.update_updated_at_column() IS 'Trigger function to automatically update the updated_at timestamp column. Runs with SECURITY DEFINER to ensure it can always update timestamps regardless of RLS policies.';

-- Verify the comment was added
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    obj_description(p.oid, 'pg_proc') as description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'update_updated_at_column'
AND n.nspname = 'public';

COMMIT; 