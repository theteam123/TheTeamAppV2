<template>
  <div class="p-6">
    <header class="mb-8">
      <h1 class="text-2xl font-semibold text-gray-900">Company Management</h1>
      <p class="mt-2 text-sm text-gray-600">
        Manage companies and their settings
      </p>
    </header>

    <!-- Add Company Button -->
    <div class="mb-6">
      <button
        @click="showAddCompanyModal = true"
        class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        <PlusIcon class="h-5 w-5 mr-2" />
        Add Company
      </button>
    </div>

    <!-- Companies List -->
    <div class="bg-white shadow overflow-hidden sm:rounded-md">
      <ul role="list" class="divide-y divide-gray-200">
        <li v-for="company in companies" :key="company.id">
          <div class="px-4 py-4 sm:px-6 hover:bg-gray-50">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <div v-if="company.logo_url" class="flex-shrink-0 h-10 w-10">
                  <img
                    :src="company.logo_url"
                    :alt="company.name"
                    class="h-10 w-10 rounded-full"
                  />
                </div>
                <div v-else class="flex-shrink-0 h-10 w-10 bg-gray-200 rounded-full flex items-center justify-center">
                  <BuildingIcon class="h-6 w-6 text-gray-500" />
                </div>
                <div class="ml-4">
                  <div class="text-sm font-medium text-gray-900">
                    {{ company.name }}
                  </div>
                  <div class="text-sm text-gray-500">
                    Created {{ new Date(company.created_at).toLocaleDateString() }}
                  </div>
                </div>
              </div>
              <div class="flex space-x-2">
                <button
                  @click="editCompany(company)"
                  class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Edit
                </button>
                <button
                  @click="confirmDelete(company)"
                  class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        </li>
      </ul>
    </div>

    <!-- Add/Edit Company Modal -->
    <Modal
      v-if="showAddCompanyModal"
      :title="editingCompany ? 'Edit Company' : 'Add Company'"
      @close="closeModal"
    >
      <form @submit.prevent="saveCompany" class="space-y-4">
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700">
            Company Name
          </label>
          <input
            type="text"
            id="name"
            v-model="companyForm.name"
            required
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          />
        </div>

        <div>
          <label for="website" class="block text-sm font-medium text-gray-700">
            Website
          </label>
          <input
            type="url"
            id="website"
            v-model="companyForm.website"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          />
        </div>

        <div>
          <label for="logo_url" class="block text-sm font-medium text-gray-700">
            Logo URL
          </label>
          <input
            type="url"
            id="logo_url"
            v-model="companyForm.logo_url"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          />
        </div>

        <div class="flex justify-end space-x-3 pt-4">
          <button
            type="button"
            @click="closeModal"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            {{ editingCompany ? 'Update' : 'Create' }}
          </button>
        </div>
      </form>
    </Modal>

    <!-- Delete Confirmation Modal -->
    <Modal
      v-if="showDeleteModal"
      title="Delete Company"
      @close="showDeleteModal = false"
    >
      <div class="space-y-4">
        <p class="text-sm text-gray-500">
          Are you sure you want to delete {{ companyToDelete?.name }}? This action cannot be undone.
        </p>
        <div class="flex justify-end space-x-3">
          <button
            @click="showDeleteModal = false"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Cancel
          </button>
          <button
            @click="deleteCompany"
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            Delete
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
  TrashIcon,
  LoaderIcon,
  PlusIcon,
  XIcon
} from 'lucide-vue-next';
import Modal from '@/components/Modal.vue';
import { useToast } from '@/composables/useToast';
import type { Company } from '@/lib/types';

const { showToast } = useToast();
const companies = ref<Company[]>([]);
const showAddCompanyModal = ref(false);
const showDeleteModal = ref(false);
const companyToDelete = ref<Company | null>(null);
const editingCompany = ref<Company | null>(null);
const companyForm = ref({
  name: '',
  website: '',
  logo_url: ''
});

onMounted(async () => {
  await fetchCompanies();
});

async function fetchCompanies() {
  try {
    const { data, error } = await supabase
      .from('companies')
      .select('*')
      .order('name');

    if (error) throw error;
    companies.value = data;
  } catch (error) {
    console.error('Error fetching companies:', error);
    showToast('Error fetching companies', 'error');
  }
}

function editCompany(company: Company) {
  editingCompany.value = company;
  companyForm.value = {
    name: company.name,
    website: company.website || '',
    logo_url: company.logo_url || ''
  };
  showAddCompanyModal.value = true;
}

async function saveCompany() {
  try {
    if (editingCompany.value) {
      const { error } = await supabase
        .from('companies')
        .update(companyForm.value)
        .eq('id', editingCompany.value.id);

      if (error) throw error;
      showToast('Company updated successfully', 'success');
    } else {
      const { error } = await supabase
        .from('companies')
        .insert(companyForm.value);

      if (error) throw error;
      showToast('Company created successfully', 'success');
    }

    await fetchCompanies();
    closeModal();
  } catch (error) {
    console.error('Error saving company:', error);
    showToast('Error saving company', 'error');
  }
}

function confirmDelete(company: Company) {
  companyToDelete.value = company;
  showDeleteModal.value = true;
}

async function deleteCompany() {
  if (!companyToDelete.value) return;

  try {
    const { error } = await supabase
      .from('companies')
      .delete()
      .eq('id', companyToDelete.value.id);

    if (error) throw error;
    showToast('Company deleted successfully', 'success');
    await fetchCompanies();
  } catch (error) {
    console.error('Error deleting company:', error);
    showToast('Error deleting company', 'error');
  } finally {
    showDeleteModal.value = false;
    companyToDelete.value = null;
  }
}

function closeModal() {
  showAddCompanyModal.value = false;
  editingCompany.value = null;
  companyForm.value = {
    name: '',
    website: '',
    logo_url: ''
  };
}
</script> 