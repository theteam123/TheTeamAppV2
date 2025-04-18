-- Add function to handle session cleanup
CREATE OR REPLACE FUNCTION auth.handle_session_cleanup()
RETURNS TRIGGER AS $$
BEGIN
  -- Only run on INSERT of new users
  IF TG_OP = 'INSERT' THEN
    -- Clean up old sessions for this user
    DELETE FROM auth.sessions
    WHERE user_id = NEW.id
    AND id != NEW.last_session_id;
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the operation
    RAISE LOG 'Error in handle_session_cleanup: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add trigger for auth.users table
DROP TRIGGER IF EXISTS handle_session_cleanup_trigger ON auth.users;
CREATE TRIGGER handle_session_cleanup_trigger
  AFTER INSERT OR UPDATE
  ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION auth.handle_session_cleanup(); 