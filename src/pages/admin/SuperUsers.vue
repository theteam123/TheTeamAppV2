<template>
  <div class="p-6">
    <header class="mb-8">
      <h1 class="text-2xl font-semibold text-gray-900">Super User Management</h1>
      <p class="mt-2 text-sm text-gray-600">
        Manage users with system-wide administrative privileges
      </p>
    </header>

    <!-- User List -->
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
        <h3 class="text-lg leading-6 font-medium text-gray-900">Super Users</h3>
        <button
          @click="showAddUserModal = true"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
        >
          <UserPlusIcon class="h-5 w-5 mr-2" />
          Add Super User
        </button>
      </div>
      <div class="border-t border-gray-200">
        <ul role="list" class="divide-y divide-gray-200">
          <li v-for="user in superUsers" :key="user.id" class="px-4 py-4 sm:px-6">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <img
                    v-if="user.avatar_url"
                    :src="user.avatar_url"
                    :alt="user.full_name"
                    class="h-10 w-10 rounded-full"
                  />
                  <div v-else class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                    <UserIcon class="h-6 w-6 text-gray-500" />
                  </div>
                </div>
                <div class="ml-4">
                  <div class="text-sm font-medium text-gray-900">
                    {{ user.full_name }}
                  </div>
                  <div class="text-sm text-gray-500">
                    {{ user.email }}
                  </div>
                </div>
              </div>
              <button
                @click="confirmRemove(user)"
                class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200"
              >
                Remove
              </button>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <!-- Add Super User Modal -->
    <Modal
      v-if="showAddUserModal"
      title="Add Super User"
      @close="closeAddModal"
    >
      <form @submit.prevent="addSuperUser" class="space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700">
            User Email
          </label>
          <div class="mt-1">
            <input
              type="email"
              id="email"
              v-model="userEmail"
              required
              class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"
              placeholder="user@example.com"
            />
          </div>
        </div>
        <div class="flex justify-end space-x-3">
          <button
            type="button"
            @click="closeAddModal"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700"
          >
            Add User
          </button>
        </div>
      </form>
    </Modal>

    <!-- Remove Confirmation Modal -->
    <Modal
      v-if="showRemoveModal"
      title="Remove Super User"
      @close="closeRemoveModal"
    >
      <div class="space-y-4">
        <p class="text-sm text-gray-500">
          Are you sure you want to remove super user privileges from {{ userToRemove?.full_name }}?
        </p>
        <div class="flex justify-end space-x-3">
          <button
            @click="closeRemoveModal"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            @click="removeSuperUser"
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md shadow-sm hover:bg-red-700"
          >
            Remove
          </button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import {
  UserIcon,
  UserPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  ShieldIcon
} from 'lucide-vue-next';
import Modal from '../../components/Modal.vue';
import { useToast } from '../../composables/useToast';
import type { Profile } from '../../lib/types';

const { showToast } = useToast();
const superUsers = ref<Profile[]>([]);
const showAddUserModal = ref(false);
const showRemoveModal = ref(false);
const userToRemove = ref<Profile | null>(null);
const userEmail = ref('');

onMounted(async () => {
  await fetchSuperUsers();
});

async function fetchSuperUsers() {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('can_manage_companies', true)
      .order('full_name');

    if (error) throw error;
    superUsers.value = data;
  } catch (error) {
    console.error('Error fetching super users:', error);
    showToast('Error fetching super users', 'error');
  }
}

async function addSuperUser() {
  try {
    // First find the user by email
    const { data: users, error: userError } = await supabase
      .from('profiles')
      .select('*')
      .eq('email', userEmail.value)
      .single();

    if (userError) throw userError;
    if (!users) {
      showToast('User not found', 'error');
      return;
    }

    // Update the user's profile to grant super user privileges
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ can_manage_companies: true })
      .eq('id', users.id);

    if (updateError) throw updateError;

    showToast('Super user added successfully', 'success');
    await fetchSuperUsers();
    closeAddModal();
  } catch (error) {
    console.error('Error adding super user:', error);
    showToast('Error adding super user', 'error');
  }
}

function confirmRemove(user: Profile) {
  userToRemove.value = user;
  showRemoveModal.value = true;
}

async function removeSuperUser() {
  if (!userToRemove.value) return;

  try {
    const { error } = await supabase
      .from('profiles')
      .update({ can_manage_companies: false })
      .eq('id', userToRemove.value.id);

    if (error) throw error;

    showToast('Super user removed successfully', 'success');
    await fetchSuperUsers();
    closeRemoveModal();
  } catch (error) {
    console.error('Error removing super user:', error);
    showToast('Error removing super user', 'error');
  }
}

function closeAddModal() {
  showAddUserModal.value = false;
  userEmail.value = '';
}

function closeRemoveModal() {
  showRemoveModal.value = false;
  userToRemove.value = null;
}
</script> 