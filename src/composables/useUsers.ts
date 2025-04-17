import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import type { CompanyUser } from '../lib/types';

export function useUsers() {
  const authStore = useAuthStore();
  const users = ref<CompanyUser[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const fetchUsers = async () => {
    if (!authStore.currentCompanyId) return;
    if (!authStore.hasPermission('users.view')) {
      error.value = 'You do not have permission to view users';
      return;
    }
    
    loading.value = true;
    error.value = null;

    try {
      const { data, error: fetchError } = await supabase
        .from('user_companies')
        .select(`
          user_id,
          users:user_id (
            id,
            email,
            profiles (
              full_name,
              avatar_url
            )
          ),
          user_roles (
            roles (
              name
            )
          )
        `)
        .eq('company_id', authStore.currentCompanyId);

      if (fetchError) throw fetchError;

      users.value = data.map(item => ({
        id: item.users.id,
        email: item.users.email,
        full_name: item.users.profiles[0]?.full_name,
        avatar_url: item.users.profiles[0]?.avatar_url,
        role: item.user_roles[0]?.roles.name || 'No Role',
        active: true
      }));
    } catch (err: any) {
      error.value = err.message;
      users.value = [];
    } finally {
      loading.value = false;
    }
  };

  const deleteUser = async (userId: string) => {
    if (!authStore.hasPermission('users.delete')) {
      error.value = 'You do not have permission to delete users';
      return;
    }

    if (!confirm('Are you sure you want to delete this user?')) return;

    loading.value = true;
    error.value = null;

    try {
      const { error: deleteError } = await supabase.auth.admin.deleteUser(userId);
      if (deleteError) throw deleteError;
      await fetchUsers();
    } catch (err: any) {
      error.value = err.message;
    } finally {
      loading.value = false;
    }
  };

  return {
    users,
    loading,
    error,
    fetchUsers,
    deleteUser
  };
}