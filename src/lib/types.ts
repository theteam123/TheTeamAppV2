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
  is_system_role?: boolean;
  role_permissions: {
    permission_key: string;
  }[];
}

export interface RolePermission {
  permission_key: string;
}

export interface UserRole {
  user_id: string;
  role_id: string;
  company_id: string;
  roles?: {
    name: string;
    description?: string;
  };
}

// Extend the Supabase User type to include our custom profile
export interface User extends SupabaseUser {
  profile?: Profile;
  role?: string;
  status?: 'active' | 'inactive' | 'pending' | 'invited';
}

export interface RoleFormData {
  id: string;
  name: string;
  description: string;
  permissions: string[];
}

export interface Company {
  id: string;
  name: string;
  website?: string;
  settings?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface AuditDetails {
  previous_status?: string;
  new_status?: string;
  [key: string]: any;
}