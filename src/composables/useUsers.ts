import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';

interface Profile {
  id: string;
  full_name: string;
  email: string;
  avatar_url?: string;
  created_at: string;
}

interface Role {
  name: string;
}

interface UserRole {
  role_id: string;
  roles: Role;
}

interface UserCompany {
  user_id: string;
  company_id: string;
  profiles: Profile;
  user_roles: UserRole[];
}

interface User {
  id: string;
  full_name: string;
  email: string;
  avatar_url?: string;
  created_at: string;
  role: string;
}

interface RoleData {
  user_id: string;
  role_id: string;
  roles: {
    name: string;
  };
}

export const useUsers = () => {
  const authStore = useAuthStore()
  const users = ref<User[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const fetchUsers = async () => {
    try {
      loading.value = true
      error.value = null

      // Check if we have a valid company ID
      if (!authStore.currentCompanyId) {
        throw new Error('No company selected')
      }

      // First fetch users with their profiles
      const { data: userData, error: userError } = await supabase
        .from('user_companies')
        .select(`
          user_id,
          profiles!inner (
            id,
            full_name,
            email,
            avatar_url,
            created_at
          )
        `)
        .eq('company_id', authStore.currentCompanyId)

      if (userError) {
        throw userError
      }

      if (!userData) {
        users.value = []
        return
      }

      // Then fetch roles for these users
      const userIds = userData.map(user => user.user_id)
      const { data: roleData, error: roleError } = await supabase
        .from('user_roles')
        .select(`
          user_id,
          role_id,
          roles (
            name
          )
        `)
        .in('user_id', userIds)
        .eq('company_id', authStore.currentCompanyId)

      if (roleError) {
        throw roleError
      }

      // Create a map of user_id to role name
      const roleMap = new Map()
      if (roleData) {
        const typedRoleData = roleData as unknown as RoleData[]
        typedRoleData.forEach(role => {
          roleMap.set(role.user_id, role.roles?.name || 'user')
        })
      }

      // Map the data to our User type
      const mappedUsers = (userData as unknown as UserCompany[]).map((item: UserCompany) => ({
        id: item.user_id,
        full_name: item.profiles.full_name,
        email: item.profiles.email,
        avatar_url: item.profiles.avatar_url,
        created_at: item.profiles.created_at,
        role: roleMap.get(item.user_id) || 'user'
      }))

      users.value = mappedUsers

    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to fetch users'
      console.error('Error fetching users:', err)
    } finally {
      loading.value = false
    }
  }

  const deleteUser = async (userId: string) => {
    if (!authStore.currentCompanyId) {
      error.value = 'No company selected';
      return;
    }

    if (!authStore.hasPermission('users.delete')) {
      error.value = 'You do not have permission to delete users';
      return;
    }

    if (!confirm('Are you sure you want to delete this user?')) return;

    loading.value = true;
    error.value = null;

    try {
      const { data: userCompany, error: checkError } = await supabase
        .from('user_companies')
        .select('user_id')
        .eq('user_id', userId)
        .eq('company_id', authStore.currentCompanyId)
        .single();

      if (checkError) throw checkError;
      if (!userCompany) {
        throw new Error('User not found in current company');
      }

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