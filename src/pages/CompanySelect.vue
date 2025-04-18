<template>
  <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Select Your Company
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Choose which company you want to access
      </p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <div v-if="loading" class="flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="company in companies"
            :key="company.id"
            @click="selectCompany(company)"
            class="flex items-center p-4 cursor-pointer rounded-lg border transition-colors duration-150"
            :class="[
              selectedCompany?.id === company.id
                ? 'border-indigo-500 bg-indigo-50'
                : 'border-gray-200 hover:border-gray-300'
            ]"
          >
            <div class="flex items-center flex-1">
              <div v-if="company.logo_url" class="flex-shrink-0 h-12 w-12">
                <img
                  :src="company.logo_url"
                  :alt="company.name"
                  class="h-12 w-12 rounded-full"
                />
              </div>
              <div v-else class="flex-shrink-0 h-12 w-12 bg-gray-200 rounded-full flex items-center justify-center">
                <BuildingIcon class="h-8 w-8 text-gray-500" />
              </div>
              <div class="ml-4">
                <div class="text-sm font-medium text-gray-900">
                  {{ company.name }}
                </div>
                <div v-if="company.website" class="text-sm text-gray-500">
                  {{ company.website }}
                </div>
              </div>
            </div>
            <div v-if="selectedCompany?.id === company.id" class="text-indigo-600">
              <CheckCircleIcon class="h-5 w-5" />
            </div>
          </div>

          <div class="mt-6">
            <button
              @click="confirmSelection"
              :disabled="!selectedCompany || loading"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Continue
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { BuildingIcon, CheckCircleIcon } from 'lucide-vue-next';
import { useAuthStore } from '../stores/auth';
import { useToast } from '../composables/useToast';
import type { Company } from '../lib/types';

const router = useRouter();
const auth = useAuthStore();
const { showToast } = useToast();

const loading = ref(false);
const selectedCompany = ref<Company | null>(null);

const companies = computed(() => auth.availableCompanies);

async function selectCompany(company: Company) {
  selectedCompany.value = company;
}

async function confirmSelection() {
  if (!selectedCompany.value) return;

  try {
    loading.value = true;
    await auth.selectCompany(selectedCompany.value.id);
    showToast('Company selected successfully', 'success');
    router.push('/dashboard');
  } catch (error) {
    console.error('Error selecting company:', error);
    showToast('Error selecting company', 'error');
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  // If user has no companies or only one company, redirect to dashboard
  if (!auth.needsCompanySelection) {
    router.push('/dashboard');
  }
});
</script> 