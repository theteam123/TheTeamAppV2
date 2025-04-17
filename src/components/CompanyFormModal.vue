<template>
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
    <div class="bg-white rounded-lg p-6 max-w-md w-full">
      <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Company' : 'Create New Company' }}</h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label for="company-name" class="block text-sm font-medium text-gray-700">Company Name</label>
          <input
            id="company-name"
            type="text"
            v-model="formData.name"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            required
          />
        </div>

        <div>
          <label for="company-website" class="block text-sm font-medium text-gray-700">Website</label>
          <input
            id="company-website"
            type="url"
            v-model="formData.website"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            placeholder="https://example.com"
          />
        </div>

        <div>
          <label for="company-settings" class="block text-sm font-medium text-gray-700">Settings</label>
          <textarea
            id="company-settings"
            v-model="formData.settingsStr"
            rows="4"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            placeholder="Enter JSON settings"
          ></textarea>
          <p class="mt-1 text-sm text-gray-500">
            Enter valid JSON for company settings
          </p>
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
            <LoaderIcon v-if="loading" class="w-4 h-4 animate-spin" />
            <span v-else>{{ isEditing ? 'Update' : 'Create' }}</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import type { Company } from '../lib/types';
import { LoaderIcon } from 'lucide-vue-next';

const props = defineProps<{
  isEditing: boolean;
  companyData?: Company;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'submit', data: { name: string; website: string; settingsStr: string }): void;
}>();

const loading = ref(false);

const formData = ref({
  name: props.companyData?.name || '',
  website: props.companyData?.website || '',
  settingsStr: props.companyData ? JSON.stringify(props.companyData.settings, null, 2) : '{}'
});

const handleSubmit = async () => {
  loading.value = true;
  try {
    // Validate JSON settings
    try {
      JSON.parse(formData.value.settingsStr);
    } catch (err) {
      alert('Invalid JSON in settings field');
      return;
    }

    emit('submit', formData.value);
  } finally {
    loading.value = false;
  }
};
</script>