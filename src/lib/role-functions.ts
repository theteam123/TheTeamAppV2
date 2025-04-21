import { supabase } from './supabase';

// Type definitions
export type RoleName = string;
export type PermissionKey = string;

// Function to check if the current user has a specific role
export async function hasRole(roleName: RoleName): Promise<boolean> {
  const { data, error } = await supabase.rpc('has_role', { role_name: roleName });
  if (error) {
    console.error('Error checking role:', error);
    return false;
  }
  return data;
}

// Function to check if the current user has a specific permission
export async function hasPermission(permissionKey: PermissionKey): Promise<boolean> {
  const { data, error } = await supabase.rpc('has_permission', { permission_key: permissionKey });
  if (error) {
    console.error('Error checking permission:', error);
    return false;
  }
  return data;
}

// Function to check if the current user has a specific system role
export async function hasSystemRole(roleName: RoleName): Promise<boolean> {
  const { data, error } = await supabase.rpc('has_system_role', { role_name: roleName });
  if (error) {
    console.error('Error checking system role:', error);
    return false;
  }
  return data;
}

// Helper function to check multiple permissions
export async function hasAllPermissions(permissionKeys: PermissionKey[]): Promise<boolean> {
  const results = await Promise.all(permissionKeys.map(key => hasPermission(key)));
  return results.every(result => result);
}

// Helper function to check any of multiple permissions
export async function hasAnyPermission(permissionKeys: PermissionKey[]): Promise<boolean> {
  const results = await Promise.all(permissionKeys.map(key => hasPermission(key)));
  return results.some(result => result);
} 