import { ref } from 'vue';
import { useAuthStore } from '@/stores/auth';

// Define valid permission keys
export type PermissionKey = 
  | 'manage_settings'
  | 'manage_content'
  | 'manage_users'
  | 'users.view'
  | 'users.create'
  | 'users.edit'
  | 'users.delete'
  | 'users.manage'
  | 'companies.view'
  | 'companies.edit'
  | 'roles.view'
  | 'roles.edit'
  | 'content.manage'
  | 'content.view'
  | 'content.create'
  | 'content.edit'
  | 'content.delete'

interface PermissionState {
  [key: string]: boolean;
}

export function usePermissions() {
  const permissionState = ref<PermissionState>({});
  const authStore = useAuthStore();

  /**
   * Check if the current user has a specific permission
   */
  const checkPermission = async (permission: PermissionKey): Promise<boolean> => {
    try {
      // Check if permission is already cached
      if (permission in permissionState.value) {
        return permissionState.value[permission];
      }

      // Fetch permission from authStore
      const hasPermission = await authStore.hasPermission(permission);
      permissionState.value[permission] = hasPermission;
      return hasPermission;
    } catch (error) {
      console.error(`Error checking permission ${permission}:`, error);
      return false;
    }
  };

  /**
   * Check if the current user has all of the specified permissions
   */
  const hasAllPermissions = async (permissions: PermissionKey[]): Promise<boolean> => {
    try {
      const results = await Promise.all(
        permissions.map(permission => checkPermission(permission))
      );
      return results.every(Boolean);
    } catch (error) {
      console.error('Error checking multiple permissions:', error);
      return false;
    }
  };

  /**
   * Check if the current user has any of the specified permissions
   */
  const hasAnyPermission = async (permissions: PermissionKey[]): Promise<boolean> => {
    try {
      const results = await Promise.all(
        permissions.map(permission => checkPermission(permission))
      );
      return results.some(Boolean);
    } catch (error) {
      console.error('Error checking multiple permissions:', error);
      return false;
    }
  };

  /**
   * Reset the permission cache
   */
  const resetPermissionCache = () => {
    permissionState.value = {};
  };

  /**
   * Get all cached permissions
   */
  const getCachedPermissions = (): Record<string, boolean> => {
    return { ...permissionState.value };
  };

  return {
    checkPermission,
    hasAllPermissions,
    hasAnyPermission,
    resetPermissionCache,
    getCachedPermissions,
    permissionState
  };
} 