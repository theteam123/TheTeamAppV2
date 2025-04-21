-- Verify function security settings
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    p.prosecdef as security_definer,
    p.provolatile as volatility,
    p.proleakproof as leakproof,
    array_to_string(p.proargnames, ', ') as arg_names,
    pg_get_function_result(p.oid) as result_type,
    obj_description(p.oid, 'pg_proc') as description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'update_updated_at_column'
AND n.nspname = 'public'; 