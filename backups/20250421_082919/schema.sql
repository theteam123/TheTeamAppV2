--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.12 (Homebrew)

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

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: backups; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA backups;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Standard public schema - backup tables have been removed';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: user_company_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_company_status AS ENUM (
    'active',
    'inactive',
    'pending',
    'invited'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: cleanup_expired_sessions(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.cleanup_expired_sessions() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  DELETE FROM auth.sessions
  WHERE expires_at < NOW();
END;
$$;


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: handle_session_cleanup(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.handle_session_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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
$$;


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: validate_session(uuid); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.validate_session(session_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  is_valid boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM auth.sessions
    WHERE id = session_id
    AND expires_at > NOW()
  ) INTO is_valid;
  
  RETURN is_valid;
END;
$$;


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


--
-- Name: archive_company(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.archive_company(company_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE companies
  SET archived_at = NOW()
  WHERE id = company_id;
END;
$$;


--
-- Name: create_audit_log_entry(text, uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_audit_log_entry(action text, target_id uuid, target_type text, details jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: current_company_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_company_id() RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: get_user_companies(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_companies() RETURNS TABLE(id uuid, name text, website text, settings jsonb, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: get_user_roles(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_roles(user_id uuid) RETURNS TABLE(role_id uuid, role_name text, is_system_role boolean, permissions jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_company_permission(text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_company_permission(permission text, company_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_permission(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_permission(permission_key text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_permission(uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_permission(user_id uuid, permission_key text, company_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_permission(uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_permission(p_user_id uuid, p_company_id uuid, p_permission_key text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_role(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(role_name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: has_system_role(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_system_role(role_name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: is_app_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_app_admin() RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
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


--
-- Name: is_company_admin(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_company_admin(company_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: log_user_status_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_user_status_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: prevent_protected_role_deletion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_protected_role_deletion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM protected_roles WHERE name = OLD.name) THEN
        RAISE EXCEPTION 'Cannot delete protected system roles. This must be done through a database migration.';
    END IF;
    RETURN OLD;
END;
$$;


--
-- Name: prevent_protected_role_modification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_protected_role_modification() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM protected_roles WHERE name = OLD.name) 
       AND (OLD.name != NEW.name OR OLD.description != NEW.description) THEN
        RAISE EXCEPTION 'Cannot modify protected system roles. This must be done through a database migration.';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: refresh_user_role_permissions_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_user_role_permissions_view() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_role_permissions_view;
END;
$$;


--
-- Name: restore_company(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.restore_company(company_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE companies
  SET archived_at = NULL
  WHERE id = company_id;
END;
$$;


--
-- Name: schema_to_sql(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.schema_to_sql(schema_name text) RETURNS text
    LANGUAGE plpgsql
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


--
-- Name: set_audit_log_company_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_audit_log_company_id() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: update_last_login(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_last_login() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.user_companies
    SET last_login_at = now()
    WHERE user_id = NEW.user_id
    AND company_id = NEW.company_id;
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_updated_at_column(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_updated_at_column() IS 'Trigger function to automatically update the updated_at timestamp column. Runs with SECURITY DEFINER to ensure it can always update timestamps regardless of RLS policies.';


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      PERFORM pg_notify(
          'realtime:system',
          jsonb_build_object(
              'error', SQLERRM,
              'function', 'realtime.send',
              'event', event,
              'topic', topic,
              'private', private
          )::text
      );
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    action text NOT NULL,
    performed_by uuid,
    target_id uuid,
    target_type text NOT NULL,
    company_id uuid,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    ip_address text,
    user_agent text
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    website text,
    settings jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    slug text,
    logo_url text,
    archived_at timestamp with time zone
);


--
-- Name: COLUMN companies.logo_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.companies.logo_url IS 'URL to the company logo image';


--
-- Name: content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid,
    name text NOT NULL,
    url text,
    description text,
    content_type text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    updated_by uuid
);


--
-- Name: content_content_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_content_tags (
    content_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: content_role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_role_permissions (
    content_id uuid NOT NULL,
    role_id uuid NOT NULL,
    view_permission boolean DEFAULT false,
    edit_permission boolean DEFAULT false
);


--
-- Name: content_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    color text NOT NULL,
    menu_sections text[],
    company_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE content_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.content_tags IS 'Table for storing content tags. Created or verified on 2025-04-17.';


--
-- Name: menu_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_sections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    color text NOT NULL,
    parent_id uuid,
    company_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text NOT NULL,
    full_name text,
    avatar_url text,
    current_company_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    selected_company_id uuid
);


--
-- Name: protected_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protected_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: public_submitters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_submitters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    is_system_role boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    company_id uuid
);


--
-- Name: roles_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.roles_view AS
 SELECT r.id,
    r.name,
    r.description,
    r.is_system_role,
    r.created_at,
    r.updated_at,
    r.company_id,
        CASE
            WHEN (pr.id IS NOT NULL) THEN true
            ELSE false
        END AS is_protected
   FROM (public.roles r
     LEFT JOIN public.protected_roles pr ON ((r.name = pr.name)));


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    id integer NOT NULL,
    name text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schema_migrations_id_seq OWNED BY public.schema_migrations.id;


--
-- Name: user_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_companies (
    user_id uuid NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    status public.user_company_status DEFAULT 'active'::public.user_company_status NOT NULL,
    last_login_at timestamp with time zone
);


--
-- Name: COLUMN user_companies.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_companies.status IS 'The status of the user within the company (active, inactive, pending, invited)';


--
-- Name: COLUMN user_companies.last_login_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_companies.last_login_at IS 'Timestamp of the user''s last login to this company';


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    company_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_role_permissions_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.user_role_permissions_view AS
 SELECT ur.user_id,
    ur.company_id,
    ur.role_id,
    r.name AS role_name,
    rp.permission_key
   FROM ((public.user_roles ur
     JOIN public.roles r ON ((r.id = ur.role_id)))
     JOIN public.role_permissions rp ON ((rp.role_id = r.id)))
  WITH NO DATA;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: schema_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.schema_migrations_id_seq'::regclass);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_slug_key UNIQUE (slug);


--
-- Name: content_content_tags content_content_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_content_tags
    ADD CONSTRAINT content_content_tags_pkey PRIMARY KEY (content_id, tag_id);


--
-- Name: content content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content
    ADD CONSTRAINT content_pkey PRIMARY KEY (id);


--
-- Name: content_role_permissions content_role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_role_permissions
    ADD CONSTRAINT content_role_permissions_pkey PRIMARY KEY (content_id, role_id);


--
-- Name: menu_sections menu_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_sections
    ADD CONSTRAINT menu_sections_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: protected_roles protected_roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protected_roles
    ADD CONSTRAINT protected_roles_name_key UNIQUE (name);


--
-- Name: protected_roles protected_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protected_roles
    ADD CONSTRAINT protected_roles_pkey PRIMARY KEY (id);


--
-- Name: public_submitters public_submitters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_submitters
    ADD CONSTRAINT public_submitters_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_key);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: content_tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_roles unique_user_role_company; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT unique_user_role_company UNIQUE (user_id, role_id, company_id);


--
-- Name: user_companies user_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_pkey PRIMARY KEY (user_id, company_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_audit_log_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_log_action ON public.audit_log USING btree (action);


--
-- Name: idx_audit_log_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_log_company ON public.audit_log USING btree (company_id);


--
-- Name: idx_audit_log_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_log_created_at ON public.audit_log USING btree (created_at DESC);


--
-- Name: idx_audit_log_performed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_log_performed_by ON public.audit_log USING btree (performed_by);


--
-- Name: idx_companies_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_archived_at ON public.companies USING btree (archived_at);


--
-- Name: idx_companies_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_slug ON public.companies USING btree (slug);


--
-- Name: idx_content_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_company_id ON public.content USING btree (company_id);


--
-- Name: idx_content_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_updated_at ON public.content USING btree (updated_at DESC);


--
-- Name: idx_content_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_updated_by ON public.content USING btree (updated_by);


--
-- Name: idx_profiles_current_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_current_company_id ON public.profiles USING btree (current_company_id);


--
-- Name: idx_profiles_selected_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_selected_company ON public.profiles USING btree (selected_company_id);


--
-- Name: idx_role_permissions_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role_permissions_role_id ON public.role_permissions USING btree (role_id);


--
-- Name: idx_roles_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roles_company_id ON public.roles USING btree (company_id);


--
-- Name: idx_user_companies_last_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_companies_last_login ON public.user_companies USING btree (company_id, last_login_at DESC);


--
-- Name: idx_user_companies_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_companies_status ON public.user_companies USING btree (company_id, status);


--
-- Name: idx_user_roles_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_roles_role_id ON public.user_roles USING btree (role_id);


--
-- Name: idx_user_roles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_roles_user_id ON public.user_roles USING btree (user_id);


--
-- Name: user_role_permissions_view_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_role_permissions_view_idx ON public.user_role_permissions_view USING btree (user_id, company_id, role_id, permission_key);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: users handle_session_cleanup_trigger; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER handle_session_cleanup_trigger AFTER INSERT OR UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.handle_session_cleanup();


--
-- Name: users on_auth_login; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_login AFTER INSERT OR UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.handle_session_cleanup();


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: roles prevent_protected_role_deletion_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER prevent_protected_role_deletion_trigger BEFORE DELETE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.prevent_protected_role_deletion();


--
-- Name: roles prevent_protected_role_modification_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER prevent_protected_role_modification_trigger BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.prevent_protected_role_modification();


--
-- Name: content_tags set_content_tags_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_content_tags_updated_at BEFORE UPDATE ON public.content_tags FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: companies update_companies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: roles update_roles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_companies user_status_change_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER user_status_change_audit AFTER UPDATE OF status ON public.user_companies FOR EACH ROW EXECUTE FUNCTION public.log_user_status_change();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: content content_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content
    ADD CONSTRAINT content_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: content_content_tags content_content_tags_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_content_tags
    ADD CONSTRAINT content_content_tags_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.content(id) ON DELETE CASCADE;


--
-- Name: content_content_tags content_content_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_content_tags
    ADD CONSTRAINT content_content_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.content_tags(id) ON DELETE CASCADE;


--
-- Name: content_role_permissions content_role_permissions_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_role_permissions
    ADD CONSTRAINT content_role_permissions_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.content(id) ON DELETE CASCADE;


--
-- Name: content_role_permissions content_role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_role_permissions
    ADD CONSTRAINT content_role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: content_tags content_tags_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_tags
    ADD CONSTRAINT content_tags_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: content content_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content
    ADD CONSTRAINT content_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: profiles fk_profiles_current_company_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT fk_profiles_current_company_id FOREIGN KEY (current_company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: user_companies fk_user_companies_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT fk_user_companies_user_id FOREIGN KEY (user_id) REFERENCES public.profiles(id);


--
-- Name: menu_sections menu_sections_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_sections
    ADD CONSTRAINT menu_sections_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: menu_sections menu_sections_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_sections
    ADD CONSTRAINT menu_sections_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.menu_sections(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- Name: profiles profiles_selected_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_selected_company_id_fkey FOREIGN KEY (selected_company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: roles roles_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: user_companies user_companies_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: user_companies user_companies_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: users Users can read their own auth data; Type: POLICY; Schema: auth; Owner: -
--

CREATE POLICY "Users can read their own auth data" ON auth.users FOR SELECT TO authenticated USING ((id = auth.uid()));


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles Allow users to view roles v2; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users to view roles v2" ON public.user_roles FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'App_Admin'::text) AND (r.is_system_role = true))))));


--
-- Name: public_submitters Anyone can create public submitter profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can create public submitter profiles" ON public.public_submitters FOR INSERT TO authenticated, anon WITH CHECK (true);


--
-- Name: roles App admins can manage custom roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App admins can manage custom roles" ON public.roles TO authenticated USING ((public.has_system_role('App_Admin'::text) AND (NOT (EXISTS ( SELECT 1
   FROM public.protected_roles pr
  WHERE (pr.name = roles.name)))))) WITH CHECK ((public.has_system_role('App_Admin'::text) AND (NOT (EXISTS ( SELECT 1
   FROM public.protected_roles pr
  WHERE (pr.name = roles.name))))));


--
-- Name: protected_roles App admins can view protected roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App admins can view protected roles" ON public.protected_roles FOR SELECT TO authenticated USING (public.has_system_role('App_Admin'::text));


--
-- Name: companies App_Admin can delete companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App_Admin can delete companies" ON public.companies FOR DELETE TO authenticated USING (public.is_app_admin());


--
-- Name: companies App_Admin can insert companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App_Admin can insert companies" ON public.companies FOR INSERT TO authenticated WITH CHECK (public.is_app_admin());


--
-- Name: companies App_Admin can update companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App_Admin can update companies" ON public.companies FOR UPDATE TO authenticated USING (public.is_app_admin()) WITH CHECK (public.is_app_admin());


--
-- Name: companies App_Admin can view companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App_Admin can view companies" ON public.companies FOR SELECT TO authenticated USING (public.is_app_admin());


--
-- Name: content App_Admin can view content; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "App_Admin can view content" ON public.content FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_roles ur
  WHERE ((ur.user_id = auth.uid()) AND (ur.role_id = '00000000-0000-0000-0000-000000000001'::uuid)))));


--
-- Name: role_permissions Company admins can create role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can create role permissions" ON public.role_permissions FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.roles r2
          WHERE ((r2.id = role_permissions.role_id) AND (r2.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid()))))))))));


--
-- Name: role_permissions Company admins can delete role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can delete role permissions" ON public.role_permissions FOR DELETE TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.roles r2
          WHERE ((r2.id = role_permissions.role_id) AND (r2.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid()))))))))));


--
-- Name: user_roles Company admins can manage user roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can manage user roles" ON public.user_roles USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.user_companies uc
          WHERE ((uc.user_id = user_roles.user_id) AND (uc.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid()))))))))));


--
-- Name: user_roles Company admins can manage users in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can manage users in their company" ON public.user_roles USING ((EXISTS ( SELECT 1
   FROM ((public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
     JOIN public.user_companies uc ON ((uc.user_id = user_roles.user_id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (uc.company_id = ( SELECT profiles.current_company_id
           FROM public.profiles
          WHERE (profiles.id = auth.uid())))))));


--
-- Name: role_permissions Company admins can update role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can update role permissions" ON public.role_permissions FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.roles r2
          WHERE ((r2.id = role_permissions.role_id) AND (r2.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid())))))))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.roles r2
          WHERE ((r2.id = role_permissions.role_id) AND (r2.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid()))))))))));


--
-- Name: roles Company admins can view company roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can view company roles" ON public.roles FOR SELECT USING (((NOT is_system_role) OR (EXISTS ( SELECT 1
   FROM public.user_roles ur
  WHERE ((ur.user_id = auth.uid()) AND (ur.role_id = roles.id) AND (roles.name = 'Company_Admin'::text))))));


--
-- Name: role_permissions Company admins can view role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Company admins can view role permissions" ON public.role_permissions FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'Company_Admin'::text) AND (EXISTS ( SELECT 1
           FROM public.roles r2
          WHERE ((r2.id = role_permissions.role_id) AND (r2.company_id = ( SELECT profiles.current_company_id
                   FROM public.profiles
                  WHERE (profiles.id = auth.uid()))))))))));


--
-- Name: content Content: Company-based access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Content: Company-based access" ON public.content TO authenticated USING ((company_id = ( SELECT profiles.current_company_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid()))));


--
-- Name: content_role_permissions ContentRolePermissions: Company-based access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ContentRolePermissions: Company-based access" ON public.content_role_permissions TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.content
  WHERE ((content.id = content_role_permissions.content_id) AND (content.company_id = ( SELECT profiles.current_company_id
           FROM public.profiles
          WHERE (profiles.id = auth.uid())))))));


--
-- Name: content System roles can view content; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "System roles can view content" ON public.content FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((r.id = ur.role_id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.is_system_role = true)))));


--
-- Name: menu_sections System roles can view menu_sections; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "System roles can view menu_sections" ON public.menu_sections FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((r.id = ur.role_id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.is_system_role = true)))));


--
-- Name: content_tags System roles can view tags; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "System roles can view tags" ON public.content_tags FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((r.id = ur.role_id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.is_system_role = true)))));


--
-- Name: role_permissions Test has_permission function; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Test has_permission function" ON public.role_permissions FOR SELECT TO authenticated USING (public.has_permission('roles.view'::text));


--
-- Name: roles Test has_role function; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Test has_role function" ON public.roles FOR SELECT TO authenticated USING (public.has_role('App_Admin'::text));


--
-- Name: roles Test has_system_role function; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Test has_system_role function" ON public.roles FOR SELECT TO authenticated USING (public.has_system_role('App_Admin'::text));


--
-- Name: roles Users can access roles in their companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can access roles in their companies" ON public.roles TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = roles.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: menu_sections Users can create company menu sections; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create company menu sections" ON public.menu_sections FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = menu_sections.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can create company tags; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create company tags" ON public.content_tags FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = content_tags.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can create content tags in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create content tags in their company" ON public.content_tags FOR INSERT WITH CHECK ((company_id = ((auth.jwt() ->> 'company_id'::text))::uuid));


--
-- Name: menu_sections Users can delete company menu sections; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete company menu sections" ON public.menu_sections FOR DELETE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = menu_sections.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can delete company tags; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete company tags" ON public.content_tags FOR DELETE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = content_tags.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can delete content tags in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete content tags in their company" ON public.content_tags FOR DELETE USING ((company_id = ((auth.jwt() ->> 'company_id'::text))::uuid));


--
-- Name: content Users can manage content in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can manage content in their company" ON public.content TO authenticated USING ((company_id = ( SELECT profiles.current_company_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid())))) WITH CHECK ((company_id = ( SELECT profiles.current_company_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid()))));


--
-- Name: content_content_tags Users can manage content tag relationships; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can manage content tag relationships" ON public.content_content_tags USING ((tag_id IN ( SELECT content_tags.id
   FROM public.content_tags
  WHERE (content_tags.company_id IN ( SELECT user_companies.company_id
           FROM public.user_companies
          WHERE (user_companies.user_id = auth.uid())))))) WITH CHECK ((tag_id IN ( SELECT content_tags.id
   FROM public.content_tags
  WHERE (content_tags.company_id IN ( SELECT user_companies.company_id
           FROM public.user_companies
          WHERE (user_companies.user_id = auth.uid()))))));


--
-- Name: content_tags Users can manage content tags for their companies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can manage content tags for their companies" ON public.content_tags USING ((company_id IN ( SELECT user_companies.company_id
   FROM public.user_companies
  WHERE (user_companies.user_id = auth.uid())))) WITH CHECK ((company_id IN ( SELECT user_companies.company_id
   FROM public.user_companies
  WHERE (user_companies.user_id = auth.uid()))));


--
-- Name: profiles Users can read their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can read their own profile" ON public.profiles FOR SELECT TO authenticated USING ((auth.uid() = id));


--
-- Name: menu_sections Users can update company menu sections; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update company menu sections" ON public.menu_sections FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = menu_sections.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can update company tags; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update company tags" ON public.content_tags FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = content_tags.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can update content tags in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update content tags in their company" ON public.content_tags FOR UPDATE USING ((company_id = ((auth.jwt() ->> 'company_id'::text))::uuid)) WITH CHECK ((company_id = ((auth.jwt() ->> 'company_id'::text))::uuid));


--
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: user_companies Users can update their own last login; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own last login" ON public.user_companies FOR UPDATE USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: companies Users can view companies they belong to; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view companies they belong to" ON public.companies FOR SELECT TO authenticated USING ((public.has_system_role('App_Admin'::text) OR (EXISTS ( SELECT 1
   FROM public.user_companies uc
  WHERE ((uc.user_id = auth.uid()) AND (uc.company_id = companies.id))))));


--
-- Name: menu_sections Users can view company menu sections; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view company menu sections" ON public.menu_sections FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_companies
  WHERE ((user_companies.company_id = menu_sections.company_id) AND (user_companies.user_id = auth.uid())))));


--
-- Name: content_tags Users can view company tags; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view company tags" ON public.content_tags;


--
-- Name: content Users can view content in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view content in their company" ON public.content FOR SELECT TO authenticated USING ((company_id = ( SELECT profiles.current_company_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid()))));


--
-- Name: content_tags Users can view content tags in their company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view content tags in their company" ON public.content_tags FOR SELECT USING ((company_id = ((auth.jwt() ->> 'company_id'::text))::uuid));


--
-- Name: content_tags Users can view content tags they have access to; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view content tags they have access to" ON public.content_tags FOR SELECT USING ((company_id IN ( SELECT user_companies.company_id
   FROM public.user_companies
  WHERE (user_companies.user_id = auth.uid()))));


--
-- Name: user_companies Users can view own company associations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own company associations" ON public.user_companies FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: public_submitters Users can view public submitter profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view public submitter profiles" ON public.public_submitters FOR SELECT TO authenticated USING (true);


--
-- Name: role_permissions Users can view role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view role permissions" ON public.role_permissions FOR SELECT TO authenticated USING ((public.has_system_role('App_Admin'::text) OR (EXISTS ( SELECT 1
   FROM public.user_roles ur
  WHERE ((ur.user_id = auth.uid()) AND (ur.role_id = role_permissions.role_id))))));


--
-- Name: roles Users can view roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view roles" ON public.roles FOR SELECT TO authenticated USING ((public.has_system_role('App_Admin'::text) OR (EXISTS ( SELECT 1
   FROM public.user_roles ur
  WHERE ((ur.user_id = auth.uid()) AND (ur.role_id = roles.id))))));


--
-- Name: user_roles Users can view roles v2; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view roles v2" ON public.user_roles FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE ((ur.user_id = auth.uid()) AND (r.name = 'App_Admin'::text) AND (r.is_system_role = true))))));


--
-- Name: user_companies Users can view their company assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their company assignments" ON public.user_companies FOR SELECT TO authenticated USING ((public.has_system_role('App_Admin'::text) OR (user_id = auth.uid())));


--
-- Name: user_roles Users can view their role assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their role assignments" ON public.user_roles FOR SELECT TO authenticated USING ((public.has_system_role('App_Admin'::text) OR (user_id = auth.uid())));


--
-- Name: audit_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

--
-- Name: companies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

--
-- Name: content; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.content ENABLE ROW LEVEL SECURITY;

--
-- Name: content_content_tags; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.content_content_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: content_role_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.content_role_permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: content_tags; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.content_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: menu_sections; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.menu_sections ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: public_submitters; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.public_submitters ENABLE ROW LEVEL SECURITY;

--
-- Name: role_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: user_companies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_companies ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Documents Bucket Policy flreew_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Documents Bucket Policy flreew_0" ON storage.objects FOR SELECT TO authenticated USING ((bucket_id = 'documents'::text));


--
-- Name: objects Documents Bucket Policy flreew_1; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Documents Bucket Policy flreew_1" ON storage.objects FOR INSERT TO authenticated WITH CHECK ((bucket_id = 'documents'::text));


--
-- Name: objects Documents Bucket Policy flreew_2; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Documents Bucket Policy flreew_2" ON storage.objects FOR UPDATE TO authenticated USING ((bucket_id = 'documents'::text));


--
-- Name: objects Documents Bucket Policy flreew_3; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Documents Bucket Policy flreew_3" ON storage.objects FOR DELETE TO authenticated USING ((bucket_id = 'documents'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

