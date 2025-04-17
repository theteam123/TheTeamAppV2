// Add to existing types.ts
export interface Permission {
  key: string;
  name: string;
}

export interface PermissionGroup {
  [category: string]: Permission[];
}

export interface Role {
  id: string;
  name: string;
  description: string | null;
  is_system_role: boolean;
  company_id: string | null;
  created_at: string;
  updated_at: string;
  permissions: string[];
  user_count: number;
}

export interface RoleFormData {
  id: string;
  name: string;
  description: string;
  permissions: string[];
}