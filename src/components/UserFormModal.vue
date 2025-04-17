<template>
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
    <div class="bg-white rounded-lg p-6 max-w-md w-full">
      <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit User' : 'Create New User' }}</h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label for="user-full-name" class="block text-sm font-medium text-gray-700">Full Name</label>
          <input
            id="user-full-name"
            type="text"
            v-model="formData.full_name"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            required
          />
        </div>
        <div>
          <label for="user-email" class="block text-sm font-medium text-gray-700">Email</label>
          <input
            id="user-email"
            type="email"
            v-model="formData.email"
            :disabled="isEditing"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            required
          />
        </div>
        <div>
          <label for="user-role" class="block text-sm font-medium text-gray-700">Role</label>
          <select
            id="user-role"
            v-model="formData.role_id"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            required
          >
            <option v-for="role in roles" :key="role.id" :value="role.id">
              {{ role.name }}
            </option>
          </select>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700"
            :disabled="loading"
          >
            {{ isEditing ? 'Update' : 'Create' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import type { Role } from '../lib/types';

const props = defineProps<{
  isEditing: boolean;
  userData: any;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'submit'): void;
}>();

const authStore = useAuthStore();
const loading = ref(false);
const roles = ref<Role[]>([]);
const formData = ref({
  full_name: props.userData?.full_name || '',
  email: props.userData?.email || '',
  role_id: props.userData?.role_id || ''
});

const fetchRoles = async () => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('id, name');

    if (error) throw error;
    roles.value = data;
  } catch (err) {
    console.error('Error fetching roles:', err);
  }
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    if (props.isEditing) {
      // Update user logic
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ full_name: formData.value.full_name })
        .eq('id', props.userData.id);

      if (updateError) throw updateError;

      // Update role
      const { error: roleError } = await supabase
        .from('user_roles')
        .update({ role_id: formData.value.role_id })
        .eq('user_id', props.userData.id)
        .eq('company_id', authStore.currentCompanyId);

      if (roleError) throw roleError;
    } else {
      // Create user logic
      const { data: userData, error: userError } = await supabase.auth.admin.createUser({
        email: formData.value.email,
        password: Math.random().toString(36).slice(-8), // Generate random password
        email_confirm: true
      });

      if (userError) throw userError;

      // Create profile
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: userData.user.id,
          full_name: formData.value.full_name
        });

      if (profileError) throw profileError;

      // Add to company
      const { error: companyError } = await supabase
        .from('user_companies')
        .insert({
          user_id: userData.user.id,
          company_id: authStore.currentCompanyId
        });

      if (companyError) throw companyError;

      // Assign role
      const { error: roleError } = await supabase
        .from('user_roles')
        .insert({
          user_id: userData.user.id,
          role_id: formData.value.role_id,
          company_id: authStore.currentCompanyId
        });

      if (roleError) throw roleError;
    }

    emit('submit');
  } catch (err) {
    console.error('Error submitting form:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchRoles);
</script>