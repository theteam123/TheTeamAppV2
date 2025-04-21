-- List all functions with their details
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    t.typname as return_type,
    CASE 
        WHEN p.prosecdef THEN 'SECURITY DEFINER'
        ELSE 'SECURITY INVOKER'
    END as security_type,
    CASE 
        WHEN p.provolatile = 'i' THEN 'IMMUTABLE'
        WHEN p.provolatile = 's' THEN 'STABLE'
        WHEN p.provolatile = 'v' THEN 'VOLATILE'
    END as volatility,
    CASE 
        WHEN p.proisstrict THEN 'STRICT'
        ELSE 'NOT STRICT'
    END as strictness,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_type t ON p.prorettype = t.oid
WHERE n.nspname NOT LIKE 'pg_%' 
AND n.nspname != 'information_schema'
ORDER BY n.nspname, p.proname;

-- List specifically admin and permission related functions
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    t.typname as return_type,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_type t ON p.prorettype = t.oid
WHERE n.nspname NOT LIKE 'pg_%' 
AND n.nspname != 'information_schema'
AND (
    p.proname LIKE '%admin%' 
    OR p.proname LIKE '%permission%' 
    OR p.proname LIKE '%role%' 
    OR p.proname LIKE '%user%'
)
ORDER BY n.nspname, p.proname;

-- Check for system role related functions
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    t.typname as return_type,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_type t ON p.prorettype = t.oid
WHERE n.nspname NOT LIKE 'pg_%' 
AND n.nspname != 'information_schema'
AND p.proname LIKE '%system%'
ORDER BY n.nspname, p.proname;

-- Check for company related functions
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    t.typname as return_type,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_type t ON p.prorettype = t.oid
WHERE n.nspname NOT LIKE 'pg_%' 
AND n.nspname != 'information_schema'
AND p.proname LIKE '%company%'
ORDER BY n.nspname, p.proname; 