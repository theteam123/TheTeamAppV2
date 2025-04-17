<template>
  <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-3xl mx-auto">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-8">
        <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
        {{ error }}
      </div>

      <!-- Success Message -->
      <div v-else-if="submitted" class="text-center py-12">
        <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
          <CheckIcon class="h-6 w-6 text-green-600" />
        </div>
        <h3 class="mt-2 text-sm font-medium text-gray-900">Form Submitted Successfully</h3>
        <p class="mt-1 text-sm text-gray-500">Thank you for your submission!</p>
        <div class="mt-6">
          <button
            @click="submitted = false"
            class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            Submit Another Response
          </button>
        </div>
      </div>

      <!-- Form -->
      <div v-else-if="form" class="bg-white shadow rounded-lg">
        <div class="px-6 py-5 border-b border-gray-200">
          <h3 class="text-lg leading-6 font-medium text-gray-900">{{ form.name }}</h3>
          <p v-if="form.description" class="mt-1 text-sm text-gray-500">
            {{ form.description }}
          </p>
        </div>
        <form @submit.prevent="handleSubmit" class="space-y-6 p-6">
          <div v-for="field in form.fields" :key="field.label" class="space-y-1">
            <label :for="field.label" class="block text-sm font-medium text-gray-700">
              {{ field.label }}
              <span v-if="field.required" class="text-red-500">*</span>
            </label>

            <!-- Text Input -->
            <input
              v-if="field.type === 'text' || field.type === 'email'"
              :type="field.type"
              :id="field.label"
              v-model="formData[field.label]"
              :required="field.required"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            />

            <!-- Number Input -->
            <input
              v-else-if="field.type === 'number'"
              type="number"
              :id="field.label"
              v-model="formData[field.label]"
              :required="field.required"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            />

            <!-- Date Input -->
            <input
              v-else-if="field.type === 'date'"
              type="date"
              :id="field.label"
              v-model="formData[field.label]"
              :required="field.required"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            />

            <!-- Select Input -->
            <select
              v-else-if="field.type === 'select'"
              :id="field.label"
              v-model="formData[field.label]"
              :required="field.required"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            >
              <option value="">Select an option</option>
              <option
                v-for="option in field.options"
                :key="option"
                :value="option"
              >
                {{ option }}
              </option>
            </select>

            <!-- Textarea -->
            <textarea
              v-else-if="field.type === 'textarea'"
              :id="field.label"
              v-model="formData[field.label]"
              :required="field.required"
              rows="3"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            ></textarea>
          </div>

          <div class="flex justify-end">
            <button
              type="submit"
              :disabled="submitting"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <LoaderIcon v-if="submitting" class="w-4 h-4 mr-2 animate-spin" />
              {{ submitting ? 'Submitting...' : 'Submit' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import {
  LoaderIcon,
  CheckIcon,
} from 'lucide-vue-next';

const route = useRoute();
const authStore = useAuthStore();

const loading = ref(false);
const submitting = ref(false);
const submitted = ref(false);
const error = ref(null);
const form = ref(null);
const formData = ref({});

const fetchForm = async () => {
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('forms')
      .select('*')
      .eq('id', route.params.id)
      .single();

    if (fetchError) throw fetchError;
    form.value = data;

    // Initialize form data with empty values
    formData.value = form.value.fields.reduce((acc, field) => {
      acc[field.label] = '';
      return acc;
    }, {});
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  submitting.value = true;
  try {
    const { error: submitError } = await supabase
      .from('form_submissions')
      .insert({
        form_id: route.params.id,
        submitted_by: authStore.user?.id,
        data: formData.value
      });

    if (submitError) throw submitError;

    submitted.value = true;
    formData.value = form.value.fields.reduce((acc, field) => {
      acc[field.label] = '';
      return acc;
    }, {});
  } catch (err) {
    error.value = err.message;
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchForm);
</script>