<template>
  <Modal
    :title="'Select Company'"
    :show="show"
    @close="$emit('close')"
    :closeable="false"
  >
    <div class="space-y-6">
      <p class="text-sm text-gray-500">
        Please select the company you want to access:
      </p>

      <div class="space-y-2">
        <div
          v-for="company in companies"
          :key="company.id"
          @click="selectCompany(company)"
          class="flex items-center p-3 cursor-pointer rounded-lg border"
          :class="[
            selectedCompany?.id === company.id
              ? 'border-indigo-500 bg-indigo-50'
              : 'border-gray-200 hover:border-gray-300'
          ]"
        >
          <div class="flex items-center flex-1">
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
            </div>
          </div>
          <div v-if="selectedCompany?.id === company.id" class="text-indigo-600">
            <CheckCircleIcon class="h-5 w-5" />
          </div>
        </div>
      </div>

      <div class="flex justify-end">
        <button
          type="button"
          @click="confirmSelection"
          :disabled="!selectedCompany"
          class="inline-flex justify-center px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Continue
        </button>
      </div>
    </div>
  </Modal>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { BuildingIcon, CheckCircleIcon } from 'lucide-vue-next';
import Modal from './Modal.vue';
import type { Company } from '../lib/types';

const props = defineProps<{
  show: boolean;
  companies: Company[];
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'select', company: Company): void;
}>();

const selectedCompany = ref<Company | null>(null);

function selectCompany(company: Company) {
  selectedCompany.value = company;
}

function confirmSelection() {
  if (selectedCompany.value) {
    emit('select', selectedCompany.value);
  }
}
</script> 