// Add to existing types.ts
export interface Permission {
  key: string;
  name: string;
}

export interface PermissionGroup {
  [category: string]: Permission[];
}

import type { User as SupabaseUser } from '@supabase/supabase-js';

export interface Profile {
  id: string;
  updated_at?: string;
  username?: string;
  full_name?: string;
  avatar_url?: string;
  current_company_id?: string;
  email?: string;
}

export interface Role {
  id: string;
  name: string;
  description: string;
  role_permissions: RolePermission[];
}

export interface RolePermission {
  permission_key: string;
}

export interface UserRole {
  role_id: string;
  company_id: string;
  roles: Role;
}

// Extend the Supabase User type to include our custom profile
export interface User extends SupabaseUser {
  profile?: Profile;
}

export interface RoleFormData {
  id: string;
  name: string;
  description: string;
  permissions: string[];
}