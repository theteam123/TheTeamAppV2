<template>
  <div class="p-8">
    <!-- Add Document Button -->
    <div class="flex justify-end mb-6">
      <button
        @click="openUploadModal"
        class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
      >
        <FileUpIcon class="w-5 h-5" />
        Add Document
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="mb-6 flex flex-col sm:flex-row gap-4">
      <div class="flex-1">
        <div class="relative">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search documents..."
            class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
          />
        </div>
      </div>
      <div class="flex gap-4">
        <select
          v-model="selectedCategory"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
        >
          <option value="">All Categories</option>
          <option v-for="category in categories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
        <select
          v-model="sortBy"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
        >
          <option value="name">Name</option>
          <option value="updated_at">Last Updated</option>
          <option value="created_at">Date Created</option>
        </select>
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

    <!-- Documents Grid -->
    <div v-else-if="filteredDocuments.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="document in filteredDocuments"
        :key="document.id"
        class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-start gap-3">
              <div class="p-2 bg-green-50 rounded-lg">
                <FileTextIcon class="w-8 h-8 text-green-600" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900 line-clamp-1">{{ document.name }}</h3>
                <p class="text-sm text-gray-500 mt-1">{{ formatFileSize(document.size) }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <button
                @click="downloadDocument(document)"
                class="text-gray-400 hover:text-gray-600"
                title="Download"
              >
                <DownloadIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteDocument(document)"
                class="text-gray-400 hover:text-red-600"
                title="Delete"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <div class="flex flex-wrap gap-2">
              <span
                v-if="document.category"
                class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800"
              >
                {{ document.category }}
              </span>
              <span
                v-for="tag in document.tags"
                :key="tag"
                class="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800"
              >
                {{ tag }}
              </span>
            </div>
          </div>

          <div class="mt-4 text-sm text-gray-500">
            <div class="flex items-center gap-2">
              <ClockIcon class="w-4 h-4" />
              <span>Updated {{ formatDate(document.updated_at) }}</span>
            </div>
            <div class="flex items-center gap-2 mt-1">
              <UserIcon class="w-4 h-4" />
              <span>{{ document.uploader_name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <FileIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No documents</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by uploading a new document.</p>
      <div class="mt-6">
        <button
          @click="openUploadModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <FileUpIcon class="w-5 h-5 mr-2" />
          Upload Document
        </button>
      </div>
    </div>

    <!-- Upload Modal -->
    <div v-if="showUploadModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h2 class="text-xl font-bold mb-4">Upload Document</h2>
        <form @submit.prevent="handleUpload" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Document Name</label>
            <input
              type="text"
              v-model="uploadForm.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Category</label>
            <select
              v-model="uploadForm.category"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="">Select Category</option>
              <option v-for="category in categories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Tags</label>
            <input
              type="text"
              v-model="uploadForm.tags"
              placeholder="Enter tags separated by commas"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">File</label>
            <input
              type="file"
              @change="handleFileSelect"
              class="mt-1 block w-full text-sm text-gray-500
                file:mr-4 file:py-2 file:px-4
                file:rounded-md file:border-0
                file:text-sm file:font-medium
                file:bg-green-50 file:text-green-700
                hover:file:bg-green-100"
              required
            />
          </div>
          <div class="flex justify-end gap-3 mt-6">
            <button
              type="button"
              @click="showUploadModal = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700"
              :disabled="uploading"
            >
              <span v-if="!uploading">Upload</span>
              <LoaderIcon v-else class="w-5 h-5 animate-spin" />
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import {
  FileUpIcon,
  FileTextIcon,
  FileIcon,
  SearchIcon,
  DownloadIcon,
  TrashIcon,
  LoaderIcon,
  ClockIcon,
  UserIcon,
} from 'lucide-vue-next';

const authStore = useAuthStore();
const loading = ref(false);
const error = ref<string | null>(null);
const documents = ref<any[]>([]);
const searchQuery = ref('');
const selectedCategory = ref('');
const sortBy = ref('updated_at');
const showUploadModal = ref(false);
const uploading = ref(false);

const categories = [
  'Contracts',
  'Policies',
  'Reports',
  'Training',
  'Templates',
  'Other'
];

const uploadForm = ref({
  name: '',
  category: '',
  tags: '',
  file: null as File | null
});

const filteredDocuments = computed(() => {
  let filtered = [...documents.value];

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(doc => 
      doc.name.toLowerCase().includes(query) ||
      doc.tags.some((tag: string) => tag.toLowerCase().includes(query))
    );
  }

  if (selectedCategory.value) {
    filtered = filtered.filter(doc => doc.category === selectedCategory.value);
  }

  filtered.sort((a, b) => {
    if (sortBy.value === 'name') {
      return a.name.localeCompare(b.name);
    } else {
      return new Date(b[sortBy.value]).getTime() - new Date(a[sortBy.value]).getTime();
    }
  });

  return filtered;
});

const fetchDocuments = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('documents')
      .select(`
        *,
        uploader:profiles!documents_uploaded_by_fkey (
          id,
          full_name
        )
      `)
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;

    documents.value = data.map(doc => ({
      ...doc,
      uploader_name: doc.uploader?.full_name || 'Unknown',
      tags: doc.tags || []
    }));
  } catch (err: any) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const handleFileSelect = (event: Event) => {
  const input = event.target as HTMLInputElement;
  if (input.files && input.files.length > 0) {
    uploadForm.value.file = input.files[0];
    if (!uploadForm.value.name) {
      uploadForm.value.name = uploadForm.value.file.name;
    }
  }
};

const handleUpload = async () => {
  if (!uploadForm.value.file) return;

  uploading.value = true;
  try {
    // Upload file to storage
    const fileExt = uploadForm.value.file.name.split('.').pop();
    const fileName = `${Math.random().toString(36).slice(2)}.${fileExt}`;
    const filePath = `${authStore.currentCompanyId}/${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(filePath, uploadForm.value.file);

    if (uploadError) throw uploadError;

    // Create document record
    const { error: insertError } = await supabase
      .from('documents')
      .insert({
        name: uploadForm.value.name,
        category: uploadForm.value.category,
        tags: uploadForm.value.tags.split(',').map(tag => tag.trim()).filter(Boolean),
        file_path: filePath,
        size: uploadForm.value.file.size,
        company_id: authStore.currentCompanyId,
        uploaded_by: authStore.user?.id
      });

    if (insertError) throw insertError;

    showUploadModal.value = false;
    uploadForm.value = {
      name: '',
      category: '',
      tags: '',
      file: null
    };
    await fetchDocuments();
  } catch (err: any) {
    error.value = err.message;
  } finally {
    uploading.value = false;
  }
};

const downloadDocument = async (document: any) => {
  try {
    const { data, error: downloadError } = await supabase.storage
      .from('documents')
      .download(document.file_path);

    if (downloadError) throw downloadError;

    // Create download link
    const url = window.URL.createObjectURL(data);
    const link = document.createElement('a');
    link.href = url;
    link.download = document.name;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (err: any) {
    error.value = err.message;
  }
};

const deleteDocument = async (document: any) => {
  if (!confirm('Are you sure you want to delete this document? This action cannot be undone.')) return;

  loading.value = true;
  try {
    // Delete file from storage
    const { error: storageError } = await supabase.storage
      .from('documents')
      .remove([document.file_path]);

    if (storageError) throw storageError;

    // Delete document record
    const { error: deleteError } = await supabase
      .from('documents')
      .delete()
      .eq('id', document.id);

    if (deleteError) throw deleteError;

    await fetchDocuments();
  } catch (err: any) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const formatFileSize = (bytes: number) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};

const openUploadModal = () => {
  uploadForm.value = {
    name: '',
    category: '',
    tags: '',
    file: null
  };
  showUploadModal.value = true;
};

onMounted(fetchDocuments);
</script>