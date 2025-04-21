<template>
  <div class="p-8">
    <!-- System Role Check -->
    <div v-if="!authStore.isAppAdmin" class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400">
        <ShieldIcon class="h-12 w-12" />
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900">Access Denied</h3>
      <p class="mt-1 text-sm text-gray-500">Only system administrators can manage companies.</p>
    </div>

    <!-- Main Content (only shown to users with can_manage_companies permission) -->
    <div v-else>
      <!-- Notification -->
      <div v-if="notification" 
           class="fixed top-4 right-4 p-4 rounded-lg shadow-lg"
           :class="{
             'bg-green-100 text-green-800': notification.type === 'success',
             'bg-red-100 text-red-800': notification.type === 'error'
           }">
        {{ notification.message }}
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-8">
        <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
        {{ error }}
      </div>

      <!-- Main Content -->
      <div v-else>
        <p class="text-sm text-gray-500 mb-6">Manage companies and their settings</p>

        <!-- Companies Table -->
        <div v-if="companies.length > 0" class="bg-white rounded-lg shadow overflow-hidden">
          <!-- Search and Filter Bar -->
          <div class="p-4 border-b border-gray-200">
            <div class="flex flex-col sm:flex-row gap-4">
              <div class="flex-1">
                <div class="relative">
                  <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                  <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search companies..."
                    class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                  />
                </div>
              </div>
              <div>
                <button
                  @click="openCreateCompanyModal"
                  v-if="authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')"
                  class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                >
                  <PlusIcon class="w-5 h-5 mr-2" />
                  Add Company
                </button>
              </div>
            </div>
          </div>

          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Company</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Website</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="company in filteredCompanies" :key="company.id">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="h-10 w-10 flex-shrink-0 bg-gray-200 rounded-full flex items-center justify-center">
                      <BuildingIcon class="h-6 w-6 text-gray-500" />
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ company.name }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <a v-if="company.website" :href="company.website" target="_blank" class="text-blue-600 hover:underline">
                    {{ company.website }}
                  </a>
                  <span v-else>-</span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  <span v-if="company.archived_at" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    Archived
                  </span>
                  <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    Active
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(company.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <div class="flex items-center space-x-3">
                    <button
                      @click="editCompany(company)"
                      v-if="authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')"
                      class="text-green-600 hover:text-green-900"
                      title="Edit Company"
                    >
                      <PencilIcon class="w-5 h-5" />
                    </button>
                    <button
                      v-if="(authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')) && !company.archived_at"
                      @click="confirmArchive(company)"
                      class="text-yellow-600 hover:text-yellow-900"
                      title="Archive Company"
                    >
                      <ArchiveIcon class="w-5 h-5" />
                    </button>
                    <button
                      v-if="(authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')) && company.archived_at"
                      @click="confirmRestore(company)"
                      class="text-green-600 hover:text-green-900"
                      title="Restore Company"
                    >
                      <ArchiveRestoreIcon class="w-5 h-5" />
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
            <Building2Icon class="h-12 w-12" />
          </div>
          <h3 class="mt-2 text-sm font-medium text-gray-900">No companies</h3>
          <p class="mt-1 text-sm text-gray-500">Get started by adding a new company.</p>
          <div class="mt-6">
            <button
              @click="openCreateCompanyModal"
              v-if="authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')"
              class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
            >
              <PlusIcon class="w-5 h-5 mr-2" />
              Add Company
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Company Modal -->
    <CompanyFormModal
      v-if="showAddCompanyModal"
      :is-editing="!!editingCompany"
      :company-data="editingCompany"
      @close="closeModal"
      @submit="saveCompany"
    />

    <!-- Archive Confirmation Modal -->
    <Modal
      v-if="showArchiveModal"
      title="Archive Company"
      @close="showArchiveModal = false"
    >
      <div class="space-y-4">
        <p class="text-sm text-gray-500">
          Are you sure you want to archive {{ companyToArchive?.name }}? The company will be hidden from regular users but can be restored later.
        </p>
        <div class="flex justify-end space-x-3">
          <button
            @click="showArchiveModal = false"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none"
          >
            Cancel
          </button>
          <button
            @click="archiveCompany"
            class="px-4 py-2 text-sm font-medium text-white bg-yellow-600 border border-transparent rounded-md shadow-sm hover:bg-yellow-700 focus:outline-none"
          >
            Archive
          </button>
        </div>
      </div>
    </Modal>

    <!-- Restore Confirmation Modal -->
    <Modal
      v-if="showRestoreModal"
      title="Restore Company"
      @close="showRestoreModal = false"
    >
      <div class="space-y-4">
        <p class="text-sm text-gray-500">
          Are you sure you want to restore {{ companyToRestore?.name }}? The company will become visible to users again.
        </p>
        <div class="flex justify-end space-x-3">
          <button
            @click="showRestoreModal = false"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none"
          >
            Cancel
          </button>
          <button
            @click="restoreCompany"
            class="px-4 py-2 text-sm font-medium text-white bg-green-600 border border-transparent rounded-md shadow-sm hover:bg-green-700 focus:outline-none"
          >
            Restore
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
  BuildingIcon,
  Building2Icon,
  PencilIcon,
  ArchiveIcon,
  ArchiveRestoreIcon,
  LoaderIcon,
  PlusIcon,
  SearchIcon,
  ShieldIcon
} from 'lucide-vue-next';
import Modal from '@/components/Modal.vue';
import CompanyFormModal from '@/components/CompanyFormModal.vue';
import type { Company } from '@/lib/types';
import { format } from 'date-fns';

const authStore = useAuthStore();
const companies = ref<Company[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const showAddCompanyModal = ref(false);
const showArchiveModal = ref(false);
const showRestoreModal = ref(false);
const companyToArchive = ref<Company | null>(null);
const companyToRestore = ref<Company | null>(null);
const editingCompany = ref<Company | undefined>(undefined);
const searchQuery = ref('');
const notification = ref<{ type: 'success' | 'error'; message: string } | null>(null);

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy');
};

const filteredCompanies = computed(() => {
  return companies.value.filter(company => {
    const matchesSearch = searchQuery.value === '' || 
      company.name?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      company.website?.toLowerCase().includes(searchQuery.value.toLowerCase());
    
    return matchesSearch;
  });
});

onMounted(async () => {
  if (authStore.isAppAdmin || authStore.hasPermission('can_manage_companies')) {
    await fetchCompanies();
  }
});

async function fetchCompanies() {
  loading.value = true;
  error.value = null;
  try {
    const { data, error: apiError } = await supabase
      .from('companies')
      .select('*')
      .order('name');

    if (apiError) throw apiError;
    companies.value = data || [];
  } catch (err) {
    console.error('Error fetching companies:', err);
    error.value = err instanceof Error ? err.message : 'Failed to fetch companies';
  } finally {
    loading.value = false;
  }
}

function openCreateCompanyModal() {
  if (!authStore.isAppAdmin && !authStore.hasPermission('can_manage_companies')) {
    showNotification('error', 'You do not have permission to create companies');
    return;
  }
  editingCompany.value = undefined;
  showAddCompanyModal.value = true;
}

function editCompany(company: Company) {
  if (!authStore.isAppAdmin && !authStore.hasPermission('can_manage_companies')) {
    showNotification('error', 'You do not have permission to edit companies');
    return;
  }
  editingCompany.value = company;
  showAddCompanyModal.value = true;
}

async function saveCompany(formData: any) {
  try {
    if (!authStore.isAppAdmin && !authStore.hasPermission('can_manage_companies')) {
      showNotification('error', 'You do not have permission to save company changes');
      return;
    }

    // Remove settingsStr and ensure proper data structure
    const { settingsStr, ...cleanData } = formData;
    console.log('Saving company with data:', cleanData);

    if (editingCompany.value) {
      console.log('Updating existing company:', editingCompany.value.id);
      const { data, error: apiError } = await supabase
        .from('companies')
        .update(cleanData)
        .eq('id', editingCompany.value.id)
        .select();

      if (apiError) {
        console.error('Supabase update error:', apiError);
        throw apiError;
      }
      console.log('Update successful:', data);
      showNotification('success', 'Company updated successfully');
    } else {
      console.log('Creating new company');
      const { data, error: apiError } = await supabase
        .from('companies')
        .insert(cleanData)
        .select();

      if (apiError) {
        console.error('Supabase insert error:', apiError);
        throw apiError;
      }
      console.log('Insert successful:', data);
      showNotification('success', 'Company created successfully');
    }

    await fetchCompanies();
    closeModal();
  } catch (err) {
    console.error('Error saving company:', err);
    const errorMessage = err instanceof Error 
      ? err.message 
      : (err as any)?.message || (err as any)?.details || 'Failed to save company';
    showNotification('error', errorMessage);
  }
}

function confirmArchive(company: Company) {
  if (!authStore.isAppAdmin && !authStore.hasPermission('can_manage_companies')) {
    showNotification('error', 'You do not have permission to archive companies');
    return;
  }
  companyToArchive.value = company;
  showArchiveModal.value = true;
}

function confirmRestore(company: Company) {
  if (!authStore.isAppAdmin && !authStore.hasPermission('can_manage_companies')) {
    showNotification('error', 'You do not have permission to restore companies');
    return;
  }
  companyToRestore.value = company;
  showRestoreModal.value = true;
}

async function archiveCompany() {
  if (!companyToArchive.value) return;

  try {
    const { error: apiError } = await supabase
      .rpc('archive_company', { company_id: companyToArchive.value.id });

    if (apiError) throw apiError;
    showNotification('success', 'Company archived successfully');
    await fetchCompanies();
  } catch (err) {
    console.error('Error archiving company:', err);
    showNotification('error', err instanceof Error ? err.message : 'Failed to archive company');
  } finally {
    showArchiveModal.value = false;
    companyToArchive.value = null;
  }
}

async function restoreCompany() {
  if (!companyToRestore.value) return;

  try {
    const { error: apiError } = await supabase
      .rpc('restore_company', { company_id: companyToRestore.value.id });

    if (apiError) throw apiError;
    showNotification('success', 'Company restored successfully');
    await fetchCompanies();
  } catch (err) {
    console.error('Error restoring company:', err);
    showNotification('error', err instanceof Error ? err.message : 'Failed to restore company');
  } finally {
    showRestoreModal.value = false;
    companyToRestore.value = null;
  }
}

function closeModal() {
  showAddCompanyModal.value = false;
  editingCompany.value = undefined;
}

const showNotification = (type: 'success' | 'error', message: string) => {
  notification.value = { type, message };
  setTimeout(() => {
    notification.value = null;
  }, 3000);
};
</script> 