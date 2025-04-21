-- Start transaction
BEGIN;

-- Run auth initialization
\i init_auth.sql

-- Run main setup
\i setup.sql

-- Verify setup
\i verify_setup.sql

-- Commit transaction
COMMIT; 