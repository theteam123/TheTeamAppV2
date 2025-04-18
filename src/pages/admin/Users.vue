<template>
  <div class="p-8">
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
    </div>

    <!-- No Company Selected State -->
    <div v-else-if="!authStore.currentCompanyId" class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400">
        <BuildingIcon class="h-12 w-12" />
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No company selected</h3>
      <p class="mt-1 text-sm text-gray-500">Please select a company to view its users.</p>
    </div>

    <!-- Users Table -->
    <div v-else-if="users.length > 0" class="bg-white rounded-lg shadow overflow-hidden">
      <!-- Search and Filter Bar -->
      <div class="p-4 border-b border-gray-200">
        <div class="flex flex-col sm:flex-row gap-4">
          <div class="flex-1">
            <div class="relative">
              <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                v-model="searchQuery"
                placeholder="Search users..."
                class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
              />
            </div>
          </div>
          <div class="flex gap-4">
            <select
              v-model="statusFilter"
              class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
            <select
              v-model="roleFilter"
              class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
            >
              <option value="all">All Roles</option>
              <option v-for="role in availableRoles" :key="role.id" :value="role.id">
                {{ role.name }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Login</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="user in filteredUsers" :key="user.id">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="h-10 w-10 flex-shrink-0">
                  <img
                    :src="user.avatar_url || 'https://www.gravatar.com/avatar/?d=mp'"
                    class="h-10 w-10 rounded-full"
                    alt=""
                  />
                </div>
                <div class="ml-4">
                  <div class="text-sm font-medium text-gray-900">{{ user.full_name }}</div>
                  <div class="text-sm text-gray-500">{{ user.email }}</div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                {{ user.role }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="user.active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'"
              >
                {{ user.active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ user.last_login ? formatDate(user.last_login) : 'Never' }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(user.created_at) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              <button
                @click="editUser(user)"
                v-if="authStore.hasPermission('users.edit')"
                class="text-green-600 hover:text-green-900 mr-3"
                title="Edit User"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="toggleUserStatus(user)"
                v-if="authStore.hasPermission('users.edit')"
                class="text-blue-600 hover:text-blue-900 mr-3"
                :title="user.active ? 'Deactivate User' : 'Activate User'"
              >
                <PowerIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteUser(user.id)"
                v-if="authStore.hasPermission('users.delete')"
                class="text-red-600 hover:text-red-900"
                title="Delete User"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400">
        <UsersIcon class="h-12 w-12" />
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No users</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by adding a new user to your organization.</p>
      <div class="mt-6">
        <button
          @click="openCreateUserModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
        >
          <UserPlusIcon class="w-5 h-5 mr-2" />
          Add User
        </button>
      </div>
    </div>

    <!-- Create/Edit User Modal -->
    <UserFormModal
      v-if="showModal"
      :isEditing="isEditing"
      :userData="selectedUser"
      @close="closeModal"
      @submit="handleSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useUsers } from '../../composables/useUsers';
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import type { CompanyUser } from '../../lib/types';
import {
  UserIcon,
  UserPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  XIcon,
  UsersIcon,
  BuildingIcon,
  SearchIcon,
  PowerIcon
} from 'lucide-vue-next';
import UserFormModal from '../../components/UserFormModal.vue';
import { format } from 'date-fns';

const authStore = useAuthStore();
const { users, loading, error, fetchUsers, deleteUser } = useUsers();
const showModal = ref(false);
const isEditing = ref(false);
const selectedUser = ref<CompanyUser | null>(null);
const searchQuery = ref('');
const statusFilter = ref('all');
const roleFilter = ref('all');
const availableRoles = ref([]);

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy');
};

const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const matchesSearch = searchQuery.value === '' || 
      user.full_name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.value.toLowerCase());
    
    const matchesStatus = statusFilter.value === 'all' || 
      (statusFilter.value === 'active' && user.active) ||
      (statusFilter.value === 'inactive' && !user.active);
    
    const matchesRole = roleFilter.value === 'all' || 
      user.role_id === roleFilter.value;
    
    return matchesSearch && matchesStatus && matchesRole;
  });
});

const toggleUserStatus = async (user: CompanyUser) => {
  if (!authStore.hasPermission('users.edit')) {
    alert('You do not have permission to edit users');
    return;
  }

  try {
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ 
        active: !user.active,
        updated_at: new Date().toISOString()
      })
      .eq('id', user.id);

    if (updateError) throw updateError;
    await fetchUsers();
  } catch (err) {
    console.error('Error toggling user status:', err);
    alert('Failed to update user status');
  }
};

const fetchRoles = async () => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('id, name')
      .order('name');

    if (error) throw error;
    availableRoles.value = data;
  } catch (err) {
    console.error('Error fetching roles:', err);
  }
};

const openCreateUserModal = () => {
  if (!authStore.hasPermission('users.create')) {
    alert('You do not have permission to create users');
    return;
  }
  isEditing.value = false;
  selectedUser.value = null;
  showModal.value = true;
};

const editUser = (user: CompanyUser) => {
  if (!authStore.hasPermission('users.edit')) {
    alert('You do not have permission to edit users');
    return;
  }
  isEditing.value = true;
  selectedUser.value = user;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedUser.value = null;
};

const handleSubmit = async () => {
  await fetchUsers();
  closeModal();
};

onMounted(async () => {
  if (authStore.hasPermission('users.view')) {
    await Promise.all([fetchUsers(), fetchRoles()]);
  } else {
    error.value = 'You do not have permission to view users';
  }
});
</script>