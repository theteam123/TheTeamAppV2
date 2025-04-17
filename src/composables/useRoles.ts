import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import type { Role, RoleFormData } from '../lib/types';

export function useRoles() {
  const authStore = useAuthStore();
  const roles = ref<Role[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const fetchRoles = async () => {
    if (!authStore.currentCompanyId) {
      error.value = 'No company selected';
      return;
    }

    loading.value = true;
    try {
      const { data, error: rolesError } = await supabase
        .from('roles')
        .select(`
          *,
          role_permissions (
            permission_key
          ),
          user_roles (
            count
          )
        `)
        .eq('company_id', authStore.currentCompanyId);

      if (rolesError) throw rolesError;

      roles.value = data.map(role => ({
        ...role,
        permissions: role.role_permissions.map(rp => rp.permission_key),
        user_count: role.user_roles[0]?.count || 0
      }));
    } catch (err: any) {
      console.error('Error fetching roles:', err);
      error.value = err.message;
      roles.value = [];
    } finally {
      loading.value = false;
    }
  };

  const createRole = async (formData: RoleFormData) => {
    if (!authStore.hasPermission('roles.create')) {
      throw new Error('You do not have permission to create roles');
    }

    loading.value = true;
    try {
      const roleData = {
        name: formData.name,
        description: formData.description,
        is_system_role: false,
        company_id: authStore.currentCompanyId
      };

      const { data: newRole, error: insertError } = await supabase
        .from('roles')
        .insert(roleData)
        .select()
        .single();

      if (insertError) throw insertError;

      if (formData.permissions.length > 0) {
        const permissionData = formData.permissions.map(permission_key => ({
          role_id: newRole.id,
          permission_key
        }));

        const { error: permissionError } = await supabase
          .from('role_permissions')
          .insert(permissionData);

        if (permissionError) throw permissionError;
      }

      await fetchRoles();
      return newRole;
    } catch (err: any) {
      console.error('Error creating role:', err);
      error.value = err.message;
      throw err;
    } finally {
      loading.value = false;
    }
  };

  const updateRole = async (id: string, formData: RoleFormData) => {
    if (!authStore.hasPermission('roles.edit')) {
      throw new Error('You do not have permission to edit roles');
    }

    loading.value = true;
    try {
      const roleData = {
        name: formData.name,
        description: formData.description
      };

      const { error: updateError } = await supabase
        .from('roles')
        .update(roleData)
        .eq('id', id);

      if (updateError) throw updateError;

      // Delete existing permissions
      const { error: deleteError } = await supabase
        .from('role_permissions')
        .delete()
        .eq('role_id', id);

      if (deleteError) throw deleteError;

      // Insert new permissions
      if (formData.permissions.length > 0) {
        const permissionData = formData.permissions.map(permission_key => ({
          role_id: id,
          permission_key
        }));

        const { error: permissionError } = await supabase
          .from('role_permissions')
          .insert(permissionData);

        if (permissionError) throw permissionError;
      }

      await fetchRoles();
      return true;
    } catch (err: any) {
      console.error('Error updating role:', err);
      error.value = err.message;
      throw err;
    } finally {
      loading.value = false;
    }
  };

  const deleteRole = async (id: string) => {
    if (!authStore.hasPermission('roles.delete')) {
      throw new Error('You do not have permission to delete roles');
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