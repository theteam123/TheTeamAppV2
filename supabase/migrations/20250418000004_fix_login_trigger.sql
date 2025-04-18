-- Fix login trigger and ensure user_companies table exists
BEGIN;

-- Create user_companies table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_companies (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    status text DEFAULT 'active' NOT NULL,
    last_login_at timestamptz,
    UNIQUE(user_id, company_id)
);

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_last_login_trigger ON auth.users;

-- Create a more robust update_last_login function
CREATE OR REPLACE FUNCTION update_last_login()
RETURNS TRIGGER AS $$
BEGIN
  -- Only proceed if the user_companies table exists
  IF to_regclass('public.user_companies') IS NOT NULL THEN
    -- Update last_login_at for all companies the user belongs to
    -- Only update if the user has company associations
    IF EXISTS (
      SELECT 1 FROM public.user_companies
      WHERE user_id = NEW.id
    ) THEN
      UPDATE public.user_companies
      SET last_login_at = now()
      WHERE user_id = NEW.id;
    END IF;
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the operation
    RAISE LOG 'Error in update_last_login: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER update_last_login_trigger
  AFTER UPDATE OF last_sign_in_at
  ON auth.users
  FOR EACH ROW
  WHEN (NEW.last_sign_in_at IS DISTINCT FROM OLD.last_sign_in_at)
  EXECUTE FUNCTION update_last_login();

COMMIT; 