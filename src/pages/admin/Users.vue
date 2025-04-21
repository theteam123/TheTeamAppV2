<template>
  <div class="p-8">
    <!-- Notifications -->
    <div class="fixed top-4 right-4 z-50 space-y-2">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        class="p-4 rounded-lg shadow-lg"
        :class="{
          'bg-green-100 text-green-800': notification.type === 'success',
          'bg-red-100 text-red-800': notification.type === 'error',
          'bg-yellow-100 text-yellow-800': notification.type === 'warning',
          'bg-blue-100 text-blue-800': notification.type === 'info'
        }"
      >
        {{ notification.message }}
        <button
          @click="removeNotification(notification.id!)"
          class="ml-4 text-sm underline hover:no-underline"
        >
          Dismiss
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex justify-center items-center py-8">
      <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
      <button 
        @click="fetchUsers" 
        class="ml-4 text-sm underline hover:no-underline"
      >
        Retry
      </button>
    </div>

    <!-- No Company Selected State -->
    <div v-else-if="!authStore.currentCompanyId" class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400">
        <BuildingIcon class="h-12 w-12" />
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No company selected</h3>
      <p class="mt-1 text-sm text-gray-500">Please select a company to view its users.</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <p class="text-sm text-gray-500 mb-6">Manage users and their roles within your organization</p>

      <!-- Users Table -->
      <div v-if="users.length > 0" class="bg-white rounded-lg shadow overflow-hidden">
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
                <option value="pending">Pending</option>
                <option value="invited">Invited</option>
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
              <button
                @click="() => handleCreateUser({})"
                v-if="hasCreatePermission"
                :disabled="isLoading"
                class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <UserPlusIcon class="w-5 h-5 mr-2" />
                {{ isLoading ? 'Adding...' : 'Add User' }}
              </button>
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
                  :class="{
                    'bg-green-100 text-green-800': user.status === 'active',
                    'bg-gray-100 text-gray-800': user.status === 'inactive',
                    'bg-yellow-100 text-yellow-800': user.status === 'pending',
                    'bg-blue-100 text-blue-800': user.status === 'invited'
                  }"
                >
                  {{ user.status }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ user.last_login ? formatDate(user.last_login) : 'Never' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(user.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div class="flex space-x-2">
                  <button
                    @click="() => handleEditUser(user)"
                    v-if="hasEditPermission"
                    :disabled="isLoading"
                    class="text-green-600 hover:text-green-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    :title="isLoading ? 'Processing...' : 'Edit User'"
                  >
                    <PencilIcon class="w-5 h-5" />
                  </button>

                  <button
                    @click="() => handleToggleStatus(user)"
                    v-if="hasEditPermission"
                    :disabled="isLoading"
                    class="text-blue-600 hover:text-blue-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    :title="isLoading ? 'Processing...' : (user.status === 'active' ? 'Deactivate User' : 'Activate User')"
                  >
                    <PowerIcon class="w-5 h-5" />
                  </button>

                  <button
                    @click="() => handleDeleteUser(user.id)"
                    v-if="hasDeletePermission"
                    :disabled="isLoading"
                    class="text-red-600 hover:text-red-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    :title="isLoading ? 'Processing...' : 'Delete User'"
                  >
                    <TrashIcon class="w-5 h-5" />
                  </button>

                  <button
                    @click="() => handleViewStatusHistory(user)"
                    v-if="hasViewPermission"
                    :disabled="isLoading"
                    class="text-gray-600 hover:text-gray-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    :title="isLoading ? 'Loading...' : 'View Status History'"
                  >
                    <HistoryIcon class="w-5 h-5" />
                  </button>
                </div>
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
            @click="() => handleCreateUser({})"
            v-if="hasCreatePermission"
            :disabled="isLoading"
            class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <UserPlusIcon class="w-5 h-5 mr-2" />
            {{ isLoading ? 'Adding...' : 'Add User' }}
          </button>
        </div>
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

    <!-- Status History Modal -->
    <StatusHistoryModal
      v-if="showStatusHistoryModal"
      :user="selectedUser"
      @close="closeStatusHistoryModal"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useUsers } from '../../composables/useUsers';
import { useAuthStore } from '../../stores/auth';
import { useNotification } from '../../composables/useNotification';
import { supabase } from '../../lib/supabase';
import type { User, Profile } from '../../lib/types';
import { PermissionKeys } from '../../lib/permissions';
import {
  UserPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  SearchIcon,
  BuildingIcon,
  UsersIcon,
  PowerIcon,
  HistoryIcon
} from 'lucide-vue-next';
import UserFormModal from '../../components/UserFormModal.vue';
import StatusHistoryModal from '../../components/admin/StatusHistoryModal.vue';
import { format } from 'date-fns';
import { usePermissions } from '../../composables/usePermissions';

interface ExtendedUser extends User {
  full_name: string;
  email: string;
  avatar_url: string;
  role: string;
  status: 'active' | 'inactive' | 'pending' | 'invited';
  last_login?: string;
  created_at: string;
}

const { users, loading, error, fetchUsers, toggleUserStatus, deleteUser } = useUsers();
const authStore = useAuthStore();
const { showNotification, notifications, removeNotification } = useNotification();
const { permissionState, checkPermission } = usePermissions();

// State
const searchQuery = ref('');
const statusFilter = ref('all');
const roleFilter = ref('all');
const availableRoles = ref<{ id: string; name: string; }[]>([]);
const isLoading = ref(false);
const showModal = ref(false);
const showStatusHistoryModal = ref(false);
const isEditing = ref(false);
const selectedUser = ref<ExtendedUser | null>(null);

// Initialize permissions
onMounted(async () => {
  await Promise.all([
    checkPermission('users.view'),
    checkPermission('users.create'),
    checkPermission('users.edit'),
    checkPermission('users.delete')
  ]);
});

// Permission computed properties
const hasCreatePermission = computed(() => permissionState.value['users.create'] || false);
const hasEditPermission = computed(() => permissionState.value['users.edit'] || false);
const hasDeletePermission = computed(() => permissionState.value['users.delete'] || false);
const hasViewPermission = computed(() => permissionState.value['users.view'] || false);

// Error handling utility
const handleError = (error: unknown): string => {
  console.error('Error details:', error);
  
  let errorMessage = 'An unexpected error occurred';
  
  if (error instanceof Error) {
    errorMessage = error.message;
  } else if (typeof error === 'string') {
    errorMessage = error;
  } else if (error && typeof error === 'object' && 'message' in error) {
    errorMessage = String(error.message);
  }
  
  showNotification('error', errorMessage);
  return errorMessage;
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString();
};

const filteredUsers = computed(() => {
  let filtered = users.value as ExtendedUser[];
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(user => 
      user.full_name.toLowerCase().includes(query) ||
      user.email.toLowerCase().includes(query)
    );
  }
  
  if (statusFilter.value !== 'all') {
    filtered = filtered.filter(user => user.status === statusFilter.value);
  }
  
  if (roleFilter.value !== 'all') {
    filtered = filtered.filter(user => user.role === roleFilter.value);
  }
  
  return filtered;
});

const fetchRoles = async () => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('id, name')
      .order('name');

    if (error) throw error;
    availableRoles.value = data;
  } catch (err) {
    handleError(err);
  }
};

const openCreateUserModal = () => {
  if (!authStore.hasPermission('users.create') && !authStore.hasPermission('company.users.create')) {
    alert('You do not have permission to create users');
    return;
  }
  isEditing.value = false;
  selectedUser.value = null;
  showModal.value = true;
};

const editUser = (user: ExtendedUser) => {
  if (!authStore.hasPermission('users.edit') && !authStore.hasPermission('company.users.edit')) {
    alert('You do not have permission to edit users');
    return;
  }
  isEditing.value = true;
  selectedUser.value = user;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  isEditing.value = false;
  selectedUser.value = null;
};

const handleSubmit = async () => {
  try {
    await fetchUsers();
    closeModal();
  } catch (err: unknown) {
    console.error('Error submitting form:', err);
    showNotification('error', 'Failed to submit form');
  }
};

const showStatusHistory = (user: ExtendedUser) => {
  selectedUser.value = user;
  showStatusHistoryModal.value = true;
};

const closeStatusHistoryModal = () => {
  showStatusHistoryModal.value = false;
  selectedUser.value = null;
};

const handleDeleteUser = async (userId: string) => {
  if (!confirm('Are you sure you want to remove this user from the company?')) return;
  
  try {
    await deleteUser(userId);
    showNotification('success', 'User removed from company successfully');
    await fetchUsers();
  } catch (err: unknown) {
    console.error('Error deleting user:', err);
    showNotification('error', 'Failed to delete user');
  }
};

const handleToggleStatus = async (user: ExtendedUser) => {
  try {
    await toggleUserStatus(user);
    showNotification('success', `User status updated to ${user.status === 'active' ? 'active' : 'inactive'}`);
    await fetchUsers();
  } catch (err: unknown) {
    console.error('Error toggling user status:', err);
    showNotification('error', 'Failed to update user status');
  }
};

const handleViewStatusHistory = async (user: ExtendedUser) => {
  try {
    const canView = hasViewPermission.value;
    if (!canView) {
      throw new Error('You do not have permission to view users');
    }
    showStatusHistoryModal.value = true;
    selectedUser.value = user;
  } catch (err: unknown) {
    console.error('Error viewing status history:', err);
    showNotification('error', 'Failed to view status history');
  }
};

const handleCreateUser = async (userData: Partial<ExtendedUser>) => {
  try {
    // TODO: Implement create user functionality
    showNotification('success', 'User created successfully');
    await fetchUsers();
  } catch (err: unknown) {
    console.error('Error creating user:', err);
    showNotification('error', 'Failed to create user');
  }
};

const handleEditUser = async (user: ExtendedUser) => {
  try {
    // TODO: Implement edit user functionality
    showNotification('success', 'User updated successfully');
    await fetchUsers();
  } catch (err: unknown) {
    console.error('Error updating user:', err);
    showNotification('error', 'Failed to update user');
  }
};

onMounted(async () => {
  isLoading.value = true;
  error.value = null;
  
  try {
    const canView = hasViewPermission.value;
    if (!canView) {
      throw new Error('You do not have permission to view users');
    }
    
    await Promise.all([
      fetchUsers().catch((err: unknown) => {
        throw new Error(`Error fetching users: ${err instanceof Error ? err.message : 'Unknown error'}`);
      }),
      fetchRoles().catch((err: unknown) => {
        throw new Error(`Error fetching roles: ${err instanceof Error ? err.message : 'Unknown error'}`);
      })
    ]);
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : 'An unknown error occurred';
    showNotification('error', error.value);
  } finally {
    isLoading.value = false;
  }
});
</script>