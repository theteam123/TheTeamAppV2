/*
  # Remove Policies, Records, Templates, and Videos Tables

  1. Changes
    - Drop policies table and its dependencies
    - Drop records table and its dependencies
    - Drop templates table and its dependencies
    - Drop videos table and its dependencies
    - Remove any junction tables
    - Clean up related policies

  2. Security
    - Remove associated RLS policies
*/

-- Drop policies table and dependencies
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'policies') THEN
    DROP TABLE policies CASCADE;
  END IF;
END $$;

-- Drop records table and dependencies
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'records') THEN
    DROP TABLE records CASCADE;
  END IF;
END $$;

-- Drop templates table and dependencies
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'templates') THEN
    DROP TABLE templates CASCADE;
  END IF;
END $$;

-- Drop videos table and dependencies
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'videos') THEN
    DROP TABLE videos CASCADE;
  END IF;
END $$;

-- Clean up content types from content table
UPDATE content 
SET content_type = 'other'
WHERE content_type IN ('policy', 'record', 'template', 'video');