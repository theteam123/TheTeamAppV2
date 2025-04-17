<template>
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
    <div class="bg-white rounded-lg p-6 max-w-2xl w-full">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold text-gray-900">
          {{ isEditing ? 'Edit Content' : 'Add Content' }}
        </h2>
        <button
          @click="$emit('close')"
          class="text-gray-400 hover:text-gray-500"
        >
          <XIcon class="w-6 h-6" />
        </button>
      </div>

      <!-- Error Display -->
      <div v-if="error" class="mb-4 bg-red-50 text-red-600 p-4 rounded-lg">
        {{ error }}
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Content Name -->
        <div>
          <label for="content-name" class="block text-sm font-medium text-gray-700">
            Content Name <span class="text-red-500">*</span>
          </label>
          <input
            id="content-name"
            type="text"
            v-model="formData.name"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>

        <!-- URL -->
        <div>
          <label for="content-url" class="block text-sm font-medium text-gray-700">
            URL <span class="text-red-500">*</span>
          </label>
          <input
            id="content-url"
            type="url"
            v-model="formData.url"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>

        <!-- Description -->
        <div>
          <label for="content-description" class="block text-sm font-medium text-gray-700">
            Description
          </label>
          <textarea
            id="content-description"
            v-model="formData.description"
            rows="3"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          ></textarea>
        </div>

        <!-- Content Type -->
        <div>
          <label for="content-type" class="block text-sm font-medium text-gray-700">
            Content Type <span class="text-red-500">*</span>
          </label>
          <select
            id="content-type"
            v-model="formData.contentType"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            <option value="">Select a type</option>
            <option v-for="type in contentTypes" :key="type" :value="type">
              {{ type }}
            </option>
          </select>
        </div>

        <!-- Tags -->
        <div>
          <label class="block text-sm font-medium text-gray-700">Tags</label>
          <div class="mt-1">
            <div class="flex gap-2 mb-2">
              <div class="relative flex-1">
                <TagIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input
                  type="text"
                  v-model="newTag"
                  @keyup.enter="addTag"
                  placeholder="Add or search tags..."
                  class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:border-green-500 focus:ring-green-500"
                />
              </div>
              <button
                type="button"
                @click="addTag"
                class="px-3 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
              >
                <PlusIcon class="w-5 h-5" />
              </button>
            </div>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="tagId in formData.tags"
                :key="tagId"
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-sm font-medium bg-green-100 text-green-800"
              >
                {{ availableTags.find(t => t.id === tagId)?.name }}
                <button
                  type="button"
                  @click="removeTag(tagId)"
                  class="ml-1 text-green-600 hover:text-green-800"
                >
                  <XIcon class="w-4 h-4" />
                </button>
              </span>
            </div>
          </div>
        </div>

        <!-- Role Permissions -->
        <div v-if="roles.length > 0">
          <label class="block text-sm font-medium text-gray-700 mb-2">Role Permissions</label>
          <div class="border rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">View</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Edit</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="role in roles" :key="role.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {{ role.name }}
                    <span v-if="role.description" class="text-xs text-gray-500 block">
                      {{ role.description }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-center">
                    <input
                      type="checkbox"
                      :checked="getRolePermission(role.id, 'view')"
                      @change="updateRolePermission(role.id, 'view', $event.target.checked)"
                      class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded"
                    />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-center">
                    <input
                      type="checkbox"
                      :checked="getRolePermission(role.id, 'edit')"
                      @change="updateRolePermission(role.id, 'edit', $event.target.checked)"
                      class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="flex justify-end gap-3">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700 disabled:opacity-50"
          >
            {{ isEditing ? 'Update' : 'Create' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import { TagIcon, PlusIcon, XIcon } from 'lucide-vue-next';

interface Role {
  id: string;
  name: string;
  description?: string;
}

interface RolePermission {
  view: boolean;
  edit: boolean;
}

interface FormData {
  name: string;
  url: string;
  description: string;
  contentType: string;
  tags: string[];
  rolePermissions: Record<string, RolePermission>;
}

const props = defineProps<{
  isEditing: boolean;
  contentData?: any;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'submit', data: any): void;
}>();

const authStore = useAuthStore();
const loading = ref(false);
const error = ref<string | null>(null);
const roles = ref<Role[]>([]);
const availableTags = ref<any[]>([]);
const newTag = ref('');

const formData = ref<FormData>({
  name: props.contentData?.name || '',
  url: props.contentData?.url || '',
  description: props.contentData?.description || '',
  contentType: props.contentData?.contentType || '',
  tags: props.contentData?.tags || [],
  rolePermissions: {}
});

const contentTypes = [
  'Video',
  'Image',
  'Link',
  'Article',
  'Tutorial'
];

const getRolePermission = (roleId: string, type: 'view' | 'edit'): boolean => {
  return formData.value.rolePermissions[roleId]?.[type] || false;
};

const updateRolePermission = (roleId: string, type: 'view' | 'edit', value: boolean) => {
  if (!formData.value.rolePermissions[roleId]) {
    formData.value.rolePermissions[roleId] = { view: false, edit: false };
  }
  formData.value.rolePermissions[roleId][type] = value;
};

const fetchRoles = async () => {
  if (!authStore.currentCompanyId) {
    console.error('No company ID available');
    return;
  }

  try {
    // First, get the user's roles for the current company
    const { data: userRoles, error: userRolesError } = await supabase
      .from('user_roles')
      .select(`
        role_id,
        roles (
          id,
          name,
          description
        )
      `)
      .eq('company_id', authStore.currentCompanyId)
      .eq('user_id', authStore.user?.id);

    if (userRolesError) throw userRolesError;

    if (!userRoles || userRoles.length === 0) {
      console.warn('No roles found for user in company');
      roles.value = [];
      return;
    }

    // Extract and format roles from the join query
    roles.value = userRoles.map(ur => ({
      id: ur.roles.id,
      name: ur.roles.name,
      description: ur.roles.description
    }));

    // Initialize role permissions
    const initialPermissions: Record<string, RolePermission> = {};
    roles.value.forEach(role => {
      initialPermissions[role.id] = {
        view: props.contentData?.rolePermissions?.[role.id]?.view || false,
        edit: props.contentData?.rolePermissions?.[role.id]?.edit || false
      };
    });
    formData.value.rolePermissions = initialPermissions;

  } catch (err) {
    console.error('Error fetching roles:', err);
    error.value = 'Failed to load roles. Please try again.';
    roles.value = [];
  }
};

// Watch for company ID changes
watch(() => authStore.currentCompanyId, (newCompanyId) => {
  if (newCompanyId) {
    fetchRoles();
  }
});

const fetchTags = async () => {
  if (!authStore.currentCompanyId) return;

  try {
    const { data, error: fetchError } = await supabase
      .from('tags')
      .select('id, name')
      .eq('company_id', authStore.currentCompanyId)
      .order('name');

    if (fetchError) throw fetchError;
    availableTags.value = data || [];
  } catch (err) {
    console.error('Error fetching tags:', err);
    error.value = 'Failed to load tags. Please try again.';
  }
};

const addTag = async () => {
  if (!newTag.value.trim()) return;

  const existingTag = availableTags.value.find(
    tag => tag.name.toLowerCase() === newTag.value.toLowerCase()
  );

  if (existingTag) {
    if (!formData.value.tags.includes(existingTag.id)) {
      formData.value.tags.push(existingTag.id);
    }
  } else {
    try {
      const { data, error } = await supabase
        .from('tags')
        .insert({
          name: newTag.value,
          company_id: authStore.currentCompanyId
        })
        .select()
        .single();

      if (error) throw error;
      availableTags.value.push(data);
      formData.value.tags.push(data.id);
    } catch (err) {
      console.error('Error creating tag:', err);
      error.value = 'Failed to create tag. Please try again.';
    }
  }

  newTag.value = '';
};

const removeTag = (tagId: string) => {
  formData.value.tags = formData.value.tags.filter(id => id !== tagId);
};

const handleSubmit = async () => {
  loading.value = true;
  error.value = null;

  try {
    // Validate required fields
    if (!formData.value.name || !formData.value.url || !formData.value.contentType) {
      throw new Error('Please fill in all required fields');
    }

    const contentData = {
      name: formData.value.name,
      url: formData.value.url,
      description: formData.value.description,
      contentType: formData.value.contentType,
      tags: formData.value.tags,
      rolePermissions: formData.value.rolePermissions
    };

    emit('submit', contentData);
  } catch (err: any) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  if (authStore.currentCompanyId) {
    await Promise.all([fetchRoles(), fetchTags()]);
  }
});
</script>