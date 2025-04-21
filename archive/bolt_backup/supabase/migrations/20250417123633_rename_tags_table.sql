-- Start transaction
BEGIN;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a function to handle the migration
CREATE OR REPLACE FUNCTION setup_content_tags()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Create content_tags table if it doesn't exist
    CREATE TABLE IF NOT EXISTS content_tags (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        created_at timestamptz DEFAULT now(),
        updated_at timestamptz DEFAULT now(),
        name text NOT NULL,
        description text,
        color text DEFAULT '#4F46E5',
        company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE
    );

    -- Create content_content_tags table if it doesn't exist
    CREATE TABLE IF NOT EXISTS content_content_tags (
        content_id uuid NOT NULL REFERENCES content(id) ON DELETE CASCADE,
        tag_id uuid NOT NULL REFERENCES content_tags(id) ON DELETE CASCADE,
        created_at timestamptz DEFAULT now(),
        PRIMARY KEY (content_id, tag_id)
    );

    -- Enable RLS
    ALTER TABLE content_tags ENABLE ROW LEVEL SECURITY;
    ALTER TABLE content_content_tags ENABLE ROW LEVEL SECURITY;

    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can view content tags they have access to" ON content_tags;
    DROP POLICY IF EXISTS "Users can manage content tags for their companies" ON content_tags;
    DROP POLICY IF EXISTS "Users can manage content tag relationships" ON content_content_tags;

    -- Create policies for content_tags
    CREATE POLICY "Users can view content tags they have access to" ON content_tags
        FOR SELECT
        USING (
            company_id IN (
                SELECT company_id FROM user_companies WHERE user_id = auth.uid()
            )
        );

    CREATE POLICY "Users can manage content tags for their companies" ON content_tags
        FOR ALL
        USING (
            company_id IN (
                SELECT company_id FROM user_companies WHERE user_id = auth.uid()
            )
        )
        WITH CHECK (
            company_id IN (
                SELECT company_id FROM user_companies WHERE user_id = auth.uid()
            )
        );

    -- Create policy for content_content_tags
    CREATE POLICY "Users can manage content tag relationships" ON content_content_tags
        FOR ALL
        USING (
            tag_id IN (
                SELECT id FROM content_tags
                WHERE company_id IN (
                    SELECT company_id FROM user_companies WHERE user_id = auth.uid()
                )
            )
        )
        WITH CHECK (
            tag_id IN (
                SELECT id FROM content_tags
                WHERE company_id IN (
                    SELECT company_id FROM user_companies WHERE user_id = auth.uid()
                )
            )
        );

    -- Drop existing trigger if it exists
    DROP TRIGGER IF EXISTS set_content_tags_updated_at ON content_tags;

    -- Create trigger
    CREATE TRIGGER set_content_tags_updated_at
        BEFORE UPDATE ON content_tags
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    RAISE NOTICE 'Content tags setup completed successfully';
END;
$$;

-- Execute the setup function
SELECT setup_content_tags();

-- Drop the setup function
DROP FUNCTION setup_content_tags();

-- Commit transaction
COMMIT;

-- Add verification comment
COMMENT ON TABLE content_tags IS 'Table for storing content tags. Created or verified on 2025-04-17.'; 