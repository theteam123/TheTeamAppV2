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

    <!-- Users Table -->
    <div v-else-if="users.length > 0" class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="user in users" :key="user.id">
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
              <button
                @click="editUser(user)"
                v-if="authStore.hasPermission('users.edit')"
                class="text-green-600 hover:text-green-900 mr-3"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteUser(user.id)"
                v-if="authStore.hasPermission('users.delete')"
                class="text-red-600 hover:text-red-900"
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
import { ref, onMounted } from 'vue';
import { useUsers } from '../composables/useUsers';
import { useAuthStore } from '../stores/auth';
import type { CompanyUser } from '../lib/types';
import {
  UserPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  UsersIcon
} from 'lucide-vue-next';
import UserFormModal from '../components/UserFormModal.vue';

const authStore = useAuthStore();
const { users, loading, error, fetchUsers, deleteUser } = useUsers();
const showModal = ref(false);
const isEditing = ref(false);
const selectedUser = ref<CompanyUser | null>(null);

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

onMounted(() => {
  if (authStore.hasPermission('users.view')) {
    fetchUsers();
  } else {
    error.value = 'You do not have permission to view users';
  }
});
</script>