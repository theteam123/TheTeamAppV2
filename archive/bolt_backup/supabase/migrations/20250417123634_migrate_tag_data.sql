-- Start transaction
BEGIN;

-- Create a function to migrate tag relationships
CREATE OR REPLACE FUNCTION migrate_tag_relationships()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_orphaned_count integer;
    v_migrated_count integer;
BEGIN
    -- Check for orphaned relationships
    SELECT COUNT(*) INTO v_orphaned_count
    FROM content_content_tags cct
    WHERE NOT EXISTS (
        SELECT 1 FROM content_tags ct WHERE ct.id = cct.tag_id
    );

    IF v_orphaned_count > 0 THEN
        RAISE WARNING 'Found % orphaned tag relationships', v_orphaned_count;
        
        -- Delete orphaned relationships
        DELETE FROM content_content_tags cct
        WHERE NOT EXISTS (
            SELECT 1 FROM content_tags ct WHERE ct.id = cct.tag_id
        );
        
        RAISE NOTICE 'Deleted % orphaned relationships', v_orphaned_count;
    END IF;

    -- Update company_id in content_tags if null
    UPDATE content_tags ct
    SET company_id = (
        SELECT DISTINCT cc.company_id
        FROM content_content_tags cct
        JOIN content c ON c.id = cct.content_id
        JOIN content_companies cc ON cc.content_id = c.id
        WHERE cct.tag_id = ct.id
        LIMIT 1
    )
    WHERE ct.company_id IS NULL;

    GET DIAGNOSTICS v_migrated_count = ROW_COUNT;
    RAISE NOTICE 'Updated company_id for % content tags', v_migrated_count;

    -- Verify data integrity
    PERFORM validate_tag_relationships();
    
    RAISE NOTICE 'Data migration completed successfully';
END;
$$;

-- Create validation function
CREATE OR REPLACE FUNCTION validate_tag_relationships()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_invalid_count integer;
BEGIN
    -- Check for invalid company associations
    SELECT COUNT(*) INTO v_invalid_count
    FROM content_content_tags cct
    JOIN content_tags ct ON ct.id = cct.tag_id
    JOIN content c ON c.id = cct.content_id
    JOIN content_companies cc ON cc.content_id = c.id
    WHERE ct.company_id != cc.company_id;

    IF v_invalid_count > 0 THEN
        RAISE EXCEPTION 'Found % invalid company associations in tag relationships', v_invalid_count;
    END IF;

    -- Check for duplicate tag assignments
    SELECT COUNT(*) INTO v_invalid_count
    FROM (
        SELECT content_id, tag_id, COUNT(*)
        FROM content_content_tags
        GROUP BY content_id, tag_id
        HAVING COUNT(*) > 1
    ) dupes;

    IF v_invalid_count > 0 THEN
        RAISE EXCEPTION 'Found % duplicate tag assignments', v_invalid_count;
    END IF;

    RAISE NOTICE 'All tag relationships validated successfully';
END;
$$;

-- Execute the migration
SELECT migrate_tag_relationships();

-- Drop the functions
DROP FUNCTION migrate_tag_relationships();
DROP FUNCTION validate_tag_relationships();

-- Commit transaction
COMMIT;

-- Add audit log entry
INSERT INTO audit_logs (action, target_type, details)
VALUES (
    'DATA_MIGRATION',
    'content_tags',
    jsonb_build_object(
        'type', 'tag_relationships',
        'orphaned_relationships_cleaned', true,
        'company_ids_updated', true,
        'validation_passed', true
    )
); 