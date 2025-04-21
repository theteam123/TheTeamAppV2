-- Verify content_tags table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'content_tags'
ORDER BY ordinal_position;

-- Verify content_content_tags table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'content_content_tags'
ORDER BY ordinal_position;

-- Verify RLS is enabled
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename IN ('content_tags', 'content_content_tags');

-- Verify policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename IN ('content_tags', 'content_content_tags')
ORDER BY tablename, policyname;

-- Verify triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table IN ('content_tags', 'content_content_tags')
ORDER BY event_object_table, trigger_name;

-- Verify foreign keys
SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name IN ('content_tags', 'content_content_tags')
ORDER BY tc.table_name, tc.constraint_name; 