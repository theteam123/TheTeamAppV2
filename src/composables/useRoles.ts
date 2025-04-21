import { ref } from 'vue';
import { supabase } from '../lib/supabase';
import { useAuthStore } from '../stores/auth';

interface Role {
  id: string;
  name: string;
  description: string;
  is_system_role: boolean;
  is_protected: boolean;
  permissions: string[];
}

interface RoleFormData {
  name: string;
  description: string;
  company_id: string;
  permissions: string[];
}

interface RolePermission {
  role_id: string;
  permission_key: string;
}

export function useRoles() {
  const authStore = useAuthStore();
  const roles = ref<Role[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  async function fetchRoles() {
    loading.value = true;
    error.value = null;
    try {
      const { data: rolesData, error: rolesError } = await supabase
        .from('roles')
        .select(`
          *,
          role_permissions (
            permission_key
          )
        `)
        .eq('company_id', authStore.currentCompanyId);

      if (rolesError) throw rolesError;

      roles.value = rolesData.map(role => ({
        id: role.id,
        name: role.name,
        description: role.description,
        is_system_role: role.is_system_role,
        is_protected: role.is_protected,
        permissions: role.role_permissions.map((rp: RolePermission) => rp.permission_key)
      }));
    } catch (err) {
      console.error('[Roles] Error fetching roles:', err);
      error.value = err instanceof Error ? err.message : 'An unknown error occurred';
      roles.value = [];
    } finally {
      loading.value = false;
    }
  }

  async function createRole(formData: RoleFormData) {
    loading.value = true;
    error.value = null;
    try {
      const { data: role, error: roleError } = await supabase
        .from('roles')
        .insert({
          name: formData.name,
          description: formData.description,
          company_id: formData.company_id,
          is_system_role: false,
          is_protected: false
        })
        .select()
        .single();

      if (roleError) throw roleError;

      if (formData.permissions.length > 0) {
        const permissionData = formData.permissions.map(permission_key => ({
          role_id: role.id,
          permission_key
        }));

        const { error: permissionError } = await supabase
          .from('role_permissions')
          .insert(permissionData);

        if (permissionError) throw permissionError;
      }

      await fetchRoles();
      return role;
    } catch (err) {
      console.error('[Roles] Error creating role:', err);
      error.value = err instanceof Error ? err.message : 'An unknown error occurred';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  async function updateRole(roleId: string, formData: RoleFormData) {
    loading.value = true;
    error.value = null;
    try {
      // Check if role is protected
      const role = roles.value.find(r => r.id === roleId);
      if (role?.is_protected) {
        throw new Error('Cannot modify protected roles');
      }

      const { error: roleError } = await supabase
        .from('roles')
        .update({
          name: formData.name,
          description: formData.description
        })
        .eq('id', roleId);

      if (roleError) throw roleError;

      if (formData.permissions.length > 0) {
        const { error: deleteError } = await supabase
          .from('role_permissions')
          .delete()
          .eq('role_id', roleId);

        if (deleteError) throw deleteError;

        const permissionData = formData.permissions.map(permission_key => ({
          role_id: roleId,
          permission_key
        }));

        const { error: insertError } = await supabase
          .from('role_permissions')
          .insert(permissionData);

        if (insertError) throw insertError;
      }

      await fetchRoles();
      return true;
    } catch (err) {
      console.error('[Roles] Error updating role:', err);
      error.value = err instanceof Error ? err.message : 'An unknown error occurred';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  const deleteRole = async (id: string) => {
    if (!authStore.hasPermission('roles.delete')) {
      throw new Error('You do not have permission to delete roles');
    }

    // Check if role is protected
    const role = roles.value.find(r => r.id === id);
    if (role?.is_protected) {
      throw new Error('Cannot delete protected roles');
    }

    loading.value = true;
    try {
      const { error: err } = await supabase
        .from('roles')
        .delete()
        .eq('id', id);

      if (err) throw err;
      await fetchRoles();
      return true;
    } catch (err: any) {
      console.error('Error deleting role:', err);
      error.value = err.message;
      throw err;
    } finally {
      loading.value = false;
    }
  };

  return {
    roles,
    loading,
    error,
    fetchRoles,
    createRole,
    updateRole,
    deleteRole
  };
}