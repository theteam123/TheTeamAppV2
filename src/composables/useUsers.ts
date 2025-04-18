import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import type { User, Profile, UserRole } from '../lib/types';

interface Role {
  name: string;
}

interface RoleData {
  user_id: string;
  role_id: string;
  roles: {
    name: string;
  };
}

interface UserCompany {
  user_id: string;
  company_id: string;
  status: 'active' | 'inactive' | 'pending' | 'invited';
  profiles: Profile;
  user_roles: UserRole[];
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

      // First fetch users with their profiles and status
      const { data: userData, error: userError } = await supabase
        .from('user_companies')
        .select(`
          user_id,
          status,
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

      // Transform the data to match User interface
      users.value = userData.map(user => ({
        id: user.user_id,
        full_name: user.profiles.full_name,
        email: user.profiles.email,
        avatar_url: user.profiles.avatar_url,
        created_at: user.profiles.created_at,
        role: roleMap.get(user.user_id) || 'user',
        status: user.status
      }))

    } catch (err) {
      console.error('Error fetching users:', err)
      error.value = err instanceof Error ? err.message : 'Failed to fetch users'
      users.value = []
    } finally {
      loading.value = false
    }
  }

  const toggleUserStatus = async (user: User) => {
    if (!authStore.hasPermission('users.edit')) {
      throw new Error('You do not have permission to edit users')
    }

    try {
      const { error: updateError } = await supabase
        .from('user_companies')
        .update({ 
          status: user.status === 'active' ? 'inactive' : 'active',
          updated_at: new Date().toISOString()
        })
        .eq('user_id', user.id)
        .eq('company_id', authStore.currentCompanyId)

      if (updateError) throw updateError
      await fetchUsers()
    } catch (err) {
      console.error('Error toggling user status:', err)
      throw err
    }
  }

  const deleteUser = async (userId: string) => {
    if (!authStore.hasPermission('users.delete')) {
      throw new Error('You do not have permission to delete users')
    }

    try {
      const { error: deleteError } = await supabase
        .from('user_companies')
        .delete()
        .eq('user_id', userId)
        .eq('company_id', authStore.currentCompanyId)

      if (deleteError) throw deleteError
      await fetchUsers()
    } catch (err) {
      console.error('Error deleting user:', err)
      throw err
    }
  }

  return {
    users,
    loading,
    error,
    fetchUsers,
    toggleUserStatus,
    deleteUser
  }
}