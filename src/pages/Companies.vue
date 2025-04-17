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

    <!-- Companies Grid -->
    <div v-else-if="companies.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="company in companies" :key="company.id" class="bg-white rounded-lg shadow-md overflow-hidden">
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-lg font-semibold text-gray-900">{{ company.name }}</h3>
              <a 
                v-if="company.website" 
                :href="company.website"
                target="_blank"
                class="text-sm text-green-600 hover:text-green-700 flex items-center gap-1 mt-1"
              >
                <GlobeIcon class="w-4 h-4" />
                {{ company.website }}
              </a>
            </div>
            <div class="flex gap-2">
              <button
                @click="editCompany(company)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteCompany(company.id)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <div class="flex items-center gap-2 text-sm text-gray-600">
              <UsersIcon class="w-4 h-4" />
              <span>{{ company.user_count }} Users</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <CalendarIcon class="w-4 h-4" />
              <span>Created {{ formatDate(company.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400">
        <BuildingIcon class="h-12 w-12" />
      </div>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No companies</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new company.</p>
      <div class="mt-6">
        <button
          @click="openCreateCompanyModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
        >
          <BuildingPlusSquare class="w-5 h-5 mr-2" />
          Add Company
        </button>
      </div>
    </div>

    <!-- Create/Edit Company Modal -->
    <CompanyFormModal
      v-if="showModal"
      :isEditing="isEditing"
      :companyData="selectedCompany"
      @close="closeModal"
      @submit="handleSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useCompanies } from '../composables/useCompanies';
import type { Company } from '../lib/types';
import CompanyFormModal from '../components/CompanyFormModal.vue';
import { PlusSquare as BuildingPlusSquare, BuildingIcon, PencilIcon, TrashIcon, LoaderIcon, GlobeIcon, UsersIcon, CalendarIcon } from 'lucide-vue-next';

const { companies, loading, error, fetchCompanies, createCompany, updateCompany, deleteCompany } = useCompanies();
const showModal = ref(false);
const isEditing = ref(false);
const selectedCompany = ref<Company | null>(null);

const openCreateCompanyModal = () => {
  isEditing.value = false;
  selectedCompany.value = null;
  showModal.value = true;
};

const editCompany = (company: Company) => {
  isEditing.value = true;
  selectedCompany.value = company;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedCompany.value = null;
};

const handleSubmit = async (formData: { name: string; website: string; settingsStr: string }) => {
  if (isEditing.value && selectedCompany.value) {
    await updateCompany(selectedCompany.value.id, formData);
  } else {
    await createCompany(formData);
  }
  closeModal();
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};

onMounted(fetchCompanies);
</script>