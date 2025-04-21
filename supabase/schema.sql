

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."user_company_status" AS ENUM (
    'active',
    'inactive',
    'pending',
    'invited'
);


ALTER TYPE "public"."user_company_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_company"("company_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE companies
  SET archived_at = NOW()
  WHERE id = company_id;
END;
$$;


ALTER FUNCTION "public"."archive_company"("company_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_audit_log_entry"("action" "text", "target_id" "uuid", "target_type" "text", "details" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  log_id uuid;
BEGIN
  INSERT INTO audit_log (
    action,
    performed_by,
    target_id,
    target_type,
    details,
    ip_address,
    user_agent
  )
  VALUES (
    action,
    auth.uid(),
    target_id,
    target_type,
    details,
    current_setting('request.headers')::json->>'x-forwarded-for',
    current_setting('request.headers')::json->>'user-agent'
  )
  RETURNING id INTO log_id;

  RETURN log_id;
END;
$$;


ALTER FUNCTION "public"."create_audit_log_entry"("action" "text", "target_id" "uuid", "target_type" "text", "details" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_company_id"() RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    company_id uuid;
BEGIN
    -- Get company_id from JWT claims
    SELECT (current_setting('request.jwt.claims', true)::json->>'company_id')::uuid INTO company_id;
    
    -- If no company_id in JWT, try to get it from user_companies table
    IF company_id IS NULL THEN
        SELECT uc.company_id INTO company_id
        FROM user_companies uc
        WHERE uc.user_id = auth.uid()
        LIMIT 1;
    END IF;
    
    RETURN company_id;
END;
$$;


ALTER FUNCTION "public"."current_company_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_companies"() RETURNS TABLE("id" "uuid", "name" "text", "website" "text", "settings" "jsonb", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- First check if user is App_Admin
    IF EXISTS (
        SELECT 1 
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = 'App_Admin'
        AND r.is_system_role = true
    ) THEN
        -- App_Admin can see all companies
        RETURN QUERY
        SELECT 
            c.id,
            c.name,
            c.website,
            c.settings,
            c.created_at,
            c.updated_at
        FROM companies c;
    ELSE
        -- Regular users can only see companies they belong to with active status
        RETURN QUERY
        SELECT 
            c.id,
            c.name,
            c.website,
            c.settings,
            c.created_at,
            c.updated_at
        FROM companies c
        JOIN user_companies uc ON c.id = uc.company_id
        WHERE uc.user_id = auth.uid()
        AND uc.status = 'active';
    END IF;
END;
$$;


ALTER FUNCTION "public"."get_user_companies"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_roles"("user_id" "uuid") RETURNS TABLE("role_id" "uuid", "role_name" "text", "is_system_role" boolean, "permissions" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id as role_id,
        r.name as role_name,
        r.is_system_role,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'permission_key', rp.permission_key
            ))
            FROM user_role_permissions_view rp
            WHERE rp.role_id = r.id
            AND rp.user_id = get_user_roles.user_id
        ) as permissions
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = get_user_roles.user_id;
END;
$$;


ALTER FUNCTION "public"."get_user_roles"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name')
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email,
      full_name = EXCLUDED.full_name;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_company_permission"("permission" "text", "company_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.role_permissions rp ON r.id = rp.role_id
        JOIN public.user_companies uc ON ur.user_id = uc.user_id
        WHERE ur.user_id = auth.uid()
        AND uc.company_id = has_company_permission.company_id
        AND rp.permission_key = has_company_permission.permission
    );
END;
$$;


ALTER FUNCTION "public"."has_company_permission"("permission" "text", "company_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_permission"("permission_key" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if user has the permission through any of their roles
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN role_permissions rp ON ur.role_id = rp.role_id
        WHERE ur.user_id = auth.uid()
        AND rp.permission_key = permission_key
    );
END;
$$;


ALTER FUNCTION "public"."has_permission"("permission_key" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_permission"("user_id" "uuid", "permission_key" "text", "company_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    WHERE ur.user_id = $1
    AND rp.permission_key = $2
    AND ur.company_id = $3
  );
END;
$_$;


ALTER FUNCTION "public"."has_permission"("user_id" "uuid", "permission_key" "text", "company_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_permission"("p_user_id" "uuid", "p_company_id" "uuid", "p_permission_key" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.role_permissions rp ON ur.role_id = rp.role_id
        WHERE ur.user_id = p_user_id
        AND (ur.company_id = p_company_id OR ur.company_id IS NULL)
        AND rp.permission_key = p_permission_key
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$;


ALTER FUNCTION "public"."has_permission"("p_user_id" "uuid", "p_company_id" "uuid", "p_permission_key" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_role"("role_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    role_id uuid;
BEGIN
    -- Get the role ID for the given role name
    SELECT id INTO role_id
    FROM roles
    WHERE name = role_name;

    -- If role doesn't exist, return false
    IF role_id IS NULL THEN
        RETURN false;
    END IF;

    -- Check if user has the role
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        WHERE ur.user_id = auth.uid()
        AND ur.role_id = role_id
    );
END;
$$;


ALTER FUNCTION "public"."has_role"("role_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_system_role"("role_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if user has the system role
    RETURN EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid()
        AND r.name = role_name
        AND r.is_system_role = true
    );
END;
$$;


ALTER FUNCTION "public"."has_system_role"("role_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_app_admin"() RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = auth.uid()
    AND r.name = 'App_Admin'
    AND r.is_system_role = true
  );
$$;


ALTER FUNCTION "public"."is_app_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_company_admin"("company_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        JOIN public.user_companies uc ON ur.user_id = uc.user_id
        WHERE ur.user_id = auth.uid()
        AND uc.company_id = is_company_admin.company_id
        AND r.name = 'Company_Admin'
    );
END;
$$;


ALTER FUNCTION "public"."is_company_admin"("company_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_user_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO audit_log (
      action,
      performed_by,
      target_id,
      target_type,
      company_id,
      details
    ) VALUES (
      'user_status_change',
      auth.uid(),
      NEW.user_id,
      'user',
      NEW.company_id,
      jsonb_build_object(
        'previous_status', OLD.status,
        'new_status', NEW.status
      )
    );
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."log_user_status_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_protected_role_deletion"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM protected_roles WHERE name = OLD.name) THEN
        RAISE EXCEPTION 'Cannot delete protected system roles. This must be done through a database migration.';
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."prevent_protected_role_deletion"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_protected_role_modification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM protected_roles WHERE name = OLD.name) 
       AND (OLD.name != NEW.name OR OLD.description != NEW.description) THEN
        RAISE EXCEPTION 'Cannot modify protected system roles. This must be done through a database migration.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."prevent_protected_role_modification"() OWNER TO "postgres";


-- First drop the triggers that depend on the function
DROP TRIGGER IF EXISTS refresh_user_role_permissions_view_trigger ON user_roles;
DROP TRIGGER IF EXISTS refresh_user_role_permissions_view_trigger_roles ON roles;

-- Then drop the function
DROP FUNCTION IF EXISTS public.refresh_user_role_permissions_view();

-- Create the new function
CREATE OR REPLACE FUNCTION public.refresh_user_role_permissions_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_role_permissions_view;
END;
$$;

-- Remove any remaining trigger function
DROP FUNCTION IF EXISTS refresh_user_role_permissions_view_trigger();


CREATE OR REPLACE FUNCTION "public"."restore_company"("company_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE companies
  SET archived_at = NULL
  WHERE id = company_id;
END;
$$;


ALTER FUNCTION "public"."restore_company"("company_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."schema_to_sql"("schema_name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result text := '';
    table_record record;
    column_record record;
    constraint_record record;
    index_record record;
    policy_record record;
BEGIN
    -- Validate input
    IF schema_name IS NULL THEN
        RAISE EXCEPTION 'Schema name cannot be null';
    END IF;

    -- Verify schema exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.schemata 
        WHERE schema_name = schema_to_sql.schema_name
    ) THEN
        RAISE EXCEPTION 'Schema "%" does not exist', schema_name;
    END IF;

    -- Get all tables
    FOR table_record IN 
        SELECT table_name::text as table_name
        FROM information_schema.tables 
        WHERE table_schema = schema_name 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        -- Start CREATE TABLE statement
        result := result || format(E'\n-- Table: %I.%I\n', schema_name, table_record.table_name);
        result := result || format('CREATE TABLE IF NOT EXISTS %I.%I (', schema_name, table_record.table_name) || E'\n';
        
        -- Add columns
        FOR column_record IN 
            SELECT 
                column_name::text as column_name,
                data_type::text as data_type,
                character_maximum_length::int as character_maximum_length,
                is_nullable::text as is_nullable,
                column_default::text as column_default
            FROM information_schema.columns
            WHERE table_schema = schema_name 
            AND table_name = table_record.table_name
            ORDER BY ordinal_position
        LOOP
            result := result || format('    %I %s', column_record.column_name, column_record.data_type);
            
            -- Add length for character types
            IF column_record.character_maximum_length IS NOT NULL THEN
                result := result || format('(%s)', column_record.character_maximum_length);
            END IF;
            
            -- Add nullable constraint
            IF column_record.is_nullable = 'NO' THEN
                result := result || ' NOT NULL';
            END IF;
            
            -- Add default value if it exists and is not a sequence
            IF column_record.column_default IS NOT NULL AND 
               column_record.column_default NOT LIKE 'nextval%' THEN
                result := result || ' DEFAULT ' || column_record.column_default;
            END IF;
            
            result := result || ',' || E'\n';
        END LOOP;
        
        -- Add primary key constraints
        FOR constraint_record IN 
            SELECT 
                tc.constraint_name::text as constraint_name,
                string_agg(kcu.column_name::text, ', ' ORDER BY kcu.ordinal_position) as columns
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu 
                ON tc.constraint_name = kcu.constraint_name 
                AND tc.table_schema = kcu.table_schema
            WHERE tc.table_schema = schema_name 
            AND tc.table_name = table_record.table_name
            AND tc.constraint_type = 'PRIMARY KEY'
            GROUP BY tc.constraint_name
        LOOP
            result := result || format('    CONSTRAINT %I PRIMARY KEY (%s)', 
                constraint_record.constraint_name, 
                constraint_record.columns) || ',' || E'\n';
        END LOOP;
        
        -- Remove trailing comma and close parenthesis
        result := rtrim(result, ',\n') || E'\n);\n';
        
        -- Add foreign key constraints
        FOR constraint_record IN 
            SELECT 
                tc.constraint_name::text as constraint_name,
                kcu.column_name::text as column_name,
                ccu.table_name::text as foreign_table_name,
                ccu.column_name::text as foreign_column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu 
                ON tc.constraint_name = kcu.constraint_name 
                AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage ccu 
                ON ccu.constraint_name = tc.constraint_name 
                AND ccu.table_schema = tc.table_schema
            WHERE tc.table_schema = schema_name 
            AND tc.table_name = table_record.table_name
            AND tc.constraint_type = 'FOREIGN KEY'
        LOOP
            result := result || format('ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I.%I(%I);', 
                schema_name, 
                table_record.table_name,
                constraint_record.constraint_name,
                constraint_record.column_name,
                schema_name,
                constraint_record.foreign_table_name,
                constraint_record.foreign_column_name) || E'\n';
        END LOOP;
        
        -- Add indexes (excluding those created by constraints)
        FOR index_record IN 
            SELECT 
                indexname::text as indexname,
                indexdef::text as indexdef
            FROM pg_indexes
            WHERE schemaname = schema_name 
            AND tablename = table_record.table_name
            AND indexname NOT IN (
                SELECT constraint_name 
                FROM information_schema.table_constraints 
                WHERE table_schema = schema_name 
                AND table_name = table_record.table_name
            )
        LOOP
            -- Skip primary key indexes as they're already handled
            IF index_record.indexdef NOT LIKE '%pkey%' THEN
                result := result || index_record.indexdef || E';\n';
            END IF;
        END LOOP;
        
        -- Add RLS policies
        IF EXISTS (
            SELECT 1 
            FROM pg_tables 
            WHERE schemaname = schema_name 
            AND tablename = table_record.table_name 
            AND rowsecurity = true
        ) THEN
            result := result || format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY;\n', 
                schema_name, table_record.table_name);
            
            FOR policy_record IN 
                SELECT 
                    policyname::text as policyname,
                    (permissive::boolean)::text as permissive,
                    roles::text[] as roles,
                    cmd::text as cmd,
                    qual::text as qual,
                    with_check::text as with_check
                FROM pg_policies
                WHERE schemaname = schema_name 
                AND tablename = table_record.table_name
            LOOP
                result := result || format('CREATE POLICY %I ON %I.%I\n', 
                    policy_record.policyname, 
                    schema_name,
                    table_record.table_name);
                    
                IF policy_record.permissive = 'false' THEN
                    result := result || '    AS RESTRICTIVE\n';
                END IF;
                    
                result := result || format('    FOR %s\n', policy_record.cmd);
                
                IF policy_record.roles IS NOT NULL AND 
                   policy_record.roles <> '{public}' AND 
                   array_length(policy_record.roles, 1) > 0 THEN
                    result := result || format('    TO %s\n', 
                        array_to_string(policy_record.roles, ', '));
                END IF;
                
                IF policy_record.qual IS NOT NULL THEN
                    result := result || format('    USING (%s)\n', policy_record.qual);
                END IF;
                
                IF policy_record.with_check IS NOT NULL THEN
                    result := result || format('    WITH CHECK (%s)', policy_record.with_check);
                END IF;
                
                result := result || E';\n';
            END LOOP;
        END IF;
        
        result := result || E'\n';
    END LOOP;

    RETURN result;

EXCEPTION WHEN OTHERS THEN
    -- Log the error and re-raise
    RAISE NOTICE 'Error in schema_to_sql: %', SQLERRM;
    RAISE;
END;
$$;


ALTER FUNCTION "public"."schema_to_sql"("schema_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_audit_log_company_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.company_id := (
        SELECT current_company_id
        FROM profiles
        WHERE id = auth.uid()
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_audit_log_company_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_last_login"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_companies
    SET last_login_at = now()
    WHERE user_id = NEW.user_id
    AND company_id = NEW.company_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_last_login"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_updated_at_column"() IS 'Trigger function to automatically update the updated_at timestamp column. Runs with SECURITY DEFINER to ensure it can always update timestamps regardless of RLS policies.';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."audit_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "action" "text" NOT NULL,
    "performed_by" "uuid",
    "target_id" "uuid",
    "target_type" "text" NOT NULL,
    "company_id" "uuid",
    "details" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ip_address" "text",
    "user_agent" "text"
);


ALTER TABLE "public"."audit_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "action" "text" NOT NULL,
    "target_id" "uuid",
    "target_type" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "details" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_audit_log" (
    "id" "uuid",
    "action" "text",
    "performed_by" "uuid",
    "target_id" "uuid",
    "target_type" "text",
    "company_id" "uuid",
    "details" "jsonb",
    "created_at" timestamp with time zone,
    "ip_address" "text",
    "user_agent" "text",
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_audit_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_audit_log_mismatch" (
    "id" "uuid",
    "action" "text",
    "performed_by" "uuid",
    "target_id" "uuid",
    "target_type" "text",
    "company_id" "uuid",
    "details" "jsonb",
    "created_at" timestamp with time zone,
    "ip_address" "text",
    "user_agent" "text"
);


ALTER TABLE "public"."backup_audit_log_mismatch" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_content" (
    "id" "uuid",
    "company_id" "uuid",
    "name" "text",
    "url" "text",
    "description" "text",
    "content_type" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "updated_by" "uuid",
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_content" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_content_mismatch" (
    "id" "uuid",
    "company_id" "uuid",
    "name" "text",
    "url" "text",
    "description" "text",
    "content_type" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "updated_by" "uuid"
);


ALTER TABLE "public"."backup_content_mismatch" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_profiles" (
    "id" "uuid",
    "email" "text",
    "full_name" "text",
    "avatar_url" "text",
    "current_company_id" "uuid",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "selected_company_id" "uuid",
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_profiles_mismatch" (
    "id" "uuid",
    "email" "text",
    "full_name" "text",
    "avatar_url" "text",
    "current_company_id" "uuid",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "selected_company_id" "uuid",
    "auth_users_id" "uuid"
);


ALTER TABLE "public"."backup_profiles_mismatch" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_roles" (
    "id" "uuid",
    "name" "text",
    "description" "text",
    "is_system_role" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "company_id" "uuid",
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_user_companies" (
    "user_id" "uuid",
    "company_id" "uuid",
    "created_at" timestamp with time zone,
    "status" "public"."user_company_status",
    "last_login_at" timestamp with time zone,
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_user_companies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_user_companies_mismatch" (
    "user_id" "uuid",
    "company_id" "uuid",
    "created_at" timestamp with time zone,
    "status" "public"."user_company_status",
    "last_login_at" timestamp with time zone
);


ALTER TABLE "public"."backup_user_companies_mismatch" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_user_roles" (
    "user_id" "uuid",
    "role_id" "uuid",
    "company_id" "uuid",
    "created_at" timestamp with time zone,
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_user_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."backup_users" (
    "instance_id" "uuid",
    "id" "uuid",
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text",
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text",
    "phone_change_token" character varying(255),
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone,
    "email_change_token_current" character varying(255),
    "email_change_confirm_status" smallint,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255),
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean,
    "backup_timestamp" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."backup_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."companies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "website" "text",
    "settings" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "slug" "text",
    "logo_url" "text",
    "archived_at" timestamp with time zone
);


ALTER TABLE "public"."companies" OWNER TO "postgres";


COMMENT ON COLUMN "public"."companies"."logo_url" IS 'URL to the company logo image';



CREATE TABLE IF NOT EXISTS "public"."content" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid",
    "name" "text" NOT NULL,
    "url" "text",
    "description" "text",
    "content_type" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "updated_by" "uuid"
);


ALTER TABLE "public"."content" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."content_content_tags" (
    "content_id" "uuid" NOT NULL,
    "tag_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."content_content_tags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."content_role_permissions" (
    "content_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "view_permission" boolean DEFAULT false,
    "edit_permission" boolean DEFAULT false
);


ALTER TABLE "public"."content_role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."content_tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "color" "text" NOT NULL,
    "menu_sections" "text"[],
    "company_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."content_tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."content_tags" IS 'Table for storing content tags. Created or verified on 2025-04-17.';



CREATE TABLE IF NOT EXISTS "public"."menu_sections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "color" "text" NOT NULL,
    "parent_id" "uuid",
    "company_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."menu_sections" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "full_name" "text",
    "avatar_url" "text",
    "current_company_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "selected_company_id" "uuid"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."protected_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."protected_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."public_submitters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."public_submitters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_key" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions_backup" (
    "role_id" "uuid",
    "permission_key" "text",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."role_permissions_backup" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_system_role" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "company_id" "uuid"
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles_backup" (
    "id" "uuid",
    "name" "text",
    "description" "text",
    "is_system_role" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "company_id" "uuid"
);


ALTER TABLE "public"."roles_backup" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."roles_view" AS
 SELECT "r"."id",
    "r"."name",
    "r"."description",
    "r"."is_system_role",
    "r"."created_at",
    "r"."updated_at",
    "r"."company_id",
        CASE
            WHEN ("pr"."id" IS NOT NULL) THEN true
            ELSE false
        END AS "is_protected"
   FROM ("public"."roles" "r"
     LEFT JOIN "public"."protected_roles" "pr" ON (("r"."name" = "pr"."name")));


ALTER TABLE "public"."roles_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schema_migrations" (
    "id" integer NOT NULL,
    "name" "text" NOT NULL,
    "applied_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."schema_migrations" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."schema_migrations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."schema_migrations_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."schema_migrations_id_seq" OWNED BY "public"."schema_migrations"."id";



CREATE TABLE IF NOT EXISTS "public"."user_companies" (
    "user_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "status" "public"."user_company_status" DEFAULT 'active'::"public"."user_company_status" NOT NULL,
    "last_login_at" timestamp with time zone
);


ALTER TABLE "public"."user_companies" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_companies"."status" IS 'The status of the user within the company (active, inactive, pending, invited)';



COMMENT ON COLUMN "public"."user_companies"."last_login_at" IS 'Timestamp of the user''s last login to this company';



CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "company_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


CREATE MATERIALIZED VIEW "public"."user_role_permissions_view" AS
 SELECT "ur"."user_id",
    "ur"."company_id",
    "ur"."role_id",
    "r"."name" AS "role_name",
    "rp"."permission_key"
   FROM (("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("r"."id" = "ur"."role_id")))
     JOIN "public"."role_permissions" "rp" ON (("rp"."role_id" = "r"."id")))
  WITH NO DATA;


ALTER TABLE "public"."user_role_permissions_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles_backup" (
    "user_id" "uuid",
    "role_id" "uuid",
    "company_id" "uuid",
    "created_at" timestamp with time zone
);


ALTER TABLE "public"."user_roles_backup" OWNER TO "postgres";


ALTER TABLE ONLY "public"."schema_migrations" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."schema_migrations_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."audit_log"
    ADD CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."content_content_tags"
    ADD CONSTRAINT "content_content_tags_pkey" PRIMARY KEY ("content_id", "tag_id");



ALTER TABLE ONLY "public"."content"
    ADD CONSTRAINT "content_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."content_role_permissions"
    ADD CONSTRAINT "content_role_permissions_pkey" PRIMARY KEY ("content_id", "role_id");



ALTER TABLE ONLY "public"."menu_sections"
    ADD CONSTRAINT "menu_sections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."protected_roles"
    ADD CONSTRAINT "protected_roles_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."protected_roles"
    ADD CONSTRAINT "protected_roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."public_submitters"
    ADD CONSTRAINT "public_submitters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id", "permission_key");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."content_tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "unique_user_role_company" UNIQUE ("user_id", "role_id", "company_id");



ALTER TABLE ONLY "public"."user_companies"
    ADD CONSTRAINT "user_companies_pkey" PRIMARY KEY ("user_id", "company_id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id", "role_id");



CREATE INDEX "idx_audit_log_action" ON "public"."audit_log" USING "btree" ("action");



CREATE INDEX "idx_audit_log_company" ON "public"."audit_log" USING "btree" ("company_id");



CREATE INDEX "idx_audit_log_created_at" ON "public"."audit_log" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_audit_log_performed_by" ON "public"."audit_log" USING "btree" ("performed_by");



CREATE INDEX "idx_companies_archived_at" ON "public"."companies" USING "btree" ("archived_at");



CREATE INDEX "idx_companies_slug" ON "public"."companies" USING "btree" ("slug");



CREATE INDEX "idx_content_company_id" ON "public"."content" USING "btree" ("company_id");



CREATE INDEX "idx_content_updated_at" ON "public"."content" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_content_updated_by" ON "public"."content" USING "btree" ("updated_by");



CREATE INDEX "idx_profiles_current_company_id" ON "public"."profiles" USING "btree" ("current_company_id");



CREATE INDEX "idx_profiles_selected_company" ON "public"."profiles" USING "btree" ("selected_company_id");



CREATE INDEX "idx_role_permissions_role_id" ON "public"."role_permissions" USING "btree" ("role_id");



CREATE INDEX "idx_roles_company_id" ON "public"."roles" USING "btree" ("company_id");



CREATE INDEX "idx_user_companies_last_login" ON "public"."user_companies" USING "btree" ("company_id", "last_login_at" DESC);



CREATE INDEX "idx_user_companies_status" ON "public"."user_companies" USING "btree" ("company_id", "status");



CREATE INDEX "idx_user_roles_role_id" ON "public"."user_roles" USING "btree" ("role_id");



CREATE INDEX "idx_user_roles_user_id" ON "public"."user_roles" USING "btree" ("user_id");



CREATE UNIQUE INDEX "user_role_permissions_view_idx" ON "public"."user_role_permissions_view" USING "btree" ("user_id", "company_id", "role_id", "permission_key");



CREATE OR REPLACE TRIGGER "prevent_protected_role_deletion_trigger" BEFORE DELETE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_protected_role_deletion"();



CREATE OR REPLACE TRIGGER "prevent_protected_role_modification_trigger" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_protected_role_modification"();



CREATE OR REPLACE TRIGGER "set_content_tags_updated_at" BEFORE UPDATE ON "public"."content_tags" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_audit_logs_updated_at" BEFORE UPDATE ON "public"."audit_logs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_companies_updated_at" BEFORE UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_roles_updated_at" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "user_status_change_audit" AFTER UPDATE OF "status" ON "public"."user_companies" FOR EACH ROW EXECUTE FUNCTION "public"."log_user_status_change"();



ALTER TABLE ONLY "public"."audit_log"
    ADD CONSTRAINT "audit_log_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."audit_log"
    ADD CONSTRAINT "audit_log_performed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."content"
    ADD CONSTRAINT "content_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content_content_tags"
    ADD CONSTRAINT "content_content_tags_content_id_fkey" FOREIGN KEY ("content_id") REFERENCES "public"."content"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content_content_tags"
    ADD CONSTRAINT "content_content_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."content_tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content_role_permissions"
    ADD CONSTRAINT "content_role_permissions_content_id_fkey" FOREIGN KEY ("content_id") REFERENCES "public"."content"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content_role_permissions"
    ADD CONSTRAINT "content_role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content_tags"
    ADD CONSTRAINT "content_tags_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."content"
    ADD CONSTRAINT "content_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "fk_profiles_current_company_id" FOREIGN KEY ("current_company_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_companies"
    ADD CONSTRAINT "fk_user_companies_user_id" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."menu_sections"
    ADD CONSTRAINT "menu_sections_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."menu_sections"
    ADD CONSTRAINT "menu_sections_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."menu_sections"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_selected_company_id_fkey" FOREIGN KEY ("selected_company_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_companies"
    ADD CONSTRAINT "user_companies_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_companies"
    ADD CONSTRAINT "user_companies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow users to view roles v2" ON "public"."user_roles" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'App_Admin'::"text") AND ("r"."is_system_role" = true))))));



CREATE POLICY "Anyone can create public submitter profiles" ON "public"."public_submitters" FOR INSERT TO "authenticated", "anon" WITH CHECK (true);



CREATE POLICY "App admins can manage custom roles" ON "public"."roles" TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") AND (NOT (EXISTS ( SELECT 1
   FROM "public"."protected_roles" "pr"
  WHERE ("pr"."name" = "roles"."name")))))) WITH CHECK (("public"."has_system_role"('App_Admin'::"text") AND (NOT (EXISTS ( SELECT 1
   FROM "public"."protected_roles" "pr"
  WHERE ("pr"."name" = "roles"."name"))))));



CREATE POLICY "App admins can view protected roles" ON "public"."protected_roles" FOR SELECT TO "authenticated" USING ("public"."has_system_role"('App_Admin'::"text"));



CREATE POLICY "App_Admin can delete companies" ON "public"."companies" FOR DELETE TO "authenticated" USING ("public"."is_app_admin"());



CREATE POLICY "App_Admin can insert companies" ON "public"."companies" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_app_admin"());



CREATE POLICY "App_Admin can update companies" ON "public"."companies" FOR UPDATE TO "authenticated" USING ("public"."is_app_admin"()) WITH CHECK ("public"."is_app_admin"());



CREATE POLICY "App_Admin can view companies" ON "public"."companies" FOR SELECT TO "authenticated" USING ("public"."is_app_admin"());



CREATE POLICY "App_Admin can view content" ON "public"."content" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles" "ur"
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("ur"."role_id" = '00000000-0000-0000-0000-000000000001'::"uuid")))));



CREATE POLICY "Company admins can create role permissions" ON "public"."role_permissions" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."roles" "r2"
          WHERE (("r2"."id" = "role_permissions"."role_id") AND ("r2"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"()))))))))));



CREATE POLICY "Company admins can delete role permissions" ON "public"."role_permissions" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."roles" "r2"
          WHERE (("r2"."id" = "role_permissions"."role_id") AND ("r2"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"()))))))))));



CREATE POLICY "Company admins can manage user roles" ON "public"."user_roles" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."user_companies" "uc"
          WHERE (("uc"."user_id" = "user_roles"."user_id") AND ("uc"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"()))))))))));



CREATE POLICY "Company admins can manage users in their company" ON "public"."user_roles" USING ((EXISTS ( SELECT 1
   FROM (("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
     JOIN "public"."user_companies" "uc" ON (("uc"."user_id" = "user_roles"."user_id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND ("uc"."company_id" = ( SELECT "profiles"."current_company_id"
           FROM "public"."profiles"
          WHERE ("profiles"."id" = "auth"."uid"())))))));



CREATE POLICY "Company admins can update role permissions" ON "public"."role_permissions" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."roles" "r2"
          WHERE (("r2"."id" = "role_permissions"."role_id") AND ("r2"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"())))))))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."roles" "r2"
          WHERE (("r2"."id" = "role_permissions"."role_id") AND ("r2"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"()))))))))));



CREATE POLICY "Company admins can view company roles" ON "public"."roles" FOR SELECT USING (((NOT "is_system_role") OR (EXISTS ( SELECT 1
   FROM "public"."user_roles" "ur"
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("ur"."role_id" = "roles"."id") AND ("roles"."name" = 'Company_Admin'::"text"))))));



CREATE POLICY "Company admins can view role permissions" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'Company_Admin'::"text") AND (EXISTS ( SELECT 1
           FROM "public"."roles" "r2"
          WHERE (("r2"."id" = "role_permissions"."role_id") AND ("r2"."company_id" = ( SELECT "profiles"."current_company_id"
                   FROM "public"."profiles"
                  WHERE ("profiles"."id" = "auth"."uid"()))))))))));



CREATE POLICY "Content: Company-based access" ON "public"."content" TO "authenticated" USING (("company_id" = ( SELECT "profiles"."current_company_id"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"()))));



CREATE POLICY "ContentRolePermissions: Company-based access" ON "public"."content_role_permissions" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."content"
  WHERE (("content"."id" = "content_role_permissions"."content_id") AND ("content"."company_id" = ( SELECT "profiles"."current_company_id"
           FROM "public"."profiles"
          WHERE ("profiles"."id" = "auth"."uid"())))))));



CREATE POLICY "System roles can view content" ON "public"."content" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("r"."id" = "ur"."role_id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."is_system_role" = true)))));



CREATE POLICY "System roles can view menu_sections" ON "public"."menu_sections" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("r"."id" = "ur"."role_id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."is_system_role" = true)))));



CREATE POLICY "System roles can view tags" ON "public"."content_tags" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("r"."id" = "ur"."role_id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."is_system_role" = true)))));



CREATE POLICY "Test has_permission function" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING ("public"."has_permission"('roles.view'::"text"));



CREATE POLICY "Test has_role function" ON "public"."roles" FOR SELECT TO "authenticated" USING ("public"."has_role"('App_Admin'::"text"));



CREATE POLICY "Test has_system_role function" ON "public"."roles" FOR SELECT TO "authenticated" USING ("public"."has_system_role"('App_Admin'::"text"));



CREATE POLICY "Users can access roles in their companies" ON "public"."roles" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "roles"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can create company menu sections" ON "public"."menu_sections" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "menu_sections"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can create company tags" ON "public"."content_tags" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "content_tags"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can create content tags in their company" ON "public"."content_tags" FOR INSERT WITH CHECK (("company_id" = (("auth"."jwt"() ->> 'company_id'::"text"))::"uuid"));



CREATE POLICY "Users can delete company menu sections" ON "public"."menu_sections" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "menu_sections"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can delete company tags" ON "public"."content_tags" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "content_tags"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can delete content tags in their company" ON "public"."content_tags" FOR DELETE USING (("company_id" = (("auth"."jwt"() ->> 'company_id'::"text"))::"uuid"));



CREATE POLICY "Users can manage content in their company" ON "public"."content" TO "authenticated" USING (("company_id" = ( SELECT "profiles"."current_company_id"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"())))) WITH CHECK (("company_id" = ( SELECT "profiles"."current_company_id"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"()))));



CREATE POLICY "Users can manage content tag relationships" ON "public"."content_content_tags" USING (("tag_id" IN ( SELECT "content_tags"."id"
   FROM "public"."content_tags"
  WHERE ("content_tags"."company_id" IN ( SELECT "user_companies"."company_id"
           FROM "public"."user_companies"
          WHERE ("user_companies"."user_id" = "auth"."uid"())))))) WITH CHECK (("tag_id" IN ( SELECT "content_tags"."id"
   FROM "public"."content_tags"
  WHERE ("content_tags"."company_id" IN ( SELECT "user_companies"."company_id"
           FROM "public"."user_companies"
          WHERE ("user_companies"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Users can manage content tags for their companies" ON "public"."content_tags" USING (("company_id" IN ( SELECT "user_companies"."company_id"
   FROM "public"."user_companies"
  WHERE ("user_companies"."user_id" = "auth"."uid"())))) WITH CHECK (("company_id" IN ( SELECT "user_companies"."company_id"
   FROM "public"."user_companies"
  WHERE ("user_companies"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can read their own profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update company menu sections" ON "public"."menu_sections" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "menu_sections"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can update company tags" ON "public"."content_tags" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "content_tags"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can update content tags in their company" ON "public"."content_tags" FOR UPDATE USING (("company_id" = (("auth"."jwt"() ->> 'company_id'::"text"))::"uuid")) WITH CHECK (("company_id" = (("auth"."jwt"() ->> 'company_id'::"text"))::"uuid"));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can update their own last login" ON "public"."user_companies" FOR UPDATE USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can view companies they belong to" ON "public"."companies" FOR SELECT TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."user_companies" "uc"
  WHERE (("uc"."user_id" = "auth"."uid"()) AND ("uc"."company_id" = "companies"."id"))))));



CREATE POLICY "Users can view company menu sections" ON "public"."menu_sections" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_companies"
  WHERE (("user_companies"."company_id" = "menu_sections"."company_id") AND ("user_companies"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can view company tags" ON "public"."content_tags";



CREATE POLICY "Users can view content in their company" ON "public"."content" FOR SELECT TO "authenticated" USING (("company_id" = ( SELECT "profiles"."current_company_id"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"()))));



CREATE POLICY "Users can view content tags in their company" ON "public"."content_tags" FOR SELECT USING (("company_id" = (("auth"."jwt"() ->> 'company_id'::"text"))::"uuid"));



CREATE POLICY "Users can view content tags they have access to" ON "public"."content_tags" FOR SELECT USING (("company_id" IN ( SELECT "user_companies"."company_id"
   FROM "public"."user_companies"
  WHERE ("user_companies"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can view own company associations" ON "public"."user_companies" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view public submitter profiles" ON "public"."public_submitters" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can view role permissions" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."user_roles" "ur"
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("ur"."role_id" = "role_permissions"."role_id"))))));



CREATE POLICY "Users can view roles" ON "public"."roles" FOR SELECT TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."user_roles" "ur"
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("ur"."role_id" = "roles"."id"))))));



CREATE POLICY "Users can view roles v2" ON "public"."user_roles" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE (("ur"."user_id" = "auth"."uid"()) AND ("r"."name" = 'App_Admin'::"text") AND ("r"."is_system_role" = true))))));



CREATE POLICY "Users can view their company assignments" ON "public"."user_companies" FOR SELECT TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") OR ("user_id" = "auth"."uid"())));



CREATE POLICY "Users can view their role assignments" ON "public"."user_roles" FOR SELECT TO "authenticated" USING (("public"."has_system_role"('App_Admin'::"text") OR ("user_id" = "auth"."uid"())));



ALTER TABLE "public"."audit_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content_content_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content_role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."menu_sections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."public_submitters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_companies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";











































































































































































GRANT ALL ON FUNCTION "public"."archive_company"("company_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."archive_company"("company_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_company"("company_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_audit_log_entry"("action" "text", "target_id" "uuid", "target_type" "text", "details" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_audit_log_entry"("action" "text", "target_id" "uuid", "target_type" "text", "details" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_audit_log_entry"("action" "text", "target_id" "uuid", "target_type" "text", "details" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."current_company_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_company_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_company_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_companies"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_companies"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_companies"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_roles"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_roles"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_roles"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_company_permission"("permission" "text", "company_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_company_permission"("permission" "text", "company_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_company_permission"("permission" "text", "company_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_permission"("permission_key" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("permission_key" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("permission_key" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_permission"("user_id" "uuid", "permission_key" "text", "company_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("user_id" "uuid", "permission_key" "text", "company_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("user_id" "uuid", "permission_key" "text", "company_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_permission"("p_user_id" "uuid", "p_company_id" "uuid", "p_permission_key" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("p_user_id" "uuid", "p_company_id" "uuid", "p_permission_key" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("p_user_id" "uuid", "p_company_id" "uuid", "p_permission_key" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("role_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."has_role"("role_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_role"("role_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_system_role"("role_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."has_system_role"("role_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_system_role"("role_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_app_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_app_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_app_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_company_admin"("company_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_company_admin"("company_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_company_admin"("company_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_user_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_user_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_user_status_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_protected_role_deletion"() TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_protected_role_deletion"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_protected_role_deletion"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_protected_role_modification"() TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_protected_role_modification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_protected_role_modification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_user_role_permissions_view"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_user_role_permissions_view"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_user_role_permissions_view"() TO "service_role";



GRANT ALL ON FUNCTION "public"."restore_company"("company_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."restore_company"("company_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."restore_company"("company_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."schema_to_sql"("schema_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."schema_to_sql"("schema_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."schema_to_sql"("schema_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_audit_log_company_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_audit_log_company_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_audit_log_company_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_last_login"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_last_login"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_last_login"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."audit_log" TO "anon";
GRANT ALL ON TABLE "public"."audit_log" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_log" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."backup_audit_log" TO "anon";
GRANT ALL ON TABLE "public"."backup_audit_log" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_audit_log" TO "service_role";



GRANT ALL ON TABLE "public"."backup_audit_log_mismatch" TO "anon";
GRANT ALL ON TABLE "public"."backup_audit_log_mismatch" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_audit_log_mismatch" TO "service_role";



GRANT ALL ON TABLE "public"."backup_content" TO "anon";
GRANT ALL ON TABLE "public"."backup_content" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_content" TO "service_role";



GRANT ALL ON TABLE "public"."backup_content_mismatch" TO "anon";
GRANT ALL ON TABLE "public"."backup_content_mismatch" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_content_mismatch" TO "service_role";



GRANT ALL ON TABLE "public"."backup_profiles" TO "anon";
GRANT ALL ON TABLE "public"."backup_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."backup_profiles_mismatch" TO "anon";
GRANT ALL ON TABLE "public"."backup_profiles_mismatch" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_profiles_mismatch" TO "service_role";



GRANT ALL ON TABLE "public"."backup_roles" TO "anon";
GRANT ALL ON TABLE "public"."backup_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_roles" TO "service_role";



GRANT ALL ON TABLE "public"."backup_user_companies" TO "anon";
GRANT ALL ON TABLE "public"."backup_user_companies" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_user_companies" TO "service_role";



GRANT ALL ON TABLE "public"."backup_user_companies_mismatch" TO "anon";
GRANT ALL ON TABLE "public"."backup_user_companies_mismatch" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_user_companies_mismatch" TO "service_role";



GRANT ALL ON TABLE "public"."backup_user_roles" TO "anon";
GRANT ALL ON TABLE "public"."backup_user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_user_roles" TO "service_role";



GRANT ALL ON TABLE "public"."backup_users" TO "anon";
GRANT ALL ON TABLE "public"."backup_users" TO "authenticated";
GRANT ALL ON TABLE "public"."backup_users" TO "service_role";



GRANT ALL ON TABLE "public"."companies" TO "anon";
GRANT ALL ON TABLE "public"."companies" TO "authenticated";
GRANT ALL ON TABLE "public"."companies" TO "service_role";



GRANT ALL ON TABLE "public"."content" TO "anon";
GRANT ALL ON TABLE "public"."content" TO "authenticated";
GRANT ALL ON TABLE "public"."content" TO "service_role";



GRANT ALL ON TABLE "public"."content_content_tags" TO "anon";
GRANT ALL ON TABLE "public"."content_content_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."content_content_tags" TO "service_role";



GRANT ALL ON TABLE "public"."content_role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."content_role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."content_role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."content_tags" TO "anon";
GRANT ALL ON TABLE "public"."content_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."content_tags" TO "service_role";



GRANT ALL ON TABLE "public"."menu_sections" TO "anon";
GRANT ALL ON TABLE "public"."menu_sections" TO "authenticated";
GRANT ALL ON TABLE "public"."menu_sections" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."protected_roles" TO "anon";
GRANT ALL ON TABLE "public"."protected_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."protected_roles" TO "service_role";



GRANT ALL ON TABLE "public"."public_submitters" TO "anon";
GRANT ALL ON TABLE "public"."public_submitters" TO "authenticated";
GRANT ALL ON TABLE "public"."public_submitters" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions_backup" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions_backup" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions_backup" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."roles_backup" TO "anon";
GRANT ALL ON TABLE "public"."roles_backup" TO "authenticated";
GRANT ALL ON TABLE "public"."roles_backup" TO "service_role";



GRANT ALL ON TABLE "public"."roles_view" TO "anon";
GRANT ALL ON TABLE "public"."roles_view" TO "authenticated";
GRANT ALL ON TABLE "public"."roles_view" TO "service_role";



GRANT ALL ON TABLE "public"."schema_migrations" TO "anon";
GRANT ALL ON TABLE "public"."schema_migrations" TO "authenticated";
GRANT ALL ON TABLE "public"."schema_migrations" TO "service_role";



GRANT ALL ON SEQUENCE "public"."schema_migrations_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."schema_migrations_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."schema_migrations_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_companies" TO "anon";
GRANT ALL ON TABLE "public"."user_companies" TO "authenticated";
GRANT ALL ON TABLE "public"."user_companies" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";



GRANT ALL ON TABLE "public"."user_role_permissions_view" TO "anon";
GRANT ALL ON TABLE "public"."user_role_permissions_view" TO "authenticated";
GRANT ALL ON TABLE "public"."user_role_permissions_view" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles_backup" TO "anon";
GRANT ALL ON TABLE "public"."user_roles_backup" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles_backup" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
