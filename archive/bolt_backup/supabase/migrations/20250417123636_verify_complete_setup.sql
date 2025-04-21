-- 1. Table Structures
-- content_tags columns
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'content_tags'
ORDER BY ordinal_position;

-- content_content_tags columns
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'content_content_tags'
ORDER BY ordinal_position;

-- 2. Primary Keys
SELECT
    tc.table_name, 
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY' 
    AND tc.table_name IN ('content_tags', 'content_content_tags')
ORDER BY tc.table_name;

-- 3. RLS Status
SELECT 
    tablename,
    rowsecurity,
    relrowsecurity as rls_enforced,
    relforcerowsecurity as rls_forced
FROM pg_tables
JOIN pg_class ON pg_class.relname = pg_tables.tablename
WHERE tablename IN ('content_tags', 'content_content_tags');

-- 4. RLS Policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual::text as using_expression,
    with_check::text as with_check_expression
FROM pg_policies
WHERE tablename IN ('content_tags', 'content_content_tags')
ORDER BY tablename, policyname;

-- 5. Triggers
SELECT 
    tgname as trigger_name,
    proname as function_name,
    tgtype,
    tgenabled,
    tgrelid::regclass as table_name,
    tgdeferrable,
    tginitdeferred,
    pg_get_triggerdef(t.oid) as trigger_definition
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid::regclass::text IN ('content_tags', 'content_content_tags')
AND NOT tgisinternal;

-- 6. Indexes
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename IN ('content_tags', 'content_content_tags')
ORDER BY tablename, indexname;

-- 7. Table Comments
SELECT 
    c.relname AS table_name,
    pd.description AS table_comment
FROM pg_class c
LEFT JOIN pg_description pd ON c.oid = pd.objoid AND pd.objsubid = 0
WHERE c.relname IN ('content_tags', 'content_content_tags')
AND c.relkind = 'r';

-- 8. Column Comments
SELECT 
    c.relname AS table_name,
    a.attname AS column_name,
    pd.description AS column_comment
FROM pg_class c
JOIN pg_attribute a ON c.oid = a.attrelid
LEFT JOIN pg_description pd ON c.oid = pd.objoid AND pd.objsubid = a.attnum
WHERE c.relname IN ('content_tags', 'content_content_tags')
AND a.attnum > 0
AND NOT a.attisdropped
ORDER BY c.relname, a.attnum;

-- 9. Function Definition
SELECT 
    proname as function_name,
    prosrc as function_definition,
    provolatile,
    proisstrict,
    prosecdef as security_definer
FROM pg_proc 
WHERE proname = 'update_updated_at_column';

-- 10. Dependencies
SELECT DISTINCT
    dependent_ns.nspname as dependent_schema,
    dependent_view.relname as dependent_view,
    source_ns.nspname as source_schema,
    source_table.relname as source_table
FROM pg_depend 
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid 
JOIN pg_class as dependent_view ON pg_rewrite.ev_class = dependent_view.oid 
JOIN pg_class as source_table ON pg_depend.refobjid = source_table.oid 
JOIN pg_namespace dependent_ns ON dependent_view.relnamespace = dependent_ns.oid 
JOIN pg_namespace source_ns ON source_table.relnamespace = source_ns.oid 
WHERE source_table.relname IN ('content_tags', 'content_content_tags')
AND dependent_view.relname != source_table.relname
ORDER BY 1,2,3,4; 