<template>
  <div class="p-8">
    <!-- Header with Create Button -->
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Roles</h1>
        <p class="text-sm text-gray-500 mt-1">Manage user roles and permissions</p>
      </div>
      <button
        @click="openCreateRoleModal"
        class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
      >
        <ShieldPlusIcon class="w-5 h-5" />
        Create Role
      </button>
    </div>

    <!-- Search and Filter Bar -->
    <div class="mb-6 bg-white rounded-lg shadow p-4">
      <div class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1">
          <div class="relative">
            <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Search roles..."
              class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
            />
          </div>
        </div>
        <div class="flex gap-4">
          <select
            v-model="filterType"
            class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
          >
            <option value="all">All Roles</option>
            <option value="system">System Roles</option>
            <option value="custom">Custom Roles</option>
          </select>
          <select
            v-model="sortBy"
            class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
          >
            <option value="name">Name</option>
            <option value="created_at">Date Created</option>
            <option value="user_count">User Count</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
    </div>

    <!-- Roles Grid -->
    <div v-else-if="paginatedRoles.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="role in paginatedRoles"
        :key="role.id"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div>
              <div class="flex items-center gap-2">
                <h3 class="text-lg font-semibold text-gray-900">{{ role.name }}</h3>
                <span
                  v-if="role.is_system_role"
                  class="px-2 py-0.5 text-xs font-medium rounded-full bg-purple-100 text-purple-800"
                >
                  System
                </span>
              </div>
              <p class="text-sm text-gray-500 mt-1">{{ role.description }}</p>
            </div>
            <div class="flex gap-2">
              <button
                @click="editRole(role)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                v-if="!role.is_system_role"
                @click="deleteRole(role)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <h4 class="text-sm font-medium text-gray-700 mb-2">Permissions</h4>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="permission in role.permissions"
                :key="permission"
                class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800"
              >
                {{ formatPermission(permission) }}
              </span>
            </div>
          </div>

          <div class="mt-4 flex items-center gap-2 text-sm text-gray-600">
            <UsersIcon class="w-4 h-4" />
            <span>{{ role.user_count }} Users</span>
          </div>

          <div class="mt-2 text-sm text-gray-500">
            Created {{ formatDate(role.created_at) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <ShieldIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No roles found</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new role.</p>
      <div class="mt-6">
        <button
          @click="openCreateRoleModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <ShieldPlusIcon class="w-5 h-5 mr-2" />
          Create Role
        </button>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="mt-6 flex justify-center">
      <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
        <button
          @click="currentPage--"
          :disabled="currentPage === 1"
          class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
        >
          <span class="sr-only">Previous</span>
          <ChevronLeftIcon class="h-5 w-5" />
        </button>
        
        <button
          v-for="page in displayedPages"
          :key="page"
          @click="currentPage = page"
          :class="[
            page === currentPage
              ? 'z-10 bg-green-50 border-green-500 text-green-600'
              : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50',
            'relative inline-flex items-center px-4 py-2 border text-sm font-medium'
          ]"
        >
          {{ page }}
        </button>

        <button
          @click="currentPage++"
          :disabled="currentPage === totalPages"
          class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
        >
          <span class="sr-only">Next</span>
          <ChevronRightIcon class="h-5 w-5" />
        </button>
      </nav>
    </div>

    <!-- Create/Edit Role Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-2xl w-full">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Role' : 'Create New Role' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Role Name</label>
            <input
              type="text"
              v-model="formData.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              v-model="formData.description"
              rows="2"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Permissions</label>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div v-for="(group, category) in permissionGroups" :key="category" class="space-y-2">
                <h3 class="font-medium text-gray-900">{{ category }}</h3>
                <div class="space-y-2">
                  <label
                    v-for="permission in group"
                    :key="permission.key"
                    class="flex items-center space-x-3"
                  >
                    <input
                      type="checkbox"
                      :value="permission.key"
                      v-model="formData.permissions"
                      class="h-4 w-4 rounded border-gray-300 text-green-600 focus:ring-green-500"
                    />
                    <span class="text-sm text-gray-700">{{ permission.name }}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-3 mt-6">
            <button
              type="button"
              @click="showModal = false"
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import { format } from 'date-fns';
import {
  ShieldIcon,
  ShieldPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  UsersIcon,
  SearchIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
} from 'lucide-vue-next';

interface Role {
  id: string;
  name: string;
  description: string | null;
  is_system_role: boolean;
  created_at: string;
  permissions: string[];
  user_count: number;
}

const authStore = useAuthStore();
const loading = ref(false);
const error = ref<string | null>(null);
const roles = ref<Role[]>([]);
const showModal = ref(false);
const isEditing = ref(false);
const searchQuery = ref('');
const filterType = ref('all');
const sortBy = ref('name');
const currentPage = ref(1);
const pageSize = 9;

const formData = ref({
  id: '',
  name: '',
  description: '',
  permissions: [] as string[]
});

const permissionGroups = {
  'User Management': [
    { key: 'users.view', name: 'View Users' },
    { key: 'users.create', name: 'Create Users' },
    { key: 'users.edit', name: 'Edit Users' },
    { key: 'users.delete', name: 'Delete Users' }
  ],
  'Content Management': [
    { key: 'content.view', name: 'View Content' },
    { key: 'content.create', name: 'Create Content' },
    { key: 'content.edit', name: 'Edit Content' },
    { key: 'content.delete', name: 'Delete Content' }
  ],
  'Role Management': [
    { key: 'roles.view', name: 'View Roles' },
    { key: 'roles.create', name: 'Create Roles' },
    { key: 'roles.edit', name: 'Edit Roles' },
    { key: 'roles.delete', name: 'Delete Roles' }
  ]
};

// Computed properties for filtering and pagination
const filteredRoles = computed(() => {
  let filtered = [...roles.value];

  // Apply search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(role => 
      role.name.toLowerCase().includes(query) ||
      (role.description?.toLowerCase() || '').includes(query)
    );
  }

  // Apply type filter
  if (filterType.value !== 'all') {
    filtered = filtered.filter(role => 
      filterType.value === 'system' ? role.is_system_role : !role.is_system_role
    );
  }

  // Apply sorting
  filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'name':
        return a.name.localeCompare(b.name);
      case 'created_at':
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
      case 'user_count':
        return b.user_count - a.user_count;
      default:
        return 0;
    }
  });

  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredRoles.value.length / pageSize));

const paginatedRoles = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  const end = start + pageSize;
  return filteredRoles.value.slice(start, end);
});

const displayedPages = computed(() => {
  const total = totalPages.value;
  const current = currentPage.value;
  const pages = [];

  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    if (current <= 3) {
      for (let i = 1; i <= 5; i++) pages.push(i);
      pages.push('...');
      pages.push(total);
    } else if (current >= total - 2) {
      pages.push(1);
      pages.push('...');
      for (let i = total - 4; i <= total; i++) pages.push(i);
    } else {
      pages.push(1);
      pages.push('...');
      for (let i = current - 1; i <= current + 1; i++) pages.push(i);
      pages.push('...');
      pages.push(total);
    }
  }

  return pages;
});

// Methods
const fetchRoles = async () => {
  try {
    loading.value = true
    error.value = null

    if (!authStore.currentCompanyId) {
      throw new Error('No company selected')
    }

    const { data, error: fetchError } = await supabase
      .from('user_roles')
      .select(`
        role_id,
        count(*)
      `)
      .eq('company_id', authStore.currentCompanyId)
      .group('role_id')

    if (fetchError) {
      throw fetchError
    }

    if (!data) {
      roles.value = []
      return
    }

    // Map the data to include role details
    const roleIds = data.map(item => item.role_id)
    if (roleIds.length > 0) {
      const { data: roleData, error: roleError } = await supabase
        .from('roles')
        .select('*')
        .in('id', roleIds)

      if (roleError) {
        throw roleError
      }

      roles.value = roleData.map(role => ({
        ...role,
        user_count: data.find(item => item.role_id === role.id)?.count || 0
      }))
    } else {
      roles.value = []
    }

  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to fetch roles'
    console.error('Error fetching roles:', err)
  } finally {
    loading.value = false
  }
}

const openCreateRoleModal = () => {
  if (!authStore.hasPermission('roles.create')) {
    error.value = 'You do not have permission to create roles';
    return;
  }

  isEditing.value = false;
  formData.value = {
    id: '',
    name: '',
    description: '',
    permissions: []
  };
  showModal.value = true;
};

const editRole = (role: Role) => {
  if (!authStore.hasPermission('roles.edit')) {
    error.value = 'You do not have permission to edit roles';
    return;
  }

  isEditing.value = true;
  formData.value = {
    id: role.id,
    name: role.name,
    description: role.description || '',
    permissions: role.permissions
  };
  showModal.value = true;
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    const roleData = {
      name: formData.value.name,
      description: formData.value.description,
      is_system_role: false,
      company_id: authStore.currentCompanyId
    };

    let roleId;

    if (isEditing.value) {
      const { error: updateError } = await supabase
        .from('roles')
        .update(roleData)
        .eq('id', formData.value.id);

      if (updateError) throw updateError;
      roleId = formData.value.id;

      // Delete existing permissions
      const { error: deleteError } = await supabase
        .from('role_permissions')
        .delete()
        .eq('role_id', roleId);

      if (deleteError) throw deleteError;
    } else {
      const { data: newRole, error: insertError } = await supabase
        .from('roles')
        .insert(roleData)
        .select()
        .single();

      if (insertError) throw insertError;
      roleId = newRole.id;
    }

    // Insert new permissions
    if (formData.value.permissions.length > 0) {
      const permissionData = formData.value.permissions.map(permission_key => ({
        role_id: roleId,
        permission_key
      }));

      const { error: permissionError } = await supabase
        .from('role_permissions')
        .insert(permissionData);

      if (permissionError) throw permissionError;
    }

    showModal.value = false;
    await fetchRoles();
  } catch (err: any) {
    console.error('Error saving role:', err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteRole = async (role: Role) => {
  if (!authStore.hasPermission('roles.delete')) {
    error.value = 'You do not have permission to delete roles';
    return;
  }

  if (!confirm('Are you sure you want to delete this role? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('roles')
      .delete()
      .eq('id', role.id);

    if (err) throw err;
    await fetchRoles();
  } catch (err: any) {
    console.error('Error deleting role:', err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy');
};

const formatPermission = (permission: string) => {
  const [resource, action] = permission.split('.');
  return `${action.charAt(0).toUpperCase() + action.slice(1)} ${resource}`;
};

// Watch for company changes
watch(() => authStore.currentCompanyId, () => {
  if (authStore.currentCompanyId) {
    fetchRoles();
  }
});

onMounted(() => {
  if (authStore.currentCompanyId) {
    fetchRoles();
  }
});
</script>
```