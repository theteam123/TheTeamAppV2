/*
  # Remove Forms Tables and Related Dependencies

  1. Changes
    - Drop forms table and its foreign key constraints first
    - Drop form_submissions table if it exists
    - Clean up any remaining policies
    - Safe migration that checks for existence before dropping

  2. Security
    - Remove form-related policies
*/

-- First check and drop forms table since it's referenced by form_submissions
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'forms') THEN
    DROP TABLE forms CASCADE;
  END IF;
END $$;

-- Then check and drop form_submissions table
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'form_submissions') THEN
    DROP TABLE form_submissions CASCADE;
  END IF;
END $$;

-- Clean up any remaining policies
DO $$ 
BEGIN
  -- Drop policies if they exist
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Public users can submit to public forms'
  ) THEN
    DROP POLICY IF EXISTS "Public users can submit to public forms" ON form_submissions;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can create form submissions'
  ) THEN
    DROP POLICY IF EXISTS "Users can create form submissions" ON form_submissions;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can delete company form submissions'
  ) THEN
    DROP POLICY IF EXISTS "Users can delete company form submissions" ON form_submissions;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can view company form submissions'
  ) THEN
    DROP POLICY IF EXISTS "Users can view company form submissions" ON form_submissions;
  END IF;
END $$;