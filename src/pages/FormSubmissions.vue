<template>
  <div class="p-8">
    <div class="flex items-center gap-4 mb-6">
      <button
        @click="router.push('/forms')"
        class="text-gray-600 hover:text-gray-900"
      >
        <ArrowLeftIcon class="w-6 h-6" />
      </button>
      <div class="flex-1">
        <h1 class="text-2xl font-bold text-gray-900">{{ form?.name }} Submissions</h1>
        <p class="text-sm text-gray-500 mt-1">View and manage form responses</p>
      </div>
      <div class="flex gap-3">
        <button
          v-if="submissions.length > 0"
          @click="exportToCsv"
          class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <DownloadIcon class="w-5 h-5 mr-2" />
          Export CSV
        </button>
        <button
          @click="copyFormLink"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <LinkIcon class="w-5 h-5 mr-2" />
          Copy Form Link
        </button>
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

    <!-- Submissions Table -->
    <div v-else-if="submissions.length > 0" class="bg-white rounded-lg shadow overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                v-for="field in form.fields"
                :key="field.label"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                {{ field.label }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Submitted By
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Submitted At
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="submission in submissions" :key="submission.id">
              <td
                v-for="field in form.fields"
                :key="field.label"
                class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
              >
                {{ submission.data[field.label] }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ submission.submitted_by_name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(submission.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <button
                  @click="deleteSubmission(submission)"
                  class="text-red-600 hover:text-red-900"
                >
                  <TrashIcon class="w-5 h-5" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <ClipboardIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No submissions yet</h3>
      <p class="mt-1 text-sm text-gray-500">Share this form to start collecting responses.</p>
      <div class="mt-6">
        <button
          @click="copyFormLink"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <LinkIcon class="w-5 h-5 mr-2" />
          Copy Form Link
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import { format } from 'date-fns';
import {
  ArrowLeftIcon,
  LoaderIcon,
  ClipboardIcon,
  TrashIcon,
  LinkIcon,
  DownloadIcon,
} from 'lucide-vue-next';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const loading = ref(false);
const error = ref(null);
const form = ref(null);
const submissions = ref([]);

const fetchFormAndSubmissions = async () => {
  loading.value = true;
  try {
    // Fetch form details
    const { data: formData, error: formError } = await supabase
      .from('forms')
      .select('*')
      .eq('id', route.params.id)
      .single();

    if (formError) throw formError;
    form.value = formData;

    // Fetch submissions
    const { data: submissionsData, error: submissionsError } = await supabase
      .from('form_submissions')
      .select(`
        *,
        profiles:submitted_by (
          full_name
        )
      `)
      .eq('form_id', route.params.id)
      .order('created_at', { ascending: false });

    if (submissionsError) throw submissionsError;

    submissions.value = submissionsData.map(submission => ({
      ...submission,
      submitted_by_name: submission.profiles.full_name
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteSubmission = async (submission) => {
  if (!confirm('Are you sure you want to delete this submission? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('form_submissions')
      .delete()
      .eq('id', submission.id);

    if (err) throw err;
    await fetchFormAndSubmissions();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const copyFormLink = async () => {
  const formUrl = `${window.location.origin}/forms/${route.params.id}/submit`;
  await navigator.clipboard.writeText(formUrl);
  alert('Form link copied to clipboard!');
};

const exportToCsv = () => {
  if (!form.value || !submissions.value.length) return;

  // Prepare headers
  const headers = [
    ...form.value.fields.map(field => field.label),
    'Submitted By',
    'Submitted At'
  ];

  // Prepare rows
  const rows = submissions.value.map(submission => [
    ...form.value.fields.map(field => submission.data[field.label] || ''),
    submission.submitted_by_name,
    formatDate(submission.created_at)
  ]);

  // Combine headers and rows
  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n');

  // Create and trigger download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${form.value.name} Submissions.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy h:mm a');
};

onMounted(fetchFormAndSubmissions);
</script>