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

DROP EVENT TRIGGER IF EXISTS pgrst_drop_watch;
DROP EVENT TRIGGER IF EXISTS pgrst_ddl_watch;
DROP EVENT TRIGGER IF EXISTS issue_pg_net_access;
DROP EVENT TRIGGER IF EXISTS issue_pg_graphql_access;
DROP EVENT TRIGGER IF EXISTS issue_pg_cron_access;
DROP EVENT TRIGGER IF EXISTS issue_graphql_placeholder;
DROP PUBLICATION IF EXISTS supabase_realtime;
DROP POLICY IF EXISTS "Documents Bucket Policy flreew_3" ON storage.objects;
DROP POLICY IF EXISTS "Documents Bucket Policy flreew_2" ON storage.objects;
DROP POLICY IF EXISTS "Documents Bucket Policy flreew_1" ON storage.objects;
DROP POLICY IF EXISTS "Documents Bucket Policy flreew_0" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their role assignments" ON public.user_roles;
DROP POLICY IF EXISTS "Users can view their company assignments" ON public.user_companies;
DROP POLICY IF EXISTS "Users can view roles v2" ON public.user_roles;
DROP POLICY IF EXISTS "Users can view roles" ON public.roles;
DROP POLICY IF EXISTS "Users can view role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Users can view public submitter profiles" ON public.public_submitters;
DROP POLICY IF EXISTS "Users can view own company associations" ON public.user_companies;
DROP POLICY IF EXISTS "Users can view content tags they have access to" ON public.content_tags;
DROP POLICY IF EXISTS "Users can view content tags in their company" ON public.content_tags;
DROP POLICY IF EXISTS "Users can view content in their company" ON public.content;
DROP POLICY IF EXISTS "Users can view company tags" ON public.content_tags;
DROP POLICY IF EXISTS "Users can view company menu sections" ON public.menu_sections;
DROP POLICY IF EXISTS "Users can view companies they belong to" ON public.companies;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own last login" ON public.user_companies;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update content tags in their company" ON public.content_tags;
DROP POLICY IF EXISTS "Users can update company tags" ON public.content_tags;
DROP POLICY IF EXISTS "Users can update company menu sections" ON public.menu_sections;
DROP POLICY IF EXISTS "Users can read their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can manage content tags for their companies" ON public.content_tags;
DROP POLICY IF EXISTS "Users can manage content tag relationships" ON public.content_content_tags;
DROP POLICY IF EXISTS "Users can manage content in their company" ON public.content;
DROP POLICY IF EXISTS "Users can delete content tags in their company" ON public.content_tags;
DROP POLICY IF EXISTS "Users can delete company tags" ON public.content_tags;
DROP POLICY IF EXISTS "Users can delete company menu sections" ON public.menu_sections;
DROP POLICY IF EXISTS "Users can create content tags in their company" ON public.content_tags;
DROP POLICY IF EXISTS "Users can create company tags" ON public.content_tags;
DROP POLICY IF EXISTS "Users can create company menu sections" ON public.menu_sections;
DROP POLICY IF EXISTS "Users can access roles in their companies" ON public.roles;
DROP POLICY IF EXISTS "Test has_system_role function" ON public.roles;
DROP POLICY IF EXISTS "Test has_role function" ON public.roles;
DROP POLICY IF EXISTS "Test has_permission function" ON public.role_permissions;
DROP POLICY IF EXISTS "System roles can view tags" ON public.content_tags;
DROP POLICY IF EXISTS "System roles can view menu_sections" ON public.menu_sections;
DROP POLICY IF EXISTS "System roles can view content" ON public.content;
DROP POLICY IF EXISTS "ContentRolePermissions: Company-based access" ON public.content_role_permissions;
DROP POLICY IF EXISTS "Content: Company-based access" ON public.content;
DROP POLICY IF EXISTS "Company admins can view role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Company admins can view company roles" ON public.roles;
DROP POLICY IF EXISTS "Company admins can update role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Company admins can manage users in their company" ON public.user_roles;
DROP POLICY IF EXISTS "Company admins can manage user roles" ON public.user_roles;
DROP POLICY IF EXISTS "Company admins can delete role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Company admins can create role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "App_Admin can view content" ON public.content;
DROP POLICY IF EXISTS "App_Admin can view companies" ON public.companies;
DROP POLICY IF EXISTS "App_Admin can update companies" ON public.companies;
DROP POLICY IF EXISTS "App_Admin can insert companies" ON public.companies;
DROP POLICY IF EXISTS "App_Admin can delete companies" ON public.companies;
DROP POLICY IF EXISTS "App admins can view protected roles" ON public.protected_roles;
DROP POLICY IF EXISTS "App admins can manage custom roles" ON public.roles;
DROP POLICY IF EXISTS "Anyone can create public submitter profiles" ON public.public_submitters;
DROP POLICY IF EXISTS "Allow users to view roles v2" ON public.user_roles;
DROP POLICY IF EXISTS "Users can read their own auth data" ON auth.users;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_upload_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS "objects_bucketId_fkey";
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_companies DROP CONSTRAINT IF EXISTS user_companies_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_companies DROP CONSTRAINT IF EXISTS user_companies_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_selected_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE IF EXISTS ONLY public.menu_sections DROP CONSTRAINT IF EXISTS menu_sections_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.menu_sections DROP CONSTRAINT IF EXISTS menu_sections_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_companies DROP CONSTRAINT IF EXISTS fk_user_companies_user_id;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS fk_profiles_current_company_id;
ALTER TABLE IF EXISTS ONLY public.content DROP CONSTRAINT IF EXISTS content_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.content_tags DROP CONSTRAINT IF EXISTS content_tags_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_role_permissions DROP CONSTRAINT IF EXISTS content_role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_role_permissions DROP CONSTRAINT IF EXISTS content_role_permissions_content_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_content_tags DROP CONSTRAINT IF EXISTS content_content_tags_tag_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_content_tags DROP CONSTRAINT IF EXISTS content_content_tags_content_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content DROP CONSTRAINT IF EXISTS content_company_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_company_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_flow_state_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_auth_factor_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_user_id_fkey;
DROP TRIGGER IF EXISTS update_objects_updated_at ON storage.objects;
DROP TRIGGER IF EXISTS tr_check_filters ON realtime.subscription;
DROP TRIGGER IF EXISTS user_status_change_audit ON public.user_companies;
DROP TRIGGER IF EXISTS update_roles_updated_at ON public.roles;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS update_companies_updated_at ON public.companies;
DROP TRIGGER IF EXISTS set_content_tags_updated_at ON public.content_tags;
DROP TRIGGER IF EXISTS prevent_protected_role_modification_trigger ON public.roles;
DROP TRIGGER IF EXISTS prevent_protected_role_deletion_trigger ON public.roles;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_login ON auth.users;
DROP TRIGGER IF EXISTS handle_session_cleanup_trigger ON auth.users;
DROP INDEX IF EXISTS storage.name_prefix_search;
DROP INDEX IF EXISTS storage.idx_objects_bucket_id_name;
DROP INDEX IF EXISTS storage.idx_multipart_uploads_list;
DROP INDEX IF EXISTS storage.bucketid_objname;
DROP INDEX IF EXISTS storage.bname;
DROP INDEX IF EXISTS realtime.subscription_subscription_id_entity_filters_key;
DROP INDEX IF EXISTS realtime.ix_realtime_subscription_entity;
DROP INDEX IF EXISTS public.user_role_permissions_view_idx;
DROP INDEX IF EXISTS public.idx_user_roles_user_id;
DROP INDEX IF EXISTS public.idx_user_roles_role_id;
DROP INDEX IF EXISTS public.idx_user_companies_status;
DROP INDEX IF EXISTS public.idx_user_companies_last_login;
DROP INDEX IF EXISTS public.idx_roles_company_id;
DROP INDEX IF EXISTS public.idx_role_permissions_role_id;
DROP INDEX IF EXISTS public.idx_profiles_selected_company;
DROP INDEX IF EXISTS public.idx_profiles_current_company_id;
DROP INDEX IF EXISTS public.idx_content_updated_by;
DROP INDEX IF EXISTS public.idx_content_updated_at;
DROP INDEX IF EXISTS public.idx_content_company_id;
DROP INDEX IF EXISTS public.idx_companies_slug;
DROP INDEX IF EXISTS public.idx_companies_archived_at;
DROP INDEX IF EXISTS public.idx_audit_log_performed_by;
DROP INDEX IF EXISTS public.idx_audit_log_created_at;
DROP INDEX IF EXISTS public.idx_audit_log_company;
DROP INDEX IF EXISTS public.idx_audit_log_action;
DROP INDEX IF EXISTS auth.users_is_anonymous_idx;
DROP INDEX IF EXISTS auth.users_instance_id_idx;
DROP INDEX IF EXISTS auth.users_instance_id_email_idx;
DROP INDEX IF EXISTS auth.users_email_partial_key;
DROP INDEX IF EXISTS auth.user_id_created_at_idx;
DROP INDEX IF EXISTS auth.unique_phone_factor_per_user;
DROP INDEX IF EXISTS auth.sso_providers_resource_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_domain_idx;
DROP INDEX IF EXISTS auth.sessions_user_id_idx;
DROP INDEX IF EXISTS auth.sessions_not_after_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_for_email_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_created_at_idx;
DROP INDEX IF EXISTS auth.saml_providers_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_updated_at_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_session_id_revoked_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_parent_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_user_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_idx;
DROP INDEX IF EXISTS auth.recovery_token_idx;
DROP INDEX IF EXISTS auth.reauthentication_token_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_user_id_token_type_key;
DROP INDEX IF EXISTS auth.one_time_tokens_token_hash_hash_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_relates_to_hash_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_id_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_friendly_name_unique;
DROP INDEX IF EXISTS auth.mfa_challenge_created_at_idx;
DROP INDEX IF EXISTS auth.idx_user_id_auth_method;
DROP INDEX IF EXISTS auth.idx_auth_code;
DROP INDEX IF EXISTS auth.identities_user_id_idx;
DROP INDEX IF EXISTS auth.identities_email_idx;
DROP INDEX IF EXISTS auth.flow_state_created_at_idx;
DROP INDEX IF EXISTS auth.factor_id_created_at_idx;
DROP INDEX IF EXISTS auth.email_change_token_new_idx;
DROP INDEX IF EXISTS auth.email_change_token_current_idx;
DROP INDEX IF EXISTS auth.confirmation_token_idx;
DROP INDEX IF EXISTS auth.audit_logs_instance_id_idx;
ALTER TABLE IF EXISTS ONLY supabase_migrations.seed_files DROP CONSTRAINT IF EXISTS seed_files_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_pkey;
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS objects_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_name_key;
ALTER TABLE IF EXISTS ONLY storage.buckets DROP CONSTRAINT IF EXISTS buckets_pkey;
ALTER TABLE IF EXISTS ONLY realtime.subscription DROP CONSTRAINT IF EXISTS pk_subscription;
ALTER TABLE IF EXISTS ONLY realtime.messages DROP CONSTRAINT IF EXISTS messages_pkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.user_companies DROP CONSTRAINT IF EXISTS user_companies_pkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS unique_user_role_company;
ALTER TABLE IF EXISTS ONLY public.content_tags DROP CONSTRAINT IF EXISTS tags_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_name_key;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.public_submitters DROP CONSTRAINT IF EXISTS public_submitters_pkey;
ALTER TABLE IF EXISTS ONLY public.protected_roles DROP CONSTRAINT IF EXISTS protected_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.protected_roles DROP CONSTRAINT IF EXISTS protected_roles_name_key;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_email_key;
ALTER TABLE IF EXISTS ONLY public.menu_sections DROP CONSTRAINT IF EXISTS menu_sections_pkey;
ALTER TABLE IF EXISTS ONLY public.content_role_permissions DROP CONSTRAINT IF EXISTS content_role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.content DROP CONSTRAINT IF EXISTS content_pkey;
ALTER TABLE IF EXISTS ONLY public.content_content_tags DROP CONSTRAINT IF EXISTS content_content_tags_pkey;
ALTER TABLE IF EXISTS ONLY public.companies DROP CONSTRAINT IF EXISTS companies_slug_key;
ALTER TABLE IF EXISTS ONLY public.companies DROP CONSTRAINT IF EXISTS companies_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY auth.sso_providers DROP CONSTRAINT IF EXISTS sso_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_pkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_entity_id_key;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_token_unique;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_last_challenged_at_key;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_authentication_method_pkey;
ALTER TABLE IF EXISTS ONLY auth.instances DROP CONSTRAINT IF EXISTS instances_pkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_provider_id_provider_unique;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_pkey;
ALTER TABLE IF EXISTS ONLY auth.flow_state DROP CONSTRAINT IF EXISTS flow_state_pkey;
ALTER TABLE IF EXISTS ONLY auth.audit_log_entries DROP CONSTRAINT IF EXISTS audit_log_entries_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS amr_id_pk;
ALTER TABLE IF EXISTS auth.refresh_tokens ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS supabase_migrations.seed_files;
DROP TABLE IF EXISTS storage.s3_multipart_uploads_parts;
DROP TABLE IF EXISTS storage.s3_multipart_uploads;
DROP TABLE IF EXISTS storage.objects;
DROP TABLE IF EXISTS storage.migrations;
DROP TABLE IF EXISTS storage.buckets;
DROP TABLE IF EXISTS realtime.subscription;
DROP TABLE IF EXISTS realtime.messages;
DROP MATERIALIZED VIEW IF EXISTS public.user_role_permissions_view;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.user_companies;
DROP VIEW IF EXISTS public.roles_view;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.role_permissions;
DROP TABLE IF EXISTS public.public_submitters;
DROP TABLE IF EXISTS public.protected_roles;
DROP TABLE IF EXISTS public.profiles;
DROP TABLE IF EXISTS public.menu_sections;
DROP TABLE IF EXISTS public.content_tags;
DROP TABLE IF EXISTS public.content_role_permissions;
DROP TABLE IF EXISTS public.content_content_tags;
DROP TABLE IF EXISTS public.content;
DROP TABLE IF EXISTS public.companies;
DROP TABLE IF EXISTS public.audit_log;
DROP TABLE IF EXISTS auth.users;
DROP TABLE IF EXISTS auth.sso_providers;
DROP TABLE IF EXISTS auth.sso_domains;
DROP TABLE IF EXISTS auth.sessions;
DROP TABLE IF EXISTS auth.saml_relay_states;
DROP TABLE IF EXISTS auth.saml_providers;
DROP SEQUENCE IF EXISTS auth.refresh_tokens_id_seq;
DROP TABLE IF EXISTS auth.refresh_tokens;
DROP TABLE IF EXISTS auth.one_time_tokens;
DROP TABLE IF EXISTS auth.mfa_factors;
DROP TABLE IF EXISTS auth.mfa_challenges;
DROP TABLE IF EXISTS auth.mfa_amr_claims;
DROP TABLE IF EXISTS auth.instances;
DROP TABLE IF EXISTS auth.identities;
DROP TABLE IF EXISTS auth.flow_state;
DROP TABLE IF EXISTS auth.audit_log_entries;
DROP FUNCTION IF EXISTS storage.update_updated_at_column();
DROP FUNCTION IF EXISTS storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);
DROP FUNCTION IF EXISTS storage.operation();
DROP FUNCTION IF EXISTS storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text);
DROP FUNCTION IF EXISTS storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text);
DROP FUNCTION IF EXISTS storage.get_size_by_bucket();
DROP FUNCTION IF EXISTS storage.foldername(name text);
DROP FUNCTION IF EXISTS storage.filename(name text);
DROP FUNCTION IF EXISTS storage.extension(name text);
DROP FUNCTION IF EXISTS storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb);
DROP FUNCTION IF EXISTS realtime.topic();
DROP FUNCTION IF EXISTS realtime.to_regrole(role_name text);
DROP FUNCTION IF EXISTS realtime.subscription_check_filters();
DROP FUNCTION IF EXISTS realtime.send(payload jsonb, event text, topic text, private boolean);
DROP FUNCTION IF EXISTS realtime.quote_wal2json(entity regclass);
DROP FUNCTION IF EXISTS realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer);
DROP FUNCTION IF EXISTS realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]);
DROP FUNCTION IF EXISTS realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text);
DROP FUNCTION IF EXISTS realtime."cast"(val text, type_ regtype);
DROP FUNCTION IF EXISTS realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]);
DROP FUNCTION IF EXISTS realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text);
DROP FUNCTION IF EXISTS realtime.apply_rls(wal jsonb, max_record_bytes integer);
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP FUNCTION IF EXISTS public.update_last_login();
DROP FUNCTION IF EXISTS public.set_audit_log_company_id();
DROP FUNCTION IF EXISTS public.schema_to_sql(schema_name text);
DROP FUNCTION IF EXISTS public.restore_company(company_id uuid);
DROP FUNCTION IF EXISTS public.refresh_user_role_permissions_view();
DROP FUNCTION IF EXISTS public.prevent_protected_role_modification();
DROP FUNCTION IF EXISTS public.prevent_protected_role_deletion();
DROP FUNCTION IF EXISTS public.log_user_status_change();
DROP FUNCTION IF EXISTS public.is_company_admin(company_id uuid);
DROP FUNCTION IF EXISTS public.is_app_admin();
DROP FUNCTION IF EXISTS public.has_system_role(role_name text);
DROP FUNCTION IF EXISTS public.has_role(role_name text);
DROP FUNCTION IF EXISTS public.has_permission(p_user_id uuid, p_company_id uuid, p_permission_key text);
DROP FUNCTION IF EXISTS public.has_permission(user_id uuid, permission_key text, company_id uuid);
DROP FUNCTION IF EXISTS public.has_permission(permission_key text);
DROP FUNCTION IF EXISTS public.has_company_permission(permission text, company_id uuid);
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.get_user_roles(user_id uuid);
DROP FUNCTION IF EXISTS public.get_user_companies();
DROP FUNCTION IF EXISTS public.current_company_id();
DROP FUNCTION IF EXISTS public.create_audit_log_entry(action text, target_id uuid, target_type text, details jsonb);
DROP FUNCTION IF EXISTS public.archive_company(company_id uuid);
DROP FUNCTION IF EXISTS pgbouncer.get_auth(p_usename text);
DROP FUNCTION IF EXISTS extensions.set_graphql_placeholder();
DROP FUNCTION IF EXISTS extensions.pgrst_drop_watch();
DROP FUNCTION IF EXISTS extensions.pgrst_ddl_watch();
DROP FUNCTION IF EXISTS extensions.grant_pg_net_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_graphql_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_cron_access();
DROP FUNCTION IF EXISTS auth.validate_session(session_id uuid);
DROP FUNCTION IF EXISTS auth.uid();
DROP FUNCTION IF EXISTS auth.role();
DROP FUNCTION IF EXISTS auth.jwt();
DROP FUNCTION IF EXISTS auth.handle_session_cleanup();
DROP FUNCTION IF EXISTS auth.email();
DROP FUNCTION IF EXISTS auth.cleanup_expired_sessions();
DROP TYPE IF EXISTS realtime.wal_rls;
DROP TYPE IF EXISTS realtime.wal_column;
DROP TYPE IF EXISTS realtime.user_defined_filter;
DROP TYPE IF EXISTS realtime.equality_op;
DROP TYPE IF EXISTS realtime.action;
DROP TYPE IF EXISTS public.user_company_status;
DROP TYPE IF EXISTS auth.one_time_token_type;
DROP TYPE IF EXISTS auth.factor_type;
DROP TYPE IF EXISTS auth.factor_status;
DROP TYPE IF EXISTS auth.code_challenge_method;
DROP TYPE IF EXISTS auth.aal_level;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS supabase_vault;
DROP EXTENSION IF EXISTS pgjwt;
DROP EXTENSION IF EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pg_stat_statements;
DROP EXTENSION IF EXISTS pg_graphql;
DROP SCHEMA IF EXISTS vault;
DROP SCHEMA IF EXISTS supabase_migrations;
DROP SCHEMA IF EXISTS storage;
DROP SCHEMA IF EXISTS realtime;
DROP SCHEMA IF EXISTS pgbouncer;
DROP SCHEMA IF EXISTS graphql_public;
DROP SCHEMA IF EXISTS graphql;
DROP SCHEMA IF EXISTS extensions;
DROP SCHEMA IF EXISTS backups;
DROP SCHEMA IF EXISTS auth;
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
--
--
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
--
--
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
--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	709628b5-9cd9-47b7-8d91-1a55403be076	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paul@theteam.net.au","user_id":"589e8bbe-c972-4223-8454-839eab306ca0","user_phone":""}}	2025-04-15 15:10:00.658804+00	
00000000-0000-0000-0000-000000000000	1e1ffa6d-2fd5-4143-a9fd-2f2ab73a538c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 15:10:38.32984+00	
00000000-0000-0000-0000-000000000000	6686c5da-7826-4fce-84d9-aacfe7ff031e	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-15 15:10:53.932168+00	
00000000-0000-0000-0000-000000000000	138e7bd9-2e82-4414-bf3e-8bf4959f5634	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 15:11:09.421564+00	
00000000-0000-0000-0000-000000000000	0768aa8d-9c63-4a25-81bf-113b4e544d22	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 15:14:21.435613+00	
00000000-0000-0000-0000-000000000000	2e674b34-1122-4f94-b18c-f95e2275df19	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 15:15:53.15115+00	
00000000-0000-0000-0000-000000000000	4dd8eb0a-07a0-4cf9-ad3e-91100e00e602	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 15:23:52.089648+00	
00000000-0000-0000-0000-000000000000	2fe3bb7b-c8bb-4acf-928b-08b09a9e133d	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-15 21:09:19.29473+00	
00000000-0000-0000-0000-000000000000	f88c3463-0fc9-45b6-b0cc-f6b476d42c1d	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-15 21:09:19.295624+00	
00000000-0000-0000-0000-000000000000	169ffa64-ba75-4401-bc04-beebdc25d26d	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"meryl@theteam.net.au","user_id":"c194aba1-86a5-4df9-9e3a-b38abbd928fe","user_phone":""}}	2025-04-15 21:24:11.78678+00	
00000000-0000-0000-0000-000000000000	db622d8d-bfac-46d6-93fa-49407b5f6750	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rachel@theteam.net.au","user_id":"3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f","user_phone":""}}	2025-04-15 21:24:35.738123+00	
00000000-0000-0000-0000-000000000000	abe11375-ddc6-41e8-bc6c-3f445bf53a9f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:26:56.952113+00	
00000000-0000-0000-0000-000000000000	b3e1964c-dab2-419a-bcbd-a9e3c44d4cfe	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:46:03.881367+00	
00000000-0000-0000-0000-000000000000	d264d7f2-a421-410e-8f4e-6a0e50f82465	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:46:52.347257+00	
00000000-0000-0000-0000-000000000000	02b1ab5b-e384-45ca-a1b3-18bbc3b2411c	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-15 21:47:05.854795+00	
00000000-0000-0000-0000-000000000000	7c3cd47a-383c-4605-b789-b0e03e94aacc	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:47:11.244395+00	
00000000-0000-0000-0000-000000000000	6fd438b4-9b14-46e9-962e-ad37b77440ab	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:52:43.068769+00	
00000000-0000-0000-0000-000000000000	263dbefe-940b-4996-8dfa-925be7ace785	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:53:32.10699+00	
00000000-0000-0000-0000-000000000000	bac3d71c-271b-4125-b1de-a3cc34e9fdf9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:55:08.819289+00	
00000000-0000-0000-0000-000000000000	fb1b86a9-f941-49e4-85b5-2d8a5fd974ac	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:58:14.621353+00	
00000000-0000-0000-0000-000000000000	47cb1628-c3af-487f-875c-2d10b97386a7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:58:42.952158+00	
00000000-0000-0000-0000-000000000000	8d065bae-bf95-4c8f-b567-d243a464ab27	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:01:25.354991+00	
00000000-0000-0000-0000-000000000000	4b45b29e-777f-42dd-b459-55dcd922f8f1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:07:14.562799+00	
00000000-0000-0000-0000-000000000000	a8df8fad-7487-4d5f-84f0-21e51264f2f6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:07:37.371418+00	
00000000-0000-0000-0000-000000000000	fe7e4ea3-7f27-4547-bfe1-8d52c12417b3	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:24:06.729018+00	
00000000-0000-0000-0000-000000000000	f1270200-f29d-4dff-a0d0-73b865ce8699	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-15 22:24:14.458221+00	
00000000-0000-0000-0000-000000000000	d0f79e1b-8aae-4c2c-b527-0a005e579166	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:24:15.867227+00	
00000000-0000-0000-0000-000000000000	27dc22b6-fac8-4151-a738-16316fc17e58	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:24:24.289354+00	
00000000-0000-0000-0000-000000000000	1dff3cb1-22e0-4d3d-818b-ec8322554575	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:27:03.079751+00	
00000000-0000-0000-0000-000000000000	ac3e8a6c-032a-4405-b995-f2a083b4d75e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:27:33.452294+00	
00000000-0000-0000-0000-000000000000	2aaca0ef-5ace-48bd-8145-0a1f8b1277bf	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:28:04.241707+00	
00000000-0000-0000-0000-000000000000	550a7697-a2e6-40fb-947a-a9f0951bc641	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:28:57.739517+00	
00000000-0000-0000-0000-000000000000	1fa92153-2612-4481-b182-a31ab7d46fe7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:29:02.681141+00	
00000000-0000-0000-0000-000000000000	e518dfcb-6f39-444e-99dd-ed2c23649e1a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:29:49.386106+00	
00000000-0000-0000-0000-000000000000	132103cf-6536-4828-b0a7-b94b862c10b6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:32:59.887321+00	
00000000-0000-0000-0000-000000000000	61778ef1-273d-4130-893c-78c8919b4ae4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:33:25.019501+00	
00000000-0000-0000-0000-000000000000	b1317774-7e92-418b-959a-57644c271343	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:34:34.009764+00	
00000000-0000-0000-0000-000000000000	5f9e57ee-3fce-4482-ab81-98e889fb27da	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:35:08.08701+00	
00000000-0000-0000-0000-000000000000	74e166c8-86bb-459b-8835-9e67ed41200f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:40:27.647273+00	
00000000-0000-0000-0000-000000000000	df1a91a1-7c9c-4466-8f78-5269a9f0dc35	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:41:35.177653+00	
00000000-0000-0000-0000-000000000000	cdb417a0-c9d9-4ee0-8be0-685fdd394729	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:41:40.775013+00	
00000000-0000-0000-0000-000000000000	a82b772b-2507-4206-88dd-1e3c64a0ee7f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:41:45.222822+00	
00000000-0000-0000-0000-000000000000	c4d6f1d7-e136-4c28-aa08-cd4e7dd6b581	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:41:55.6634+00	
00000000-0000-0000-0000-000000000000	e24a438a-214b-4f68-94a6-531baabd424b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:43:01.177207+00	
00000000-0000-0000-0000-000000000000	109fdc37-021a-4459-a02a-9a259954f129	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:46:30.140008+00	
00000000-0000-0000-0000-000000000000	84607b74-0896-4235-87e0-e2d5a2b96c3f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:50:28.888799+00	
00000000-0000-0000-0000-000000000000	6e77478c-3ec8-4a75-b4a7-922b9160520b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:52:52.663305+00	
00000000-0000-0000-0000-000000000000	a47b504d-f6b9-4a9a-9e1b-478eba6b2ec6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:53:15.476329+00	
00000000-0000-0000-0000-000000000000	b431605e-ff60-457a-a8fc-e96fd3ec1292	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:55:09.467027+00	
00000000-0000-0000-0000-000000000000	8685a6f4-b0b6-479c-8506-060150459633	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:56:33.654326+00	
00000000-0000-0000-0000-000000000000	375de73c-8ccc-41b2-9580-5779ccc5464e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:07:11.264347+00	
00000000-0000-0000-0000-000000000000	b598977f-17ef-4811-b5ba-09e040f11385	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:09:02.56016+00	
00000000-0000-0000-0000-000000000000	baae9321-5f36-4d67-b2ad-5bf49cc5f2f1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:10:57.305546+00	
00000000-0000-0000-0000-000000000000	6227ffb6-7d50-4e21-a32d-14a525851339	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:11:11.496761+00	
00000000-0000-0000-0000-000000000000	fa9907f3-e623-414c-94b4-6bcca7ac414d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:13:11.948435+00	
00000000-0000-0000-0000-000000000000	eda15fae-0986-4854-8e31-be7245c6adf7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:15:31.82653+00	
00000000-0000-0000-0000-000000000000	4c817298-bee0-430d-87f9-269093210e1f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:16:54.226937+00	
00000000-0000-0000-0000-000000000000	bfea4b19-f694-46ae-b2e1-bbb8978ea026	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:18:34.880986+00	
00000000-0000-0000-0000-000000000000	fc46ce53-9c7b-40e3-aa86-91ac3b5410e1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:22:06.177914+00	
00000000-0000-0000-0000-000000000000	4f1286eb-32b4-4d6a-9a0e-c7212e1e3beb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:25:06.420514+00	
00000000-0000-0000-0000-000000000000	7bf0c9fe-8e2b-4f26-a75e-28b281f0c933	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:32:22.38379+00	
00000000-0000-0000-0000-000000000000	72a10070-dc7b-422e-8fc5-702f302b6e1b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:33:50.051746+00	
00000000-0000-0000-0000-000000000000	ab30c94d-5397-4dda-b3de-b7924c315c99	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:34:02.62087+00	
00000000-0000-0000-0000-000000000000	ebb342c0-37c9-4769-9175-4185ebbc07b1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:36:18.082307+00	
00000000-0000-0000-0000-000000000000	3373a103-0f59-495e-ade6-e7bdcfddeb62	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:36:27.521233+00	
00000000-0000-0000-0000-000000000000	45274147-c18e-4dec-9aed-5dfc9350157d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:37:17.8879+00	
00000000-0000-0000-0000-000000000000	f8608b5a-80c5-4521-8051-885ea46165a4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:37:40.24158+00	
00000000-0000-0000-0000-000000000000	088b5f13-e249-4fbe-8b77-8624a773ad1e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:38:42.585309+00	
00000000-0000-0000-0000-000000000000	9c0fe6f6-6d48-4360-ab80-ffaf501d72d1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:39:27.340036+00	
00000000-0000-0000-0000-000000000000	03be155c-790a-4598-91af-81e47d4ddb50	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:39:29.023576+00	
00000000-0000-0000-0000-000000000000	9e0272d0-3e36-4e73-9398-241282ecfe18	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:39:44.843554+00	
00000000-0000-0000-0000-000000000000	cefa2694-62da-4fac-abcc-6337660e5e71	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:40:41.474537+00	
00000000-0000-0000-0000-000000000000	2a3895a3-355d-446a-a110-90dbf25f5eb2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:40:52.604843+00	
00000000-0000-0000-0000-000000000000	ed0a2086-3da4-4e9b-a22a-01f2c9711254	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:49:47.515024+00	
00000000-0000-0000-0000-000000000000	2ad18fbf-4359-45f5-b974-774f7967b256	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 23:52:04.198294+00	
00000000-0000-0000-0000-000000000000	9414e395-80f7-4c08-a7f9-c068a2839211	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 00:58:13.678019+00	
00000000-0000-0000-0000-000000000000	c1670ac7-13e3-4949-abc6-fe24d8b8b0c5	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 00:58:13.678953+00	
00000000-0000-0000-0000-000000000000	0a237a5e-d5cd-4c16-8c6a-16389ef219b5	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 09:54:59.676388+00	
00000000-0000-0000-0000-000000000000	351f7298-383b-48ca-a313-9572553da289	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 09:54:59.677329+00	
00000000-0000-0000-0000-000000000000	bbb36171-76bc-4d4d-9a6d-86c551711671	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 09:55:02.008121+00	
00000000-0000-0000-0000-000000000000	1e753c63-f8b2-49ce-a8a6-7a48c6eb124a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 09:58:47.145803+00	
00000000-0000-0000-0000-000000000000	93b5591f-60e7-4797-b3cc-79e742f616bb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:07:18.864931+00	
00000000-0000-0000-0000-000000000000	bdaa4ffd-537f-414c-9662-d3dfc3758f76	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:09:48.903523+00	
00000000-0000-0000-0000-000000000000	33959d8e-8f43-4288-b547-2278c4ea055c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:17:06.204352+00	
00000000-0000-0000-0000-000000000000	fd7a7a49-ce11-4d1a-a7ac-d78827768e7f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:24:00.971622+00	
00000000-0000-0000-0000-000000000000	eaa1e2fd-4ddf-4062-b13d-36b9c076ed71	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:26:15.267481+00	
00000000-0000-0000-0000-000000000000	182bde8b-2f80-48d4-8c38-dd150fdb1112	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:26:35.151735+00	
00000000-0000-0000-0000-000000000000	774d96c6-24f0-48d5-a6fb-9cc40c1d6b54	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:26:44.104631+00	
00000000-0000-0000-0000-000000000000	c1c8b46f-bd56-4707-830f-088be8c790a8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:31:12.91308+00	
00000000-0000-0000-0000-000000000000	13283fce-5b02-41a2-a387-fd0543348ca1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:32:33.739073+00	
00000000-0000-0000-0000-000000000000	25d08973-46e3-4019-9726-4cc1b557652f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:40:24.68072+00	
00000000-0000-0000-0000-000000000000	56042bfc-2783-40b2-8216-1d4084bb111a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:42:55.154963+00	
00000000-0000-0000-0000-000000000000	6a3cc6d4-d4c6-42bc-a296-96c65f5a5502	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:44:00.937054+00	
00000000-0000-0000-0000-000000000000	12feffe3-70b8-4876-8e49-6eef84bd7230	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:46:20.214515+00	
00000000-0000-0000-0000-000000000000	eeee707e-3090-4c9e-83e4-0b71efb6cc15	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:48:11.994858+00	
00000000-0000-0000-0000-000000000000	6fd7937f-2554-481d-ac3c-65044dd40382	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:50:12.268083+00	
00000000-0000-0000-0000-000000000000	8f1df3ec-cff3-4092-8da4-7740cce7b46a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:52:31.385299+00	
00000000-0000-0000-0000-000000000000	a92f07b0-a186-4b3f-bb2b-a2fe4ff09e5c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:53:09.655691+00	
00000000-0000-0000-0000-000000000000	7104de2e-3b44-4161-83e5-62a280c78e8c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:55:51.642877+00	
00000000-0000-0000-0000-000000000000	8e9f6672-2735-4d1f-ab74-ac44f933ff12	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 10:58:55.014577+00	
00000000-0000-0000-0000-000000000000	4efb4bdb-22e0-4bae-907d-a6167bb7ffc1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:01:39.740731+00	
00000000-0000-0000-0000-000000000000	aa00084a-b05d-4f14-90bb-8d019d273f93	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:05:10.415921+00	
00000000-0000-0000-0000-000000000000	49133f2b-7626-405f-88e8-0de834512f84	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:13:06.068202+00	
00000000-0000-0000-0000-000000000000	e274e176-f475-496f-b173-09dded857bd2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:14:08.279574+00	
00000000-0000-0000-0000-000000000000	b14bfaaf-fc13-4328-a249-197fa4fdd258	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:17:08.886093+00	
00000000-0000-0000-0000-000000000000	26bbb8e2-ca7b-49cd-ac32-6686b43f1a11	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:20:50.460704+00	
00000000-0000-0000-0000-000000000000	2567872a-1e90-4761-95ac-7d6e40365876	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:22:25.502106+00	
00000000-0000-0000-0000-000000000000	12a743c1-6111-4289-9267-3b1d13d63237	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:23:12.913984+00	
00000000-0000-0000-0000-000000000000	cd3670f4-7620-40ce-b0bd-77d8ef0ff694	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:28:15.86412+00	
00000000-0000-0000-0000-000000000000	b2f58f9f-5a34-49e9-9b90-1962359e1e69	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:55:38.537867+00	
00000000-0000-0000-0000-000000000000	05b04b46-440f-41cb-ba45-58d183eafae7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 11:57:55.523244+00	
00000000-0000-0000-0000-000000000000	d5252d1d-9561-4832-ae8b-c84683d7b9e8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:00:24.350138+00	
00000000-0000-0000-0000-000000000000	b94d9e09-3c88-45e6-8e5e-5242da20af19	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:03:42.603522+00	
00000000-0000-0000-0000-000000000000	d4eda829-92b7-4092-90cb-10926a5985b2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:06:42.308961+00	
00000000-0000-0000-0000-000000000000	4b23a1a5-7247-4deb-85ba-437ac16d35ec	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:07:10.857149+00	
00000000-0000-0000-0000-000000000000	ed27abcb-87b2-4d51-8ea3-f754f54e372d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:09:12.441097+00	
00000000-0000-0000-0000-000000000000	fa4f830a-e05c-4eb0-9ca1-def165fe0f87	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:11:54.497951+00	
00000000-0000-0000-0000-000000000000	35c27de2-c838-4bf7-99ba-7ce4f676f22f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 12:17:28.17413+00	
00000000-0000-0000-0000-000000000000	cfe8f761-9e64-4b51-ad1e-871b2bbad704	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 20:22:24.105595+00	
00000000-0000-0000-0000-000000000000	6f7fbd72-88b8-413f-91ed-1ba139f09b9f	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 20:22:24.106577+00	
00000000-0000-0000-0000-000000000000	587d9e8c-70e9-4f68-ba05-8b61127de4c0	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 22:02:23.293203+00	
00000000-0000-0000-0000-000000000000	a41d5879-8a56-4396-ac4f-4ccabe569116	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 22:02:23.294191+00	
00000000-0000-0000-0000-000000000000	74157c2b-4ba2-411e-8c05-511604114db6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:06:47.504549+00	
00000000-0000-0000-0000-000000000000	a6fc11fc-ce93-488b-b736-27626ad9febe	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 22:27:40.636269+00	
00000000-0000-0000-0000-000000000000	f883f096-5f02-4911-891a-1c1a698f7894	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-16 22:27:40.637382+00	
00000000-0000-0000-0000-000000000000	136c6668-f914-4f4a-bac5-a298019a99db	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:27:55.785983+00	
00000000-0000-0000-0000-000000000000	ff99abd3-5b39-40e5-a9f1-f7a29aaf29db	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:32:43.451236+00	
00000000-0000-0000-0000-000000000000	182d9339-9e2a-40c8-96c7-77aca3c5db32	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:40:08.643911+00	
00000000-0000-0000-0000-000000000000	d1f6c389-83fd-4a69-8a0e-1463a28e93a8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:41:54.629072+00	
00000000-0000-0000-0000-000000000000	f5322d96-7995-430e-9c8f-45b3f11a744d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:42:51.66971+00	
00000000-0000-0000-0000-000000000000	23903935-60a5-489a-82ea-547230329b01	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:44:45.06202+00	
00000000-0000-0000-0000-000000000000	2309e856-d555-4f56-b856-cd2bf15970a2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:52:30.839999+00	
00000000-0000-0000-0000-000000000000	5a8b5711-a7c4-499b-b00a-80f591dfe379	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:54:06.873234+00	
00000000-0000-0000-0000-000000000000	fecee734-61c6-4be6-b269-8b763c4140e5	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 22:55:28.372154+00	
00000000-0000-0000-0000-000000000000	f4d2c30f-85b8-4bba-a046-725de66cf37d	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:01:53.2789+00	
00000000-0000-0000-0000-000000000000	b40dc218-4e26-4c5e-a13f-55105434be9f	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:01:53.280638+00	
00000000-0000-0000-0000-000000000000	aad678e8-b6c4-406b-9aec-f74ee41bda05	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:01:55.157501+00	
00000000-0000-0000-0000-000000000000	711a5e93-20ef-47b1-92cf-dc8beb80099d	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:02:12.362783+00	
00000000-0000-0000-0000-000000000000	1b59a5af-7616-4677-8eae-aae3f6d0e069	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:02:12.363521+00	
00000000-0000-0000-0000-000000000000	6ee7ddac-e96a-482b-bbd8-352a7044d09e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:02:13.370666+00	
00000000-0000-0000-0000-000000000000	92821a92-466f-4578-8564-5c9b0915388b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:06:35.968575+00	
00000000-0000-0000-0000-000000000000	e046f0be-ee18-40cf-b378-ce9b7618d696	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:11:19.025353+00	
00000000-0000-0000-0000-000000000000	c1bb07fa-59a2-4185-a92c-f106174489e2	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 08:11:19.026275+00	
00000000-0000-0000-0000-000000000000	bb1be773-f088-416f-b1c3-980382ddb848	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:11:21.042934+00	
00000000-0000-0000-0000-000000000000	4b405d16-c62f-45c8-8127-a862dd9d9a7f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:12:03.747664+00	
00000000-0000-0000-0000-000000000000	cc9376cc-e005-475f-af93-241b6a8fad85	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:12:43.863727+00	
00000000-0000-0000-0000-000000000000	af371aae-6c45-4503-9099-64a012ab20c9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 08:21:10.958774+00	
00000000-0000-0000-0000-000000000000	df9bccf7-b1c6-4be4-a74b-b45212ed2ffe	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 10:47:53.094303+00	
00000000-0000-0000-0000-000000000000	3c2afb10-c547-48f5-97c9-8bc71aafa8b0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 10:50:02.111994+00	
00000000-0000-0000-0000-000000000000	bd535ce5-de1d-41ba-bb73-e1d1350f5463	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 10:56:57.432189+00	
00000000-0000-0000-0000-000000000000	4a35d9e1-0763-4a37-9c83-0fd2033598d1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:04:32.026926+00	
00000000-0000-0000-0000-000000000000	a7d461a5-d58d-4bc5-ad0b-0bb6b325191f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:11:51.13392+00	
00000000-0000-0000-0000-000000000000	30e370b3-dad5-447f-8e6e-52580e00a8fa	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:18:41.451753+00	
00000000-0000-0000-0000-000000000000	70d50ea3-e3cf-4164-a632-5b540e1bf30a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:19:33.631307+00	
00000000-0000-0000-0000-000000000000	811c03ed-1069-4816-a9a2-9677fbf07a44	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:21:51.057034+00	
00000000-0000-0000-0000-000000000000	4a35b56d-9377-4a86-9e0e-11ed41253f8b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:22:26.887292+00	
00000000-0000-0000-0000-000000000000	fc9f43e1-8151-4466-961a-88dafc734c6f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:24:31.637234+00	
00000000-0000-0000-0000-000000000000	879e29c6-eb67-49a9-85fb-a404dc99e50e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:25:46.853178+00	
00000000-0000-0000-0000-000000000000	f6643cef-14c8-4151-98ad-a2703570614b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:28:14.582974+00	
00000000-0000-0000-0000-000000000000	92bd3c76-db1a-4dfb-ad58-87e77755800d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:35:37.488287+00	
00000000-0000-0000-0000-000000000000	ac564aff-0846-401c-8e62-603c63079847	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:35:39.149505+00	
00000000-0000-0000-0000-000000000000	9a7feb93-01a6-48c7-a74f-0688389fcff2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:42:14.710223+00	
00000000-0000-0000-0000-000000000000	a3c0c6ba-6b04-4fb5-986c-961755407c46	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:44:05.534035+00	
00000000-0000-0000-0000-000000000000	b80c50f8-7a12-4d51-b0db-292ffe07f0dc	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:50:45.195057+00	
00000000-0000-0000-0000-000000000000	20c23fa0-d1dc-455f-9913-28d5e7348424	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:52:25.719287+00	
00000000-0000-0000-0000-000000000000	f7da557b-5d9b-44ed-94af-382c3f218214	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:53:49.862641+00	
00000000-0000-0000-0000-000000000000	bb18acdd-07ae-4095-9270-60e19101d337	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 11:58:02.531831+00	
00000000-0000-0000-0000-000000000000	df3d83e1-d191-43f7-a184-af85fe5c5cd2	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 12:00:22.04701+00	
00000000-0000-0000-0000-000000000000	bba288bb-242c-4a49-8380-9946591a7599	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-17 12:00:22.047974+00	
00000000-0000-0000-0000-000000000000	185d74c7-cd64-4b8d-9c33-0558a05a6641	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:00:38.999846+00	
00000000-0000-0000-0000-000000000000	51fdd9a8-8652-4460-8968-df78e6ad08f7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:03:10.830276+00	
00000000-0000-0000-0000-000000000000	4dd2babc-5e3d-45f1-a48a-ce220a84b645	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:05:01.589702+00	
00000000-0000-0000-0000-000000000000	b5919a79-94d1-4295-92d9-1fcbe370bb6a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:06:41.022057+00	
00000000-0000-0000-0000-000000000000	ca1b82ea-2a58-4009-9a43-29d2790ce78c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:06:58.483671+00	
00000000-0000-0000-0000-000000000000	409e422f-53a3-4664-9347-2151882d2d7e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:11:18.36855+00	
00000000-0000-0000-0000-000000000000	da1c4d54-d416-4fbb-9d9e-cb56679771c4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:12:21.605736+00	
00000000-0000-0000-0000-000000000000	13b1bd54-a0de-40ca-a5be-42e8e2977ca7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:16:12.895651+00	
00000000-0000-0000-0000-000000000000	4fee24fc-b7e4-48be-8f58-11717c4b734e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:33:01.401225+00	
00000000-0000-0000-0000-000000000000	3d0b667c-d35b-48ac-b438-144c77e92d83	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:33:14.670874+00	
00000000-0000-0000-0000-000000000000	684a6d73-e80d-4a63-8765-4b1ab852660e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 12:59:54.217427+00	
00000000-0000-0000-0000-000000000000	c044d831-dcb5-4848-aa02-7681ca9681b8	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 13:00:09.597279+00	
00000000-0000-0000-0000-000000000000	ba8e0f82-a16a-46d2-83e1-bd77ae968e29	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paul+super_admin@theteam.net.au","user_id":"9dcfbee0-4f72-472d-8c9b-d4bd2de90abe","user_phone":""}}	2025-04-17 13:01:22.951811+00	
00000000-0000-0000-0000-000000000000	4d9e76c4-b233-419c-9804-25fb7f0acf47	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:12:24.51728+00	
00000000-0000-0000-0000-000000000000	1b1715e2-19f6-4cc9-b881-207de3ca2dce	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:28:00.26837+00	
00000000-0000-0000-0000-000000000000	44fec7f9-e78d-40e4-a1eb-4f2c8f3e89ca	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:28:11.588943+00	
00000000-0000-0000-0000-000000000000	114d1144-cc2a-4d72-893a-9be48f9f8516	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:33:29.808155+00	
00000000-0000-0000-0000-000000000000	98230c59-9d0c-4281-a3e5-b4f1de1e98a0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:39:33.08781+00	
00000000-0000-0000-0000-000000000000	dbae15fd-f018-4cd1-9cd7-2e3b9809434b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:42:08.136192+00	
00000000-0000-0000-0000-000000000000	0962a3d5-04f8-4452-b403-5bb85ad01ac6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:42:36.716647+00	
00000000-0000-0000-0000-000000000000	b5dc7ded-6c56-4070-9b9f-b47a321ff9b0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:47:32.089986+00	
00000000-0000-0000-0000-000000000000	5eedeef1-7cc1-4c0d-b479-3f26bcc45c84	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:48:07.188234+00	
00000000-0000-0000-0000-000000000000	96434241-4b43-4f10-8f61-42dad6aff592	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:49:02.508062+00	
00000000-0000-0000-0000-000000000000	1fdf13c8-3536-49db-85d8-6a4f22b772e0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:50:32.957176+00	
00000000-0000-0000-0000-000000000000	dc3fce46-ccfe-4e97-9722-a6b4f07c6cce	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:51:30.837026+00	
00000000-0000-0000-0000-000000000000	834869e9-d660-40ea-99ed-bdae4e61950b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:51:53.592411+00	
00000000-0000-0000-0000-000000000000	339730af-8b6f-49af-a66f-3405edb018fa	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:54:53.282678+00	
00000000-0000-0000-0000-000000000000	45df57d7-ca13-407e-aec1-834f28c65e0d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:57:33.49568+00	
00000000-0000-0000-0000-000000000000	3080b2a2-7840-437d-ade7-96d5237e3005	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 18:59:01.63098+00	
00000000-0000-0000-0000-000000000000	00fa64aa-2c87-4e89-b615-ce624479532f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:00:13.516907+00	
00000000-0000-0000-0000-000000000000	34d87be5-d9af-4a23-b943-e4de29ba546f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:01:01.277428+00	
00000000-0000-0000-0000-000000000000	c66612b9-3a43-4dc2-8568-618669755e88	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:01:53.519868+00	
00000000-0000-0000-0000-000000000000	192eb0e7-be98-428a-989f-80d24c29f7bc	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:03:56.730103+00	
00000000-0000-0000-0000-000000000000	29891421-c224-4840-9fb9-a366305cc7d1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:06:34.628039+00	
00000000-0000-0000-0000-000000000000	0196fff4-e5ba-4686-b242-418ad0e4b9ec	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:07:12.371563+00	
00000000-0000-0000-0000-000000000000	a56b447e-7b59-41aa-8b84-9d6b06ff1fa6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:08:59.170695+00	
00000000-0000-0000-0000-000000000000	23365ac9-75b6-406c-90a5-7c431e20b3c2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:09:52.979432+00	
00000000-0000-0000-0000-000000000000	ee26b7d4-66c0-4810-b28c-5fc35faa4f9e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:11:44.831101+00	
00000000-0000-0000-0000-000000000000	bd57014a-39e7-43c6-b529-aa38381e584d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:12:56.367968+00	
00000000-0000-0000-0000-000000000000	62e12306-3dcf-4f31-b951-e5b78691a76c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:16:43.489318+00	
00000000-0000-0000-0000-000000000000	8e7de857-006e-4a68-84ba-531dd69f3ebe	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:17:03.157057+00	
00000000-0000-0000-0000-000000000000	77bfea0a-1d9d-4c83-9579-9969182f8064	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:22:57.558017+00	
00000000-0000-0000-0000-000000000000	246371bd-57aa-4aac-bfff-e6edc474f210	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:23:42.374939+00	
00000000-0000-0000-0000-000000000000	35e97b25-2a15-4c94-a85d-dfb41770b5f0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:31:32.37575+00	
00000000-0000-0000-0000-000000000000	a26d4515-e528-41c5-909e-3d16b8055639	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:33:03.512551+00	
00000000-0000-0000-0000-000000000000	45615eb2-0705-42d3-b4fa-25242ec4eaa6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:40:12.044183+00	
00000000-0000-0000-0000-000000000000	0bbc8242-b34b-43a8-a1ee-5748cd7be75f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:43:02.262816+00	
00000000-0000-0000-0000-000000000000	7dfcaff8-6c45-45c7-9dfe-c9839de35e8f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:43:13.715208+00	
00000000-0000-0000-0000-000000000000	3e3ac829-9821-4f72-aa34-c5bbc5adf690	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:45:06.476606+00	
00000000-0000-0000-0000-000000000000	07cfcc9e-d60d-4986-9168-2daff0904fa3	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 19:47:40.952076+00	
00000000-0000-0000-0000-000000000000	6e653bca-a678-47bf-b8c0-614bc6d54471	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:02:09.148624+00	
00000000-0000-0000-0000-000000000000	ac533066-47c1-4572-95c5-589cf7fc7fe9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:05:56.129767+00	
00000000-0000-0000-0000-000000000000	00285eea-d682-42e7-a643-336c356400b8	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 20:06:29.012775+00	
00000000-0000-0000-0000-000000000000	75e9cf49-f22f-4d57-a1ad-e0d7f689deac	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:06:36.168639+00	
00000000-0000-0000-0000-000000000000	38bb8d1d-5a1c-4bef-92a2-33f5ab05a8d9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:06:48.753392+00	
00000000-0000-0000-0000-000000000000	5ae0514d-f1eb-4d5b-bbcf-484e7d40f0c7	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 20:09:38.023412+00	
00000000-0000-0000-0000-000000000000	145854a1-052b-460c-b7b5-3758815dbbea	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:16:14.390518+00	
00000000-0000-0000-0000-000000000000	7fcda3c7-fc64-460a-ba99-1f92a5394aa5	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:16:54.617483+00	
00000000-0000-0000-0000-000000000000	c95edba7-d602-42ce-a4f1-10ba402ce268	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:17:38.283541+00	
00000000-0000-0000-0000-000000000000	8001d274-b3fe-4a9a-a39a-d97e72cc5037	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:19:28.755543+00	
00000000-0000-0000-0000-000000000000	f47636cc-9dd1-4847-a91e-89995fedee4a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:21:27.313033+00	
00000000-0000-0000-0000-000000000000	85e52da5-3a17-4ed8-823d-ac9bf2bf825a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:24:35.945803+00	
00000000-0000-0000-0000-000000000000	277fbcef-c521-4763-b9c8-7a7605e839c7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:49:56.854193+00	
00000000-0000-0000-0000-000000000000	cd746919-ce19-4244-bc4c-e4e02b915de8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:53:05.839217+00	
00000000-0000-0000-0000-000000000000	ba628228-461e-47bb-94aa-547ff4f4de92	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:56:53.618618+00	
00000000-0000-0000-0000-000000000000	87eaaf9d-8a54-4460-be63-efedb84bb4c9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 20:59:32.398224+00	
00000000-0000-0000-0000-000000000000	c65d7dcd-2205-4a4c-9f08-4a60d7543e25	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:01:01.897445+00	
00000000-0000-0000-0000-000000000000	5a941d3e-a5d6-44ad-8bec-3beed271067c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:04:14.551982+00	
00000000-0000-0000-0000-000000000000	2c38e697-e505-43e2-be17-2ab2e28c29f4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:04:22.315262+00	
00000000-0000-0000-0000-000000000000	2912b6ee-b361-4df1-b270-4e9a12f64009	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:05:16.473394+00	
00000000-0000-0000-0000-000000000000	95a66e21-4067-4217-84ae-339b33da08b6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:06:29.935854+00	
00000000-0000-0000-0000-000000000000	70b8e497-ca00-43ce-a172-fab307e287cd	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:06:45.751182+00	
00000000-0000-0000-0000-000000000000	f4ccdea0-dd72-49a0-ab53-17290b7cce63	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:06:58.69872+00	
00000000-0000-0000-0000-000000000000	13218297-213a-48eb-8009-25921ba987cd	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:07:58.813246+00	
00000000-0000-0000-0000-000000000000	8fc45790-1572-48e9-bcf0-d4ad647b4eef	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:08:28.606286+00	
00000000-0000-0000-0000-000000000000	bebed9b1-4bc9-44dd-b404-a8baa33db267	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:12:00.303986+00	
00000000-0000-0000-0000-000000000000	3b329013-50f6-4285-88ef-6d1b23e8dc53	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:20:15.637979+00	
00000000-0000-0000-0000-000000000000	d1598271-cd4f-4d47-880d-50d707d3b1eb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:20:33.720221+00	
00000000-0000-0000-0000-000000000000	21efea59-f35a-4930-b30c-50cda334ca1e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:20:54.807718+00	
00000000-0000-0000-0000-000000000000	086b797c-bb0d-4ed5-94b2-4292852d4b18	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:26:04.480169+00	
00000000-0000-0000-0000-000000000000	2ee8ceae-645f-4f83-bef5-f7867dee977c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:28:12.715887+00	
00000000-0000-0000-0000-000000000000	1934818f-a179-4a82-9ac4-c533466cf458	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:28:58.914673+00	
00000000-0000-0000-0000-000000000000	6e5c511a-e79e-44be-843f-1af7e1faf779	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:31:27.75617+00	
00000000-0000-0000-0000-000000000000	e8e32004-5010-435d-b04e-e1779ec32fda	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:35:15.664679+00	
00000000-0000-0000-0000-000000000000	ec164142-635a-48d3-9357-a3a9c07199b9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:38:36.182279+00	
00000000-0000-0000-0000-000000000000	ec788edc-5183-4c47-b064-aa47cdeafa6b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:40:11.891566+00	
00000000-0000-0000-0000-000000000000	9326c6b7-e8ba-407d-90ff-900221ac0277	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:41:14.949717+00	
00000000-0000-0000-0000-000000000000	88a0039f-1dfa-4b12-8671-dd76f9f79f25	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:42:16.089453+00	
00000000-0000-0000-0000-000000000000	034fe5d9-b704-4b6d-b181-6c2fdb10351d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 21:46:33.524731+00	
00000000-0000-0000-0000-000000000000	9c400d9d-c658-4ed0-9fc1-c7f42d5de79e	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:00:51.952026+00	
00000000-0000-0000-0000-000000000000	88b08789-b8af-4a4a-87e1-0d3baf59a271	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:00:55.328094+00	
00000000-0000-0000-0000-000000000000	d146dafc-1c46-461a-938a-f5987b7917bd	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:02:05.566832+00	
00000000-0000-0000-0000-000000000000	f692b620-4147-4697-8f66-22875ebc1ecd	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:02:08.254213+00	
00000000-0000-0000-0000-000000000000	9351d677-f019-4025-a1db-39d7f368efb5	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:02:13.300539+00	
00000000-0000-0000-0000-000000000000	a31f4370-e0fa-4c2e-8132-2e5ed88e1c41	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:03:02.018507+00	
00000000-0000-0000-0000-000000000000	1d5b88cb-7dfc-46f1-9aae-933e77e4ef3f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:03:36.450235+00	
00000000-0000-0000-0000-000000000000	e523e72a-b483-4cb9-aee2-41826417f389	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:04:02.629787+00	
00000000-0000-0000-0000-000000000000	b76dc484-9d55-4280-a0b5-904cdcc723ab	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:05:14.968306+00	
00000000-0000-0000-0000-000000000000	47f9f988-c233-4618-8ef7-2dec7741b8ae	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:06:50.706494+00	
00000000-0000-0000-0000-000000000000	32c27a54-bd13-47a4-84cd-99dffcaa355b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:07:15.937086+00	
00000000-0000-0000-0000-000000000000	32564281-7cdf-4828-82fe-6657fd4e8910	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:07:42.819279+00	
00000000-0000-0000-0000-000000000000	80873669-2387-460b-92f5-e9f22e362cd6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:08:37.576142+00	
00000000-0000-0000-0000-000000000000	3ff4f7b4-1aff-4136-9d4f-d0c73799280e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:10:17.926329+00	
00000000-0000-0000-0000-000000000000	1cfe7624-2c41-4ebd-8fdb-ae29d2a45d36	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:11:07.032744+00	
00000000-0000-0000-0000-000000000000	d0f08d65-d4ea-4b6c-8cc3-1c5630372718	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:13:03.534385+00	
00000000-0000-0000-0000-000000000000	fca31176-e9d3-4401-a1a4-c12438d4e98d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:20:05.61429+00	
00000000-0000-0000-0000-000000000000	f507fc22-f014-40b4-941c-9cbf2bfc4ef6	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:21:03.323184+00	
00000000-0000-0000-0000-000000000000	5a91de3b-5512-41d3-8bad-100243addf89	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:21:43.752042+00	
00000000-0000-0000-0000-000000000000	58c1941a-9fc6-45cf-8f13-4d0459e92f07	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:24:41.849582+00	
00000000-0000-0000-0000-000000000000	d390eb56-6909-4740-8453-9f986a719366	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:24:56.479537+00	
00000000-0000-0000-0000-000000000000	40f67224-86e1-454e-aa52-a7e736ff9d3d	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:29:27.76508+00	
00000000-0000-0000-0000-000000000000	0072eb0a-f6ff-4d74-b9b2-6d252c3d60a6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:32:21.92835+00	
00000000-0000-0000-0000-000000000000	bb097e38-0af1-4776-9a46-9904cf225ab1	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:32:25.670752+00	
00000000-0000-0000-0000-000000000000	c87f94c5-34ac-44aa-8b61-9f38a4dc0e5a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:32:30.751729+00	
00000000-0000-0000-0000-000000000000	67dc3f39-8659-43fe-8184-e85456c2ede8	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:32:34.25698+00	
00000000-0000-0000-0000-000000000000	1f82ee7f-c2c0-4dd5-9e59-a6faa9717387	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:32:56.209492+00	
00000000-0000-0000-0000-000000000000	2f3b748a-2cde-4209-b267-2d7e0831040b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:33:28.971712+00	
00000000-0000-0000-0000-000000000000	4fcf2899-09e0-4784-9b51-3e726cbc072a	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:33:32.046666+00	
00000000-0000-0000-0000-000000000000	35421d36-019b-4c0f-aa3d-b6760e53b57f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:33:35.807075+00	
00000000-0000-0000-0000-000000000000	b6537058-590e-43ae-a5fa-0ef47052b6d5	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:45:47.878376+00	
00000000-0000-0000-0000-000000000000	b9c987ca-0e62-463b-87fa-233a864cbb45	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:45:53.75472+00	
00000000-0000-0000-0000-000000000000	72da6f4f-f36d-4d02-86d8-968531829000	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:49:15.819684+00	
00000000-0000-0000-0000-000000000000	35beeb0f-52a3-461d-9b3d-ce98d1d2b1ea	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 22:52:57.530001+00	
00000000-0000-0000-0000-000000000000	c23c9429-7e13-44e4-87ca-b9721001784f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:53:01.911899+00	
00000000-0000-0000-0000-000000000000	de519772-4732-4161-9b09-1140b8dd811d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:56:26.94052+00	
00000000-0000-0000-0000-000000000000	29319232-7b13-4ad6-addd-f3dcef901f2d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 22:59:23.349343+00	
00000000-0000-0000-0000-000000000000	eaf060d1-0f0e-4f7a-be7d-8553bc3aec2a	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 23:04:05.808464+00	
00000000-0000-0000-0000-000000000000	9552b1ec-61d7-4811-a375-d5a8462d183a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:05:44.603717+00	
00000000-0000-0000-0000-000000000000	cb167eac-c260-43c6-b920-0a4514150b04	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-17 23:05:48.661774+00	
00000000-0000-0000-0000-000000000000	c27207ca-b828-49ca-9afb-b6c0e5200c3b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:07:35.693195+00	
00000000-0000-0000-0000-000000000000	0fcb2925-a341-42c9-a770-d57099a76343	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:08:15.639842+00	
00000000-0000-0000-0000-000000000000	f5a391f8-c297-4092-bb89-2da65c3d5220	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:09:15.524469+00	
00000000-0000-0000-0000-000000000000	2e78a345-3bf5-4e78-be4d-61b3ea234ef1	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:13:11.97346+00	
00000000-0000-0000-0000-000000000000	192ea3a8-7575-44a9-8d61-d08fbd9f1e67	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:13:40.565079+00	
00000000-0000-0000-0000-000000000000	687f8321-dd89-48df-852c-e57e0b674602	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:13:45.671335+00	
00000000-0000-0000-0000-000000000000	12078129-01a0-4601-9949-dacbfa68597a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:14:20.558261+00	
00000000-0000-0000-0000-000000000000	762d1197-4c1b-40f2-b230-c769ecae332d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:14:34.220967+00	
00000000-0000-0000-0000-000000000000	8d15be95-11aa-49ba-a2f5-2e30579e199e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:16:03.785314+00	
00000000-0000-0000-0000-000000000000	765fbe9b-d3e2-452b-8f3e-f4c076f624e9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:16:06.367856+00	
00000000-0000-0000-0000-000000000000	fcefc3e3-ed64-4314-ae65-404a7e750726	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:16:08.553194+00	
00000000-0000-0000-0000-000000000000	0367b2b5-8baa-4276-8afe-958cc270f99d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:16:16.725685+00	
00000000-0000-0000-0000-000000000000	9036437c-b8cd-490f-b00b-86224e548e67	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:18:05.155189+00	
00000000-0000-0000-0000-000000000000	408111e6-3238-4836-a35c-aa9694ad8ea2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:20:07.051659+00	
00000000-0000-0000-0000-000000000000	6b3f0187-1d23-4d38-ac09-fcc7403594eb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:20:40.432333+00	
00000000-0000-0000-0000-000000000000	5d17d8f8-4112-42ef-9089-924f73916d9a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:21:11.627425+00	
00000000-0000-0000-0000-000000000000	216252a8-c8f6-47e7-a1f6-d76966a1378a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:21:13.345751+00	
00000000-0000-0000-0000-000000000000	29f84cf9-8f34-480a-a7e7-88bec5fe1f61	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:21:16.302432+00	
00000000-0000-0000-0000-000000000000	d0e48f21-3898-4f27-9da0-7ea980d4e629	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:23:16.439862+00	
00000000-0000-0000-0000-000000000000	f6e2c314-d64a-436f-964f-f12dadeac8e4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:31:05.442221+00	
00000000-0000-0000-0000-000000000000	318f445e-6480-4bc6-91e1-fa4f0e57c78f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:31:24.654356+00	
00000000-0000-0000-0000-000000000000	627e4693-8e9d-4d5d-ae3b-7d86bcfee251	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:31:41.19377+00	
00000000-0000-0000-0000-000000000000	effc880e-232a-4ae7-a08a-ff58b3647a79	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:34:45.587433+00	
00000000-0000-0000-0000-000000000000	0423db8d-8d9d-4c2c-948e-82ffc75fa6a6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:34:56.343863+00	
00000000-0000-0000-0000-000000000000	a4002ce5-94d3-485f-825f-c3c16db2556d	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:36:57.062732+00	
00000000-0000-0000-0000-000000000000	09cf314f-006e-4f05-afd1-63a114b5fe7b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:45:07.844975+00	
00000000-0000-0000-0000-000000000000	1ddd099b-f8b0-4101-a48d-18ae2ed7b7bc	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:45:19.716443+00	
00000000-0000-0000-0000-000000000000	38909270-f96e-4b13-88f8-9fc64f614088	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-17 23:48:45.772306+00	
00000000-0000-0000-0000-000000000000	b8e87994-c938-4100-9fd2-f0f6c4d964f6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:07:31.451509+00	
00000000-0000-0000-0000-000000000000	d04effca-3f3c-4a79-8ba3-fc70434c65e8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:07:43.474468+00	
00000000-0000-0000-0000-000000000000	3c067c63-19dc-41b4-a9da-ec1c4f7602a7	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:08:27.427394+00	
00000000-0000-0000-0000-000000000000	91410af9-a3d4-48bb-a07b-b23bf5a680b9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:10:06.77785+00	
00000000-0000-0000-0000-000000000000	eb918bea-024d-443e-bec4-bbc74d072f7e	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 00:12:32.397123+00	
00000000-0000-0000-0000-000000000000	50f935ee-df21-497d-875b-73eb26114e2e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:12:36.101597+00	
00000000-0000-0000-0000-000000000000	b00ddb32-f946-4a56-8ca8-1e03963090da	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:12:56.208986+00	
00000000-0000-0000-0000-000000000000	c4881c61-ced2-4bb1-a4ae-e61ba3ab6f08	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:13:31.395873+00	
00000000-0000-0000-0000-000000000000	84cfedfd-5980-4a9e-b070-36874e6d78b6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:13:40.267649+00	
00000000-0000-0000-0000-000000000000	6cf6b085-4aba-4104-83c3-0be2070af118	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 00:14:02.127617+00	
00000000-0000-0000-0000-000000000000	3f99f80f-ae98-4bae-b669-14b2c422b944	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:14:05.979592+00	
00000000-0000-0000-0000-000000000000	31fe374d-f50e-42cb-b5e8-27d41adc361f	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 00:14:25.118397+00	
00000000-0000-0000-0000-000000000000	ed996234-18a2-4a9e-9038-63372c927192	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:14:30.220687+00	
00000000-0000-0000-0000-000000000000	1bfdd738-718a-4bdc-b6cb-033dfd91cf6b	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:15:21.978375+00	
00000000-0000-0000-0000-000000000000	6372a13e-0690-4b8c-a08f-e2d7b73ef6d0	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:18:02.579054+00	
00000000-0000-0000-0000-000000000000	4739c23c-510a-472f-8abc-af7d97b3cd03	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:18:10.192875+00	
00000000-0000-0000-0000-000000000000	4acbf72c-4a45-4b92-b9ae-a8208c619c5e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:18:22.434683+00	
00000000-0000-0000-0000-000000000000	9627870e-9995-4dc3-89e3-2cfefaa2e43c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:18:27.416859+00	
00000000-0000-0000-0000-000000000000	44670b6c-ff2b-4973-8b03-656d07100869	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:19:41.374744+00	
00000000-0000-0000-0000-000000000000	3a10c9b3-ff10-4afa-a33c-7e6dcfc2597a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:20:56.467405+00	
00000000-0000-0000-0000-000000000000	925f6065-0c75-4bce-ac91-30da27fb70bf	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:22:40.502245+00	
00000000-0000-0000-0000-000000000000	dcaaed84-47e3-490a-8ccb-9d69f4a49a95	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:22:52.624438+00	
00000000-0000-0000-0000-000000000000	f59905a2-96e2-4650-99b9-962240aa352e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:23:49.824107+00	
00000000-0000-0000-0000-000000000000	51d6f284-27d4-4eaa-871d-d834d5902de8	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 00:23:52.371179+00	
00000000-0000-0000-0000-000000000000	79cd7ed3-4e86-440b-a1c8-d8ffd27bd320	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:28:34.329317+00	
00000000-0000-0000-0000-000000000000	5d8a6dcd-b894-44e9-b3a3-32a6f32fe571	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:28:42.405292+00	
00000000-0000-0000-0000-000000000000	34ce1b53-6fcd-4be4-80c6-add08b750b20	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 00:28:57.696858+00	
00000000-0000-0000-0000-000000000000	2f48c796-7eb8-418d-a1ae-6de6995288d6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:49:09.093812+00	
00000000-0000-0000-0000-000000000000	a3ae5d7f-05ac-48b4-96f0-d0c0bdbd54e6	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:49:20.913048+00	
00000000-0000-0000-0000-000000000000	1c7d69d4-c957-47e2-b6e5-77f92fcdee13	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 00:52:30.919407+00	
00000000-0000-0000-0000-000000000000	1503a525-88dc-4ef2-8c1e-bc21fa7fc898	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:06:10.230032+00	
00000000-0000-0000-0000-000000000000	2118b627-b482-4be0-abcc-2ba84ef329e6	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 01:23:53.787196+00	
00000000-0000-0000-0000-000000000000	4573ebdf-a9c2-4527-be64-cc31da10bc5e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:23:57.896972+00	
00000000-0000-0000-0000-000000000000	e078b343-b4fa-4129-82ee-cdd7b1da0c69	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:28:38.34189+00	
00000000-0000-0000-0000-000000000000	138eedf5-96be-4566-b80a-f296ce74cbb4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:29:25.778449+00	
00000000-0000-0000-0000-000000000000	9bb7cabd-c976-4be1-95b3-8db9ed7b01da	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:30:57.799631+00	
00000000-0000-0000-0000-000000000000	da238658-deea-4ed4-9a2a-bd163a8f5b97	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:54:16.106004+00	
00000000-0000-0000-0000-000000000000	88271036-f4c0-44fb-a20b-b69a95288058	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 01:54:35.195238+00	
00000000-0000-0000-0000-000000000000	fe79c110-5421-4b69-984f-6a59c084ee69	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:54:38.771677+00	
00000000-0000-0000-0000-000000000000	35c21b68-ccd9-486b-a2b0-2c9074882281	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 01:56:25.6832+00	
00000000-0000-0000-0000-000000000000	18d10d31-d42a-4846-bc72-8ef5208a7066	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 01:57:11.638729+00	
00000000-0000-0000-0000-000000000000	59139cd0-3566-4c65-af2f-2fab5f5f2676	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:07:09.17989+00	
00000000-0000-0000-0000-000000000000	07ce13b0-1a46-460c-b8c4-2c820b2f4403	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:08:48.364013+00	
00000000-0000-0000-0000-000000000000	9363c63c-5439-434f-ad8a-d2f7b29526c9	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:11:13.717814+00	
00000000-0000-0000-0000-000000000000	d300ff43-9edc-4e4a-ba08-38eeffc6f730	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:12:05.56181+00	
00000000-0000-0000-0000-000000000000	89682f7b-e5e0-4ccb-80de-a2266fd84891	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:15:09.493587+00	
00000000-0000-0000-0000-000000000000	26b81a60-ea0c-4ff8-8a4c-e0c903c16756	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 02:54:58.074749+00	
00000000-0000-0000-0000-000000000000	505040d4-a0e5-4e9c-a47f-c794f297dda3	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:19:23.051876+00	
00000000-0000-0000-0000-000000000000	f2959cac-4adf-477f-8768-1a079e9e0198	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:30:08.222881+00	
00000000-0000-0000-0000-000000000000	b792d8c0-4965-40a2-b2cf-770c26b20f5c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:36:52.396074+00	
00000000-0000-0000-0000-000000000000	d97e40d8-8219-48b4-985c-aa5c452dcf07	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:41:13.245939+00	
00000000-0000-0000-0000-000000000000	9de6927c-2397-413a-b29c-262fddc12bc4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:57:53.130651+00	
00000000-0000-0000-0000-000000000000	0c0a8620-01a7-42a0-ae21-2cc324567539	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:57:57.529211+00	
00000000-0000-0000-0000-000000000000	fa0d26e7-201d-46be-9591-17e9cce006ec	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 03:59:39.039266+00	
00000000-0000-0000-0000-000000000000	9547084f-fa0f-458a-9fad-8f312808e0c7	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 03:59:56.015733+00	
00000000-0000-0000-0000-000000000000	a007e530-e99f-4abd-8058-da28c867adcc	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:00:01.116725+00	
00000000-0000-0000-0000-000000000000	a0e77022-9a2c-4498-acee-c2558c3710b3	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 04:00:19.992992+00	
00000000-0000-0000-0000-000000000000	4aae3cb0-1c9f-4910-ac15-2ba0d4831661	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:00:28.935219+00	
00000000-0000-0000-0000-000000000000	57b6c6eb-9d31-4ad5-a869-8246c699c4be	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 04:02:20.211962+00	
00000000-0000-0000-0000-000000000000	5e82b346-5186-4eb3-95e8-47e4a5a95f54	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:02:25.279657+00	
00000000-0000-0000-0000-000000000000	dfaf86b5-c778-43e9-a7c3-ff3a1db7cf9c	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 04:03:36.25966+00	
00000000-0000-0000-0000-000000000000	061054c5-00ac-40bd-bb78-ba08cb5fb9e8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:03:40.134073+00	
00000000-0000-0000-0000-000000000000	ef7fbc10-5082-4652-b4f8-d31e0c28b66f	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-18 04:04:58.520716+00	
00000000-0000-0000-0000-000000000000	0daafd08-5c81-4f37-bbe6-b9cb89eeeed4	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:05:01.637073+00	
00000000-0000-0000-0000-000000000000	b3dbcc16-3636-4f07-9341-2e633e405cf2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:17:53.256173+00	
00000000-0000-0000-0000-000000000000	1ca21c7f-0ae3-4377-90c8-46f2204a24f2	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 04:53:51.649754+00	
00000000-0000-0000-0000-000000000000	d3f1e8f8-6aa8-41bb-97c8-208fe74abbcb	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 13:20:03.705626+00	
00000000-0000-0000-0000-000000000000	fe90e927-246e-454f-997e-ca64936acb0a	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 13:20:03.706585+00	
00000000-0000-0000-0000-000000000000	b5470c3f-cb5a-4bef-b7b5-112f89e25a69	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 21:52:10.030473+00	
00000000-0000-0000-0000-000000000000	c815a8a6-8c45-4398-ac3a-ce511a70deb7	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 21:52:10.031487+00	
00000000-0000-0000-0000-000000000000	eda6a9cd-c4dd-4cb7-ae26-a21c1463aa96	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 21:54:35.136893+00	
00000000-0000-0000-0000-000000000000	c06195fb-e9a2-45a0-b23c-caad39a4a91a	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 21:55:32.446929+00	
00000000-0000-0000-0000-000000000000	6b8b4539-4335-4610-882a-05b8a212ac78	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-18 21:58:50.335094+00	
00000000-0000-0000-0000-000000000000	2212b00c-9965-4b60-8855-02412c2b863b	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 22:57:17.230347+00	
00000000-0000-0000-0000-000000000000	472ace25-ce90-4b1a-87d9-2b5da8fc82a9	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-18 22:57:17.231383+00	
00000000-0000-0000-0000-000000000000	d5341e2f-ebae-4c65-a504-0265ab3056a8	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 00:28:30.011172+00	
00000000-0000-0000-0000-000000000000	a790533f-0d05-4c0e-97a9-9ba9afda659d	{"action":"token_refreshed","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 02:38:12.737+00	
00000000-0000-0000-0000-000000000000	9b5d77af-2882-4f5c-9fe0-a6a8da392919	{"action":"token_revoked","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 02:38:12.738107+00	
00000000-0000-0000-0000-000000000000	41a99a1e-1f7f-498f-afea-80cc1f3f367a	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 02:39:26.399217+00	
00000000-0000-0000-0000-000000000000	a827c350-0b8f-478a-8df7-9e12bccd02fb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 02:40:27.169706+00	
00000000-0000-0000-0000-000000000000	3599e10a-3bb2-452f-ae24-4e015f09e0cb	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:04:03.439848+00	
00000000-0000-0000-0000-000000000000	a3edac8f-8b3d-432c-b5d8-c3748eddd55e	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:07:58.725781+00	
00000000-0000-0000-0000-000000000000	be530d3c-c076-42b3-b805-0bdcbb11c1d8	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paul+app_admin@theteam.net.au","user_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","user_phone":""}}	2025-04-19 03:21:24.431879+00	
00000000-0000-0000-0000-000000000000	7cbf2d79-346c-4c10-aa14-f8a9fcb463fe	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paul+company_admin@theteam.net.au","user_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","user_phone":""}}	2025-04-19 03:23:42.516442+00	
00000000-0000-0000-0000-000000000000	324c1d35-fce8-42aa-b24a-e5ccfd16fc01	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paul+company_user@theteam.net.au","user_id":"ffc692ce-0eaf-466b-9684-dbf98832f49b","user_phone":""}}	2025-04-19 03:24:20.545429+00	
00000000-0000-0000-0000-000000000000	62912e1b-0ad3-4a56-b992-36d6466c1602	{"action":"user_recovery_requested","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"user"}	2025-04-19 03:49:58.242257+00	
00000000-0000-0000-0000-000000000000	f97960ba-7d23-4158-a9a1-2abd03af53a8	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 03:50:13.6727+00	
00000000-0000-0000-0000-000000000000	296aae81-dc85-413c-b873-e4db7718f775	{"action":"user_recovery_requested","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"user"}	2025-04-19 03:53:55.580054+00	
00000000-0000-0000-0000-000000000000	f9a7f2b6-f5df-4cbb-ae97-29eda84f5724	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 03:54:06.647975+00	
00000000-0000-0000-0000-000000000000	2850d427-3924-4a4d-bdfc-15d01404b83f	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:54:32.805686+00	
00000000-0000-0000-0000-000000000000	ed9b95a3-01d4-41ca-921c-4169c22b1280	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:55:16.529169+00	
00000000-0000-0000-0000-000000000000	a97f9469-69cd-43b5-9ce4-d54f80ecb738	{"action":"user_recovery_requested","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"user"}	2025-04-19 03:57:06.027207+00	
00000000-0000-0000-0000-000000000000	7f8e16a5-61d7-49eb-ade2-7e5d74664da7	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:59:14.712363+00	
00000000-0000-0000-0000-000000000000	bd287efb-6d96-4f51-9a09-35d5d2c7ffbe	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 03:59:42.454841+00	
00000000-0000-0000-0000-000000000000	c729e1ab-67c4-4cd1-a61f-2e1f98c5d6ac	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:01:06.547704+00	
00000000-0000-0000-0000-000000000000	9e089e6c-be7b-49e7-81dc-74bc1d46cda3	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:03:15.969736+00	
00000000-0000-0000-0000-000000000000	83a277e1-3795-408f-a0e3-379a6030f9c5	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:03:22.661915+00	
00000000-0000-0000-0000-000000000000	1e1fbe02-bde0-40fb-8526-081d8bdf647a	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:04:10.299774+00	
00000000-0000-0000-0000-000000000000	caec746a-c44a-4451-8128-f75254d88f27	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:04:15.971476+00	
00000000-0000-0000-0000-000000000000	2bf77683-ff8e-4980-a768-24ab91f09bbf	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:06:35.756518+00	
00000000-0000-0000-0000-000000000000	8598aff4-6ca0-495e-9c49-b4660b2e9f1b	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:06:44.789432+00	
00000000-0000-0000-0000-000000000000	31cf86ec-5041-4b8f-b54c-69305005af4e	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:12:35.03147+00	
00000000-0000-0000-0000-000000000000	d02c0f06-a823-49fa-861b-926789a7c768	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:21:18.656622+00	
00000000-0000-0000-0000-000000000000	a303b086-98a0-4ac9-a3ed-c3c34859484d	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:27:13.377776+00	
00000000-0000-0000-0000-000000000000	9f3a543a-7a2f-4e0a-ad6b-1e001b043e5b	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:43:21.552697+00	
00000000-0000-0000-0000-000000000000	ec5c6278-0f25-4776-8b33-f327b0fab7a5	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:55:25.205582+00	
00000000-0000-0000-0000-000000000000	a8e22cc1-68a4-4359-9162-e3884c5b1bc2	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 04:59:15.162087+00	
00000000-0000-0000-0000-000000000000	cb337454-d5e4-48ce-be6e-794f8fbb4b8d	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 04:59:31.821779+00	
00000000-0000-0000-0000-000000000000	beb957b8-633a-4b27-9b1a-3280a079ae42	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 05:03:21.591428+00	
00000000-0000-0000-0000-000000000000	bd6fead7-cc25-434d-9fb6-239704cac5d2	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:03:27.864833+00	
00000000-0000-0000-0000-000000000000	1662273d-6346-48f1-a828-5eba6679e3ab	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:13:21.976644+00	
00000000-0000-0000-0000-000000000000	1efa40d6-9f75-4df8-a931-bd4effd8014e	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:17:32.709763+00	
00000000-0000-0000-0000-000000000000	bd829a6d-219d-4145-9fbd-256829973fb3	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:19:00.570754+00	
00000000-0000-0000-0000-000000000000	ee446bc3-2a27-4f72-9375-fc370d303bf0	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:19:07.716394+00	
00000000-0000-0000-0000-000000000000	87dd0546-70ef-47b2-b8a2-5a3eaab4da75	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 05:24:10.166667+00	
00000000-0000-0000-0000-000000000000	b2fb7192-8c98-4cda-ab1f-50dc7c9c0411	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:24:13.918597+00	
00000000-0000-0000-0000-000000000000	1648c649-d270-45c7-bcb6-494f607143fc	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 05:24:17.768557+00	
00000000-0000-0000-0000-000000000000	5b0cd1e4-94d7-4edb-ad1f-3f490fe7dd0c	{"action":"login","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:24:22.194924+00	
00000000-0000-0000-0000-000000000000	2cbe36bb-177d-4a75-b665-e9a55113c2bc	{"action":"logout","actor_id":"589e8bbe-c972-4223-8454-839eab306ca0","actor_username":"paul@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 05:24:40.76474+00	
00000000-0000-0000-0000-000000000000	9578d491-8039-4222-b38a-56aeaf2cb9ff	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:27:34.831535+00	
00000000-0000-0000-0000-000000000000	fc0d5d9e-db6b-469e-b5ea-e3ea232994dc	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:27:54.682609+00	
00000000-0000-0000-0000-000000000000	15a0d0fb-f217-4df0-a0af-b19b00e93bfe	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:36:12.899096+00	
00000000-0000-0000-0000-000000000000	0681fe23-edc5-45e1-92a3-31c4314e257e	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:36:20.884392+00	
00000000-0000-0000-0000-000000000000	0ed4ab23-bb94-4618-ac6f-47212f9aaae9	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:36:36.13203+00	
00000000-0000-0000-0000-000000000000	249f8ff6-bd6d-41a3-a8e2-80c8245ed1c6	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 05:36:41.444671+00	
00000000-0000-0000-0000-000000000000	4bf0e31d-22ba-4679-b38c-a8f77d6a634f	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 05:39:39.48802+00	
00000000-0000-0000-0000-000000000000	7b9ef42b-bf5d-4fa0-b0ca-f574b92685df	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 07:00:32.305255+00	
00000000-0000-0000-0000-000000000000	2d75feaf-7029-4829-aa2c-f6f2a6ea2021	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 07:00:32.306172+00	
00000000-0000-0000-0000-000000000000	d82ff63f-be8c-492b-91df-d9b54e944115	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 10:55:46.651076+00	
00000000-0000-0000-0000-000000000000	8d2787c4-4ba0-4faa-92dd-98d17a05f3a3	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 10:55:46.652088+00	
00000000-0000-0000-0000-000000000000	785e7e14-17cc-43cf-8cb8-e7fb44317671	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 10:56:02.797422+00	
00000000-0000-0000-0000-000000000000	e17620d8-674d-4028-9a4f-a2e77ad5718f	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 10:56:20.700718+00	
00000000-0000-0000-0000-000000000000	3eda9276-1698-4eb4-bbbd-9fa453fd4463	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 10:56:31.416205+00	
00000000-0000-0000-0000-000000000000	d4f62a94-9879-412e-a552-8c4cf851132e	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 10:59:38.78598+00	
00000000-0000-0000-0000-000000000000	d606b4d1-60e8-4dd2-a009-3f7ac0de5c21	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 10:59:46.613453+00	
00000000-0000-0000-0000-000000000000	a8505353-f71a-4574-bc9d-620cc896e998	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:01:41.457501+00	
00000000-0000-0000-0000-000000000000	7c7a4235-be3d-4dbf-b218-da9105987efe	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:01:50.164277+00	
00000000-0000-0000-0000-000000000000	ad4d68d8-abf9-4f4d-b954-db8d14ef73a1	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:03:08.553963+00	
00000000-0000-0000-0000-000000000000	c1c69630-17a0-4ae3-a649-272f49f45ff5	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:03:15.987133+00	
00000000-0000-0000-0000-000000000000	95496402-7b47-4e6f-ba74-672b8d1047d2	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:04:37.4558+00	
00000000-0000-0000-0000-000000000000	64460d2c-afe2-410f-ad96-e2b55f0ddc0b	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:04:44.126756+00	
00000000-0000-0000-0000-000000000000	f01996d9-7b25-4a99-9460-b2e6b20d2166	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 11:04:48.878541+00	
00000000-0000-0000-0000-000000000000	890944e1-a015-4a2c-8cbf-779c8e145d84	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:04:55.798598+00	
00000000-0000-0000-0000-000000000000	06cf9ec7-8105-43ce-af43-78567c7c9abf	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:05:01.046034+00	
00000000-0000-0000-0000-000000000000	ff33c949-40bd-4aee-b48c-01b3e09fe139	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 11:05:09.302201+00	
00000000-0000-0000-0000-000000000000	8a49949f-6d60-4ee7-859a-e119a6c43d57	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:05:14.212751+00	
00000000-0000-0000-0000-000000000000	b4aa9707-3260-47f9-bb32-153abf8b7e1b	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:05:19.750304+00	
00000000-0000-0000-0000-000000000000	d513ace4-587d-4051-872e-ce2a0004e5e8	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:06:20.182325+00	
00000000-0000-0000-0000-000000000000	04e37211-5de2-4106-910e-4667337c0ec1	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:06:26.575945+00	
00000000-0000-0000-0000-000000000000	a4d226bc-9b86-4c50-8e2f-f2a4eb72d0d6	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:08:01.681707+00	
00000000-0000-0000-0000-000000000000	c6970b18-9933-4426-ba62-54664ce5d543	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:08:08.96106+00	
00000000-0000-0000-0000-000000000000	4f284343-93ac-4653-8f3c-a85d5d12dee5	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:09:01.727032+00	
00000000-0000-0000-0000-000000000000	40c454a2-5d70-42b4-9855-8a609b09b065	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:09:07.416172+00	
00000000-0000-0000-0000-000000000000	ae5a9a5d-ec4a-4c09-8f4d-7755f89c9cf7	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:10:34.790677+00	
00000000-0000-0000-0000-000000000000	4f7617ff-e448-49ba-a8d8-9c849bbfa30c	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:10:40.573476+00	
00000000-0000-0000-0000-000000000000	e48ad267-4f70-4af9-b78a-9d083d0725e4	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 11:12:34.270228+00	
00000000-0000-0000-0000-000000000000	fe36dd78-3b8a-4ae2-9cd9-b6faba490417	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:12:38.419746+00	
00000000-0000-0000-0000-000000000000	ea564487-7e86-4066-83ea-3d97646eae71	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 11:24:57.933199+00	
00000000-0000-0000-0000-000000000000	d447e31e-674d-4a78-a41e-32be2c1bb164	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:25:01.983546+00	
00000000-0000-0000-0000-000000000000	4ee1c2c3-73bc-4a8a-a54f-db20d0bb2dea	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 11:53:43.40898+00	
00000000-0000-0000-0000-000000000000	b7eced84-d829-485f-9e2a-9b50a35a7fae	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 11:53:47.639474+00	
00000000-0000-0000-0000-000000000000	21b110d4-95b9-4e28-afbb-5da6a73db672	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 16:17:51.839027+00	
00000000-0000-0000-0000-000000000000	b0c9b686-8b06-46af-bd8b-b97635f73b37	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-19 16:17:51.839956+00	
00000000-0000-0000-0000-000000000000	35054215-d9b6-4fa0-8b47-0dc54da1cfb6	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:00:14.777289+00	
00000000-0000-0000-0000-000000000000	397a3c46-a763-4296-9ae5-ec4eaf49c54d	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:24:20.169569+00	
00000000-0000-0000-0000-000000000000	d6087857-0970-4819-91bf-a53c201aea82	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:24:30.591484+00	
00000000-0000-0000-0000-000000000000	32a997e2-4b89-4e0d-bd6a-e233b71be46a	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:30:41.2461+00	
00000000-0000-0000-0000-000000000000	390f62d3-382a-4b28-9a00-a7338aaf8cad	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:30:49.233802+00	
00000000-0000-0000-0000-000000000000	336f9d70-d6f9-4386-9f91-b685092f1c5b	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:36:44.136747+00	
00000000-0000-0000-0000-000000000000	6fb1e832-5512-492c-9296-4a7386637cba	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:17:28.14225+00	
00000000-0000-0000-0000-000000000000	46c6a34a-a4b6-48ca-801f-ccdfbb596192	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 20:31:38.549713+00	
00000000-0000-0000-0000-000000000000	ea8652cd-0de4-4f95-b210-023245903ff1	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:38:20.792467+00	
00000000-0000-0000-0000-000000000000	f46c8e8d-fbec-4c52-afe4-193e98be944d	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:38:33.171916+00	
00000000-0000-0000-0000-000000000000	38cd30c0-4544-42e7-a5bb-566a922df51c	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 20:42:36.815451+00	
00000000-0000-0000-0000-000000000000	93261e9d-144c-4b50-abff-7a4f61cd94b0	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:42:46.644189+00	
00000000-0000-0000-0000-000000000000	08a84c03-67bd-43d6-9229-045eeb96ac95	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 20:54:20.639202+00	
00000000-0000-0000-0000-000000000000	e515f6b2-323c-44df-b9ba-3358c0b8edee	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:54:26.214044+00	
00000000-0000-0000-0000-000000000000	380fe9c7-940f-4c20-bb32-16cfa08f5ada	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 20:56:21.728069+00	
00000000-0000-0000-0000-000000000000	faf27117-f93e-414c-b8a7-35cf54b9e18f	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 20:56:37.688137+00	
00000000-0000-0000-0000-000000000000	af363141-ceb5-48a4-bb89-15f494fe7c3d	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 21:14:19.051975+00	
00000000-0000-0000-0000-000000000000	d84f3f58-79f9-45ee-9dea-779089d42a57	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 21:14:24.042091+00	
00000000-0000-0000-0000-000000000000	2684c306-640d-4d86-ba62-bfb6bda38f64	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 21:17:40.925716+00	
00000000-0000-0000-0000-000000000000	c51eb85a-2a92-485a-9947-1510d07e7618	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 21:17:47.281718+00	
00000000-0000-0000-0000-000000000000	23f4052d-0585-4e1f-8053-85255d45095e	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 21:40:48.184497+00	
00000000-0000-0000-0000-000000000000	42007786-260f-40b2-bcb4-b098b1d167df	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 21:40:53.100264+00	
00000000-0000-0000-0000-000000000000	9d3ef18f-c863-4700-9f72-e3d521aaafa2	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 21:46:06.568027+00	
00000000-0000-0000-0000-000000000000	e6452865-6500-4c50-84f1-3d81b7e7113a	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 21:50:15.956405+00	
00000000-0000-0000-0000-000000000000	b4b49c5b-5073-44bb-ab0c-576ee0010259	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 21:57:19.861828+00	
00000000-0000-0000-0000-000000000000	9104ca99-a806-47d0-9aed-19129fea566f	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 21:57:22.230206+00	
00000000-0000-0000-0000-000000000000	a67ed1a4-88c3-4e76-b2f9-24550a4acb93	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:02:05.031497+00	
00000000-0000-0000-0000-000000000000	c050405b-01e7-4894-9082-65154f40bbae	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:27:10.60092+00	
00000000-0000-0000-0000-000000000000	dac8de15-11b5-485c-b455-76d973bd6eff	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:27:15.525582+00	
00000000-0000-0000-0000-000000000000	151b2c08-60c5-4291-a73f-e0403c8ed54c	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:49:09.971893+00	
00000000-0000-0000-0000-000000000000	2f33c354-d88a-4764-8364-5c02dccd9403	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:49:15.365695+00	
00000000-0000-0000-0000-000000000000	7ed65fc3-a086-43c6-b85b-2c1da7050be4	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:49:33.577442+00	
00000000-0000-0000-0000-000000000000	2e983238-410d-4ab8-b96f-82a67ff85a01	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:49:40.700786+00	
00000000-0000-0000-0000-000000000000	b44dfb94-6ef9-4545-a234-68c103bb9ff4	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:56:44.563173+00	
00000000-0000-0000-0000-000000000000	0500c531-7e90-4eab-9447-4411b1142834	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:56:50.131975+00	
00000000-0000-0000-0000-000000000000	85c86963-8a61-4967-afbe-634d45678d1a	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:59:04.300619+00	
00000000-0000-0000-0000-000000000000	dc3c4c08-0ed5-47cb-af51-5d6526475def	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 22:59:08.814838+00	
00000000-0000-0000-0000-000000000000	b7d32a7a-1363-4789-8406-2722f48d569a	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 23:09:41.489808+00	
00000000-0000-0000-0000-000000000000	6433b69b-6219-4aff-9e9f-13933f0ae857	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 23:09:46.286342+00	
00000000-0000-0000-0000-000000000000	7893996c-30c8-476f-8dc1-114cc647c950	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 23:09:57.886657+00	
00000000-0000-0000-0000-000000000000	9275780c-8f49-4bb8-a41d-9b4a362d6977	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 23:10:05.288368+00	
00000000-0000-0000-0000-000000000000	4c23133f-ae0d-48b4-9c01-55d2348ec6d4	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 23:18:13.925843+00	
00000000-0000-0000-0000-000000000000	124af1da-fc92-489a-8f13-02e22fc48582	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 23:18:32.510637+00	
00000000-0000-0000-0000-000000000000	63a4b9eb-004d-474d-9718-d616bcefb9ae	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-19 23:58:37.759987+00	
00000000-0000-0000-0000-000000000000	42c619d3-4ff2-4955-b814-f7b5066c67c9	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 23:58:42.322445+00	
00000000-0000-0000-0000-000000000000	723a8e25-d490-4d25-b5e8-d2f63b0f0a0f	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-20 00:09:32.579939+00	
00000000-0000-0000-0000-000000000000	b2db4d15-2040-44d7-9230-dde0a8da1f57	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 00:09:39.483602+00	
00000000-0000-0000-0000-000000000000	b7160bc4-0a48-4875-b328-cfdff8ba6a0e	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-20 00:22:47.342821+00	
00000000-0000-0000-0000-000000000000	dacab7b9-7fc4-4947-887f-fb12b9347b07	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 00:27:41.915483+00	
00000000-0000-0000-0000-000000000000	de6cf2ef-2502-4e09-9598-b6050242d34c	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 00:27:56.995862+00	
00000000-0000-0000-0000-000000000000	fab92c86-46a3-4f87-9c49-f1ea58b0fe3b	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 06:39:38.255109+00	
00000000-0000-0000-0000-000000000000	4b36acb5-acb5-4d02-be2e-3278ea225341	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 06:39:38.256037+00	
00000000-0000-0000-0000-000000000000	98837a43-fcfc-4031-9b05-2e624a97f3f0	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-20 06:39:50.43266+00	
00000000-0000-0000-0000-000000000000	37f7227a-a545-4c9c-99de-8b265f155874	{"action":"login","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 06:39:55.917325+00	
00000000-0000-0000-0000-000000000000	5f4083b1-89dd-4b82-8705-99bd232dd99c	{"action":"token_refreshed","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 08:30:09.266505+00	
00000000-0000-0000-0000-000000000000	42bcbd73-a71e-4c49-a8b7-cc0a0788432c	{"action":"token_revoked","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 08:30:09.267487+00	
00000000-0000-0000-0000-000000000000	753481bf-e1d3-4a69-96dd-38d1e14c7ba7	{"action":"logout","actor_id":"4578c9c6-d8f3-4eaf-a476-33bd6ee07f78","actor_username":"paul+company_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-20 08:30:19.673189+00	
00000000-0000-0000-0000-000000000000	32f5b8aa-650a-49fc-93f4-effbb03ecd62	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 08:30:24.957177+00	
00000000-0000-0000-0000-000000000000	d47fa190-00f1-409d-a16e-f11c3e028b33	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 10:22:59.902158+00	
00000000-0000-0000-0000-000000000000	dc050f09-0efc-4d86-8245-4890e855fa8b	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 10:22:59.903022+00	
00000000-0000-0000-0000-000000000000	5eb9be9a-d0d3-4f20-bff0-c30c550d82cd	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:23:07.392385+00	
00000000-0000-0000-0000-000000000000	eef9fd90-fc49-4396-b50c-8d2586b11974	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:28:50.891285+00	
00000000-0000-0000-0000-000000000000	5b7c8ff7-6769-408d-960d-20af6140eb3b	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:55:15.229733+00	
00000000-0000-0000-0000-000000000000	cfe45343-da9b-419b-9e34-f99b16f639ca	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:55:29.542268+00	
00000000-0000-0000-0000-000000000000	003e0903-afe1-4bb3-a6c7-7b4f040a6ce7	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:56:23.782872+00	
00000000-0000-0000-0000-000000000000	3ffb1ed1-8d7f-4555-b74e-6d749adf2e3c	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:56:39.731189+00	
00000000-0000-0000-0000-000000000000	c114489b-4eaa-413d-8f61-381e55c2dae9	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:58:56.954538+00	
00000000-0000-0000-0000-000000000000	75b52c30-d8ee-49f7-aa53-b815bbecbdd6	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 10:59:09.807965+00	
00000000-0000-0000-0000-000000000000	96f41e19-1a4f-47e4-b213-4bcedb33fc56	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 11:06:05.344342+00	
00000000-0000-0000-0000-000000000000	ff37ba8c-f311-4d23-b619-aa2c4b4ba78e	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 11:07:37.263479+00	
00000000-0000-0000-0000-000000000000	4e2b5aa5-6b54-4b88-a652-dc63df9149c8	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 11:08:25.888072+00	
00000000-0000-0000-0000-000000000000	8e152096-b482-4ab5-96d2-1baffefbe2ac	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 11:10:31.597785+00	
00000000-0000-0000-0000-000000000000	8c2be0c4-0c68-4984-81bc-5797e0f34fd9	{"action":"logout","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account"}	2025-04-20 11:27:46.43869+00	
00000000-0000-0000-0000-000000000000	6bbb0a5b-97b3-432e-9827-1a9c1e6b116b	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 11:27:51.801836+00	
00000000-0000-0000-0000-000000000000	2c53afda-dbd8-48e5-b7e3-025cfba272f6	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 12:26:04.041894+00	
00000000-0000-0000-0000-000000000000	9bc72756-e2ca-4a90-8cda-f2365e35c984	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 12:26:04.042875+00	
00000000-0000-0000-0000-000000000000	c069219b-2c1b-44b6-aec3-fff71a015131	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 18:45:00.251446+00	
00000000-0000-0000-0000-000000000000	01547e75-3c47-468f-a7dd-019c987c3d65	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 18:45:00.257466+00	
00000000-0000-0000-0000-000000000000	19ae720e-8f77-406b-961e-524c483ad542	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 20:20:32.890543+00	
00000000-0000-0000-0000-000000000000	18be9e2b-dfc2-470a-a345-97191bb0b435	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 20:20:32.891563+00	
00000000-0000-0000-0000-000000000000	2a8fc801-2d48-48c5-8cae-9128f6c92c75	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 20:21:22.550762+00	
00000000-0000-0000-0000-000000000000	dc097943-4c62-49b3-98ce-d7b19e4036be	{"action":"token_refreshed","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 23:44:54.540615+00	
00000000-0000-0000-0000-000000000000	e730517b-e390-4ee3-b257-2abf41a84c55	{"action":"token_revoked","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"token"}	2025-04-20 23:44:54.541594+00	
00000000-0000-0000-0000-000000000000	aae37524-8e6b-4089-ba58-95d8b147523c	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-21 00:10:56.144057+00	
00000000-0000-0000-0000-000000000000	a4633fdd-d37a-4836-8d53-fa8e2d6257ee	{"action":"login","actor_id":"f3dc6cb2-e289-4219-8da3-820bc02ccbef","actor_username":"paul+app_admin@theteam.net.au","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-21 00:13:44.642795+00	
\.
--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.
--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
589e8bbe-c972-4223-8454-839eab306ca0	589e8bbe-c972-4223-8454-839eab306ca0	{"sub": "589e8bbe-c972-4223-8454-839eab306ca0", "email": "paul@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-15 15:10:00.65695+00	2025-04-15 15:10:00.657024+00	2025-04-15 15:10:00.657024+00	54bafd6a-ef0a-4fb0-aa1d-082570468061
c194aba1-86a5-4df9-9e3a-b38abbd928fe	c194aba1-86a5-4df9-9e3a-b38abbd928fe	{"sub": "c194aba1-86a5-4df9-9e3a-b38abbd928fe", "email": "meryl@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-15 21:24:11.78578+00	2025-04-15 21:24:11.785837+00	2025-04-15 21:24:11.785837+00	f78c03fb-5d92-4d56-a2ca-ed47bf52b191
3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f	3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f	{"sub": "3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f", "email": "rachel@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-15 21:24:35.737307+00	2025-04-15 21:24:35.737358+00	2025-04-15 21:24:35.737358+00	e1cc3451-a5de-430e-b897-73e03752b6e3
9dcfbee0-4f72-472d-8c9b-d4bd2de90abe	9dcfbee0-4f72-472d-8c9b-d4bd2de90abe	{"sub": "9dcfbee0-4f72-472d-8c9b-d4bd2de90abe", "email": "paul+super_admin@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-17 13:01:22.950824+00	2025-04-17 13:01:22.950878+00	2025-04-17 13:01:22.950878+00	138de4aa-aa3b-44fd-abfe-be3493e5e59b
f3dc6cb2-e289-4219-8da3-820bc02ccbef	f3dc6cb2-e289-4219-8da3-820bc02ccbef	{"sub": "f3dc6cb2-e289-4219-8da3-820bc02ccbef", "email": "paul+app_admin@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-19 03:21:24.430922+00	2025-04-19 03:21:24.43098+00	2025-04-19 03:21:24.43098+00	e9ef4602-13c1-43d7-a45b-0061beb4cc7d
4578c9c6-d8f3-4eaf-a476-33bd6ee07f78	4578c9c6-d8f3-4eaf-a476-33bd6ee07f78	{"sub": "4578c9c6-d8f3-4eaf-a476-33bd6ee07f78", "email": "paul+company_admin@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-19 03:23:42.515483+00	2025-04-19 03:23:42.515537+00	2025-04-19 03:23:42.515537+00	3e8ef589-28ce-4d89-80c3-22f7566349c0
ffc692ce-0eaf-466b-9684-dbf98832f49b	ffc692ce-0eaf-466b-9684-dbf98832f49b	{"sub": "ffc692ce-0eaf-466b-9684-dbf98832f49b", "email": "paul+company_user@theteam.net.au", "email_verified": false, "phone_verified": false}	email	2025-04-19 03:24:20.544606+00	2025-04-19 03:24:20.544661+00	2025-04-19 03:24:20.544661+00	8a71846f-c53a-4c93-9852-f308a8308a0f
\.
--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.
--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
d7349ae4-23cd-41a5-b673-7ae3c6eddbd9	2025-04-20 11:27:51.805601+00	2025-04-20 11:27:51.805601+00	password	ae21c394-5638-4e74-8738-428b12b2d2d6
ef97b285-ed59-4059-bf3d-3968b128dbe8	2025-04-20 20:21:22.553599+00	2025-04-20 20:21:22.553599+00	password	d5972a0c-14d4-47c7-959b-1b76006083f9
1126479d-aa0c-4ff8-a494-a71933cf90a0	2025-04-21 00:10:56.149106+00	2025-04-21 00:10:56.149106+00	password	d13eee75-4f16-4575-acfb-673410dc449d
47ad2c75-4e2b-43e4-8f72-c775c37ef15d	2025-04-21 00:13:44.647317+00	2025-04-21 00:13:44.647317+00	password	bd519209-3536-4d44-95d8-137e357d20d0
\.
--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.
--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.
--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
cdc016d7-6d7e-41bf-94ae-109715e5bedc	f3dc6cb2-e289-4219-8da3-820bc02ccbef	recovery_token	2dd004d173d43509695d3fe1af7da0870e63cb73c85b8b2069f7a98f	paul+app_admin@theteam.net.au	2025-04-19 03:57:07.740222	2025-04-19 03:57:07.740222
\.
--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	490	GivN63dx68pltDSYTH0SYw	f3dc6cb2-e289-4219-8da3-820bc02ccbef	t	2025-04-20 12:26:04.044063+00	2025-04-20 18:45:00.260184+00	mXmFrKn8dLcsG_5mZ0WpRg	d7349ae4-23cd-41a5-b673-7ae3c6eddbd9
00000000-0000-0000-0000-000000000000	492	3v8DVaf8AOWJvmfR9iefcQ	f3dc6cb2-e289-4219-8da3-820bc02ccbef	f	2025-04-20 20:20:32.892875+00	2025-04-20 20:20:32.892875+00	hCFXmMsKM46b5b9MfSzp0w	d7349ae4-23cd-41a5-b673-7ae3c6eddbd9
00000000-0000-0000-0000-000000000000	493	5DHzGxF-5J4u4UVJM1mL1A	f3dc6cb2-e289-4219-8da3-820bc02ccbef	t	2025-04-20 20:21:22.552357+00	2025-04-20 23:44:54.542121+00	\N	ef97b285-ed59-4059-bf3d-3968b128dbe8
00000000-0000-0000-0000-000000000000	495	h-sW3wfwyTPIYJ10Nc3CHg	f3dc6cb2-e289-4219-8da3-820bc02ccbef	f	2025-04-21 00:10:56.146692+00	2025-04-21 00:10:56.146692+00	\N	1126479d-aa0c-4ff8-a494-a71933cf90a0
00000000-0000-0000-0000-000000000000	489	mXmFrKn8dLcsG_5mZ0WpRg	f3dc6cb2-e289-4219-8da3-820bc02ccbef	t	2025-04-20 11:27:51.803449+00	2025-04-20 12:26:04.043394+00	\N	d7349ae4-23cd-41a5-b673-7ae3c6eddbd9
00000000-0000-0000-0000-000000000000	491	hCFXmMsKM46b5b9MfSzp0w	f3dc6cb2-e289-4219-8da3-820bc02ccbef	t	2025-04-20 18:45:00.26147+00	2025-04-20 20:20:32.892164+00	GivN63dx68pltDSYTH0SYw	d7349ae4-23cd-41a5-b673-7ae3c6eddbd9
00000000-0000-0000-0000-000000000000	494	V0c3S5fv92XEdPJUx_7J4A	f3dc6cb2-e289-4219-8da3-820bc02ccbef	f	2025-04-20 23:44:54.543417+00	2025-04-20 23:44:54.543417+00	5DHzGxF-5J4u4UVJM1mL1A	ef97b285-ed59-4059-bf3d-3968b128dbe8
00000000-0000-0000-0000-000000000000	496	liiIItJGZAc_RrEBkzJ2LQ	f3dc6cb2-e289-4219-8da3-820bc02ccbef	f	2025-04-21 00:13:44.64498+00	2025-04-21 00:13:44.64498+00	\N	47ad2c75-4e2b-43e4-8f72-c775c37ef15d
\.
--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.
--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.
--
--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
d7349ae4-23cd-41a5-b673-7ae3c6eddbd9	f3dc6cb2-e289-4219-8da3-820bc02ccbef	2025-04-20 11:27:51.802574+00	2025-04-20 20:20:32.898194+00	\N	aal1	\N	2025-04-20 20:20:32.898123	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	101.189.44.76	\N
ef97b285-ed59-4059-bf3d-3968b128dbe8	f3dc6cb2-e289-4219-8da3-820bc02ccbef	2025-04-20 20:21:22.551485+00	2025-04-20 23:44:54.546531+00	\N	aal1	\N	2025-04-20 23:44:54.546461	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	101.189.44.76	\N
1126479d-aa0c-4ff8-a494-a71933cf90a0	f3dc6cb2-e289-4219-8da3-820bc02ccbef	2025-04-21 00:10:56.145457+00	2025-04-21 00:10:56.145457+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	101.189.44.76	\N
47ad2c75-4e2b-43e4-8f72-c775c37ef15d	f3dc6cb2-e289-4219-8da3-820bc02ccbef	2025-04-21 00:13:44.643798+00	2025-04-21 00:13:44.643798+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	101.189.44.76	\N
\.
--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.
--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.
--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	f3dc6cb2-e289-4219-8da3-820bc02ccbef	authenticated	authenticated	paul+app_admin@theteam.net.au	$2a$06$qO6hPK9i884apo38mDVZYOvkVN16tlj23qXZ5tYgy49RRkyYB5zp.	2025-04-19 03:21:24.433414+00	\N		\N	2dd004d173d43509695d3fe1af7da0870e63cb73c85b8b2069f7a98f	2025-04-19 03:57:06.0281+00			\N	2025-04-21 00:13:44.643721+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-19 03:21:24.428775+00	2025-04-21 00:13:44.646335+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4578c9c6-d8f3-4eaf-a476-33bd6ee07f78	authenticated	authenticated	paul+company_admin@theteam.net.au	$2a$10$dl7u5MxYCWH4YZHiXfy.S.VEB7k/Y7WopPmb5eXTapXEMVPV0bC7S	2025-04-19 03:23:42.518016+00	\N		\N		\N			\N	2025-04-20 06:39:55.918079+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-19 03:23:42.513356+00	2025-04-20 08:30:09.269946+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c194aba1-86a5-4df9-9e3a-b38abbd928fe	authenticated	authenticated	meryl@theteam.net.au	$2a$10$2oYWrInneJPxblF0c8OhE.EQ4tM.t/PC6L64dkbUi9wRIGec7DsOq	2025-04-15 21:24:11.788355+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-15 21:24:11.782988+00	2025-04-15 21:24:11.789256+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f	authenticated	authenticated	rachel@theteam.net.au	$2a$10$0wyOt5Ok/XYkWih54sip8emr2lllALfBVIJ6SOE86RLfY3SHki/uO	2025-04-15 21:24:35.739206+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-15 21:24:35.736283+00	2025-04-15 21:24:35.739958+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ffc692ce-0eaf-466b-9684-dbf98832f49b	authenticated	authenticated	paul+company_user@theteam.net.au	$2a$10$Y8jLwJQjmh80IaSe1el9muVbuAB3K7P1qLS1NS.GUc53fwt0uZl46	2025-04-19 03:24:20.546512+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-19 03:24:20.543225+00	2025-04-19 03:24:20.547231+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9dcfbee0-4f72-472d-8c9b-d4bd2de90abe	authenticated	authenticated	paul+super_admin@theteam.net.au	$2a$10$IWOppM/yqtL.BI9M3ClkFOoRLA85zm0YTpLzjMgWYjPmk1X9gPLZC	2025-04-17 13:01:22.953065+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-17 13:01:22.949351+00	2025-04-17 13:01:22.953991+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	589e8bbe-c972-4223-8454-839eab306ca0	authenticated	authenticated	paul@theteam.net.au	$2a$10$bzNcwG0wkMdk0W5lR724b.eNSOsN.i.OIhOysVZ/SuWpFHVWSeSvO	2025-04-15 15:10:00.662837+00	\N		\N		\N			\N	2025-04-19 05:24:22.195714+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-04-15 15:10:00.64774+00	2025-04-19 05:24:22.197559+00	\N	\N			\N		0	\N		\N	f	\N	f
\.
--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (id, action, performed_by, target_id, target_type, company_id, details, created_at, ip_address, user_agent) FROM stdin;
\.
--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.companies (id, name, website, settings, created_at, updated_at, slug, logo_url, archived_at) FROM stdin;
22222222-2222-2222-2222-222222222222	Tech Innovators	https://tech-innovators.example.com	{}	2025-04-15 21:22:41.975186+00	2025-04-19 23:44:39.574179+00	\N	\N	\N
33333333-3333-3333-3333-333333333333	Global Solutions	https://global-solutions.example.com	{}	2025-04-15 21:22:41.975186+00	2025-04-19 23:44:39.574179+00	\N	\N	\N
a465a6a6-e646-4bca-8e8f-62017887ded3	Team Group Pty Ltd	https://theteam.com.au	{}	2025-04-19 23:43:39.585143+00	2025-04-19 23:44:39.574179+00	\N	\N	\N
012457a7-b407-46dc-b13e-fb2de2569085	test delete	https://test.com	{}	2025-04-19 23:44:06.668234+00	2025-04-19 23:50:50.551491+00	\N	\N	\N
2703a0a0-dac8-4492-ac06-bbc76e4163ec	test 2	http://test.com	{}	2025-04-20 20:47:27.196283+00	2025-04-20 20:47:27.196283+00	\N		\N
11111111-1111-1111-1111-111111111111	Acme Corporation	https://acme.example.com	{}	2025-04-15 21:22:41.975186+00	2025-04-21 00:19:52.033932+00	\N		\N
\.
--
-- Data for Name: content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content (id, company_id, name, url, description, content_type, created_at, updated_at, updated_by) FROM stdin;
\.
--
-- Data for Name: content_content_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_content_tags (content_id, tag_id, created_at) FROM stdin;
\.
--
-- Data for Name: content_role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_role_permissions (content_id, role_id, view_permission, edit_permission) FROM stdin;
\.
--
-- Data for Name: content_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_tags (id, name, color, menu_sections, company_id, created_at, updated_at) FROM stdin;
77777777-7777-7777-7777-777777777777	Important	#f43f5e	\N	11111111-1111-1111-1111-111111111111	2025-04-15 21:22:41.975186+00	2025-04-15 21:22:41.975186+00
88888888-8888-8888-8888-888888888888	Draft	#f97316	\N	22222222-2222-2222-2222-222222222222	2025-04-15 21:22:41.975186+00	2025-04-15 21:22:41.975186+00
99999999-9999-9999-9999-999999999999	Archived	#eab308	\N	33333333-3333-3333-3333-333333333333	2025-04-15 21:22:41.975186+00	2025-04-15 21:22:41.975186+00
\.
--
-- Data for Name: menu_sections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menu_sections (id, name, description, color, parent_id, company_id, created_at, updated_at) FROM stdin;
\.
--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, email, full_name, avatar_url, current_company_id, created_at, updated_at, selected_company_id) FROM stdin;
f3dc6cb2-e289-4219-8da3-820bc02ccbef	paul+app_admin@theteam.net.au	Paul App Admin	\N	\N	2025-04-19 20:14:34.773889+00	2025-04-19 23:16:47.17803+00	\N
\.
--
-- Data for Name: protected_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.protected_roles (id, name, description, created_at, updated_at) FROM stdin;
940922a8-01df-4ef5-9943-6218fe60f7ce	App_Admin	System administrator with full access	2025-04-20 10:16:30.511354+00	2025-04-20 10:16:30.511354+00
6f82a67e-30d8-4d02-a87c-cad1edc0505b	Company_Admin	Company administrator with full company access	2025-04-20 10:16:30.511354+00	2025-04-20 10:16:30.511354+00
\.
--
-- Data for Name: public_submitters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.public_submitters (id, name, email, created_at) FROM stdin;
\.
--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (role_id, permission_key, created_at) FROM stdin;
00000000-0000-0000-0000-000000000001	manage_users	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000001	manage_roles	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000001	manage_content	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000001	manage_settings	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000001	manage_companies	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000002	manage_users	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000002	manage_content	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000002	manage_settings	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000004	view_content	2025-04-19 04:52:57.093616+00
00000000-0000-0000-0000-000000000001	users.view	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	users.create	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	users.edit	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	users.delete	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	companies.view	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	companies.create	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	companies.edit	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	companies.delete	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	roles.view	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	roles.create	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	roles.edit	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	roles.delete	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	content.view	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	content.create	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	content.edit	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	content.delete	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	system.manage	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	system.audit	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	system.settings	2025-04-19 16:38:17.663426+00
00000000-0000-0000-0000-000000000001	can_manage_companies	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000001	can_manage_users	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000001	can_manage_roles	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000001	can_manage_content	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000001	can_manage_categories	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000001	can_manage_tags	2025-04-19 17:30:26.086284+00
00000000-0000-0000-0000-000000000002	users.view	2025-04-19 22:39:18.43631+00
00000000-0000-0000-0000-000000000002	users.create	2025-04-19 22:39:18.43631+00
00000000-0000-0000-0000-000000000002	users.edit	2025-04-19 22:39:18.43631+00
00000000-0000-0000-0000-000000000002	users.delete	2025-04-19 22:39:18.43631+00
00000000-0000-0000-0000-000000000002	users.manage	2025-04-20 00:26:41.951854+00
00000000-0000-0000-0000-000000000002	companies.view	2025-04-20 00:26:41.951854+00
00000000-0000-0000-0000-000000000002	roles.view	2025-04-20 00:26:41.951854+00
00000000-0000-0000-0000-000000000002	content.manage	2025-04-20 00:26:41.951854+00
\.
--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, is_system_role, created_at, updated_at, company_id) FROM stdin;
00000000-0000-0000-0000-000000000002	Company_Admin	Company manager with limited admin access	t	2025-04-15 21:22:41.975186+00	2025-04-20 00:26:41.951854+00	\N
00000000-0000-0000-0000-000000000004	User	\N	f	2025-04-18 12:34:23+00	2025-04-18 12:34:30.726142+00	\N
00000000-0000-0000-0000-000000000001	App_Admin	System administrator with company management permissions	t	2025-04-15 21:22:41.975186+00	2025-04-15 21:22:41.975186+00	\N
\.
--
--
-- Data for Name: user_companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_companies (user_id, company_id, created_at, status, last_login_at) FROM stdin;
\.
--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (user_id, role_id, company_id, created_at) FROM stdin;
f3dc6cb2-e289-4219-8da3-820bc02ccbef	00000000-0000-0000-0000-000000000001	\N	2025-04-19 22:58:42.32532+00
4578c9c6-d8f3-4eaf-a476-33bd6ee07f78	00000000-0000-0000-0000-000000000002	\N	2025-04-20 00:26:41.951854+00
\.
--
--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.
--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
documents	documents	\N	2025-04-16 10:34:14.931395+00	2025-04-16 10:34:14.931395+00	f	f	\N	\N	\N
\.
--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-04-15 13:24:51.979848
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-04-15 13:24:51.984085
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-04-15 13:24:51.987478
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-04-15 13:24:52.004707
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-04-15 13:24:52.027689
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-04-15 13:24:52.031492
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-04-15 13:24:52.035807
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-04-15 13:24:52.040155
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-04-15 13:24:52.043648
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-04-15 13:24:52.047416
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-04-15 13:24:52.051362
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-04-15 13:24:52.055946
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-04-15 13:24:52.060413
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-04-15 13:24:52.0642
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-04-15 13:24:52.067887
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-04-15 13:24:52.094982
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-04-15 13:24:52.099028
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-04-15 13:24:52.103099
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-04-15 13:24:52.107205
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-04-15 13:24:52.112124
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-04-15 13:24:52.115895
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-04-15 13:24:52.124938
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-04-15 13:24:52.154166
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-04-15 13:24:52.179203
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-04-15 13:24:52.183408
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-04-15 13:24:52.187205
\.
--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
301809f2-e2f6-4aca-8d25-a5039427ff63	documents	33333333-3333-3333-3333-333333333333/dsb3brzuk6w.jpg	589e8bbe-c972-4223-8454-839eab306ca0	2025-04-16 10:40:42.044866+00	2025-04-16 10:40:42.044866+00	2025-04-16 10:40:42.044866+00	{"eTag": "\\"215ae4adf4f6256152e525c92b177df9\\"", "size": 7212, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-04-16T10:40:43.000Z", "contentLength": 7212, "httpStatusCode": 200}	56bbdb2f-8ee4-4bfb-97f9-cfa6a210a837	589e8bbe-c972-4223-8454-839eab306ca0	{}
\.
--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.
--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.
--
--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY supabase_migrations.seed_files (path, hash) FROM stdin;
\.
--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.
--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 496, true);
--
--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);
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
-- Name: user_role_permissions_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.user_role_permissions_view;
--
-- PostgreSQL database dump complete
--

