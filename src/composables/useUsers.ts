import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';

interface UserProfile {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  created_at: string;
}

interface UserCompany {
  user_id: string;
  status: 'active' | 'inactive' | 'pending' | 'invited';
  profiles: UserProfile;
}

interface UserRole {
  name: string;
  user_roles: { user_id: string }[];
}

interface ExtendedUser {
  id: string;
  full_name: string;
  email: string;
  avatar_url: string | null;
  status: 'active' | 'inactive' | 'pending' | 'invited';
  created_at: string;
  role: string;
}

export function useUsers() {
  const users = ref<ExtendedUser[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);
  const authStore = useAuthStore();

  const fetchUsers = async () => {
    loading.value = true;
    error.value = null;

    try {
      // First get the user_companies for the current company
      const { data, error: userCompaniesError } = await supabase
        .from('user_companies')
        .select(`
          user_id,
          status,
          profiles!inner(
            id,
            full_name,
            email,
            avatar_url,
            created_at
          )
        `)
        .eq('company_id', authStore.currentCompanyId);

      if (userCompaniesError) throw userCompaniesError;
      
      const userCompanies = data as unknown as UserCompany[];

      // Then get the roles for these users
      const userIds = userCompanies.map(uc => uc.user_id);
      const { data: roleData, error: userRolesError } = await supabase
        .from('roles')
        .select(`
          name,
          user_roles!inner(user_id)
        `)
        .in('user_roles.user_id', userIds)
        .eq('user_roles.company_id', authStore.currentCompanyId);

      if (userRolesError) throw userRolesError;
      
      const userRoles = roleData as unknown as UserRole[];

      // Combine the data
      users.value = userCompanies.map(uc => ({
        id: uc.profiles.id,
        full_name: uc.profiles.full_name,
        email: uc.profiles.email,
        avatar_url: uc.profiles.avatar_url,
        status: uc.status,
        created_at: uc.profiles.created_at,
        role: userRoles.find(ur => ur.user_roles.some(r => r.user_id === uc.user_id))?.name || 'No Role'
      }));

    } catch (err) {
      console.error('Error fetching users:', err);
      error.value = err instanceof Error ? err.message : 'Failed to fetch users';
    } finally {
      loading.value = false;
    }
  };

  const toggleUserStatus = async (user: ExtendedUser) => {
    if (!authStore.hasPermission('users.edit') && !authStore.hasPermission('company.users.edit')) {
      throw new Error('You do not have permission to edit users');
    }

    try {
      const newStatus = user.status === 'active' ? 'inactive' : 'active';
      const { error: updateError } = await supabase
        .from('user_companies')
        .update({ status: newStatus })
        .eq('user_id', user.id)
        .eq('company_id', authStore.currentCompanyId);

      if (updateError) throw updateError;
      user.status = newStatus;
      await fetchUsers();
    } catch (err) {
      console.error('Error toggling user status:', err);
      throw err;
    }
  };

  const deleteUser = async (userId: string) => {
    if (!authStore.hasPermission('users.delete') && !authStore.hasPermission('company.users.delete')) {
      throw new Error('You do not have permission to delete users');
    }

    try {
      const { error: deleteError } = await supabase
        .from('user_companies')
        .delete()
        .eq('user_id', userId)
        .eq('company_id', authStore.currentCompanyId);

      if (deleteError) throw deleteError;
      await fetchUsers();
    } catch (err) {
      console.error('Error deleting user:', err);
      throw err;
    }
  };

  return {
    users,
    loading,
    error,
    fetchUsers,
    toggleUserStatus,
    deleteUser
  };
}