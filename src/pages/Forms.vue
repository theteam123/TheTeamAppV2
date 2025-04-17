<template>
  <div class="p-8">
    <!-- Create Form Button -->
    <div class="flex justify-end mb-6">
      <button
        @click="openCreateFormModal"
        class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
      >
        <ClipboardPlusIcon class="w-5 h-5" />
        Create Form
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="mb-6 flex flex-col sm:flex-row gap-4">
      <div class="flex-1">
        <div class="relative">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            id="form-search"
            v-model="searchQuery"
            placeholder="Search forms..."
            class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
          />
        </div>
      </div>
      <div class="flex gap-4">
        <select
          id="form-category"
          v-model="selectedCategory"
          class="border border-gray-300 rounded-lg px-4 py-2 focus:ring-green-500 focus:border-green-500"
        >
          <option value="">All Categories</option>
          <option v-for="category in categories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
        <select
          id="form-sort"
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

    <!-- Forms Grid -->
    <div v-else-if="filteredForms.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="form in filteredForms"
        :key="form.id"
        class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-start gap-3">
              <div class="p-2 bg-green-50 rounded-lg">
                <ClipboardIcon class="w-8 h-8 text-green-600" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ form.name }}</h3>
                <p class="text-sm text-gray-500 mt-1">{{ form.description }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <button
                @click="viewAnalytics(form)"
                class="text-gray-400 hover:text-gray-600"
                title="View Analytics"
              >
                <BarChartIcon class="w-5 h-5" />
              </button>
              <button
                @click="viewSubmissions(form)"
                class="text-gray-400 hover:text-gray-600"
                title="View Submissions"
              >
                <FileTextIcon class="w-5 h-5" />
              </button>
              <button
                @click="editForm(form)"
                class="text-gray-400 hover:text-gray-600"
                title="Edit"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteForm(form)"
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
                v-if="form.category"
                class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800"
              >
                {{ form.category }}
              </span>
              <span class="px-2 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-800">
                {{ form.fields.length }} Fields
              </span>
            </div>
          </div>

          <div class="mt-4 text-sm text-gray-500">
            <div class="flex items-center gap-2">
              <ClockIcon class="w-4 h-4" />
              <span>Updated {{ formatDate(form.updated_at) }}</span>
            </div>
            <div class="flex items-center gap-2 mt-1">
              <FileTextIcon class="w-4 h-4" />
              <span>{{ form.submissions_count }} Submissions</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <ClipboardIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No forms</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new form.</p>
      <div class="mt-6">
        <button
          @click="openCreateFormModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <ClipboardPlusIcon class="w-5 h-5 mr-2" />
          Create Form
        </button>
      </div>
    </div>

    <!-- Create/Edit Form Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-2xl w-full">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Form' : 'Create New Form' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label for="form-name" class="block text-sm font-medium text-gray-700">Form Name</label>
            <input
              id="form-name"
              type="text"
              v-model="formData.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>
          <div>
            <label for="form-description" class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              id="form-description"
              v-model="formData.description"
              rows="2"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            ></textarea>
          </div>
          <div>
            <label for="form-category" class="block text-sm font-medium text-gray-700">Category</label>
            <select
              id="form-category"
              v-model="formData.category"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="">Select Category</option>
              <option v-for="category in categories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>

          <!-- Form Fields -->
          <div>
            <div class="flex justify-between items-center mb-2">
              <label class="block text-sm font-medium text-gray-700">Form Fields</label>
              <button
                type="button"
                @click="addField"
                class="text-sm text-green-600 hover:text-green-700 flex items-center gap-1"
              >
                <PlusIcon class="w-4 h-4" />
                Add Field
              </button>
            </div>
            <div class="space-y-4">
              <div
                v-for="(field, index) in formData.fields"
                :key="index"
                class="flex gap-4 items-start p-4 bg-gray-50 rounded-lg"
              >
                <div class="flex-1">
                  <input
                    :id="'field-label-' + index"
                    type="text"
                    v-model="field.label"
                    placeholder="Field Label"
                    class="block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 text-sm"
                  />
                  <div class="mt-2 flex gap-4">
                    <select
                      :id="'field-type-' + index"
                      v-model="field.type"
                      class="rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 text-sm"
                    >
                      <option value="text">Text</option>
                      <option value="number">Number</option>
                      <option value="email">Email</option>
                      <option value="date">Date</option>
                      <option value="select">Select</option>
                      <option value="textarea">Text Area</option>
                    </select>
                    <label :for="'field-required-' + index" class="flex items-center">
                      <input
                        :id="'field-required-' + index"
                        type="checkbox"
                        v-model="field.required"
                        class="rounded border-gray-300 text-green-600 focus:ring-green-500"
                      />
                      <span class="ml-2 text-sm text-gray-600">Required</span>
                    </label>
                  </div>
                  <div v-if="field.type === 'select'" class="mt-2">
                    <input
                      :id="'field-options-' + index"
                      type="text"
                      v-model="field.options"
                      placeholder="Options (comma-separated)"
                      class="block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 text-sm"
                    />
                  </div>
                </div>
                <button
                  type="button"
                  @click="removeField(index)"
                  class="text-gray-400 hover:text-red-600"
                >
                  <TrashIcon class="w-5 h-5" />
                </button>
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
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import {
  ClipboardPlusIcon,
  ClipboardIcon,
  SearchIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  ClockIcon,
  FileTextIcon,
  PlusIcon,
  BarChartIcon,
} from 'lucide-vue-next';

const router = useRouter();
const authStore = useAuthStore();
const loading = ref(false);
const error = ref(null);
const forms = ref([]);
const searchQuery = ref('');
const selectedCategory = ref('');
const sortBy = ref('updated_at');
const showModal = ref(false);
const isEditing = ref(false);

const categories = [
  'HR',
  'Operations',
  'Finance',
  'IT',
  'Sales',
  'Other'
];

const formData = ref({
  id: '',
  name: '',
  description: '',
  category: '',
  fields: [] as any[]
});

const filteredForms = computed(() => {
  let filtered = [...forms.value];

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(form => 
      form.name.toLowerCase().includes(query) ||
      form.description.toLowerCase().includes(query)
    );
  }

  if (selectedCategory.value) {
    filtered = filtered.filter(form => form.category === selectedCategory.value);
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

const fetchForms = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('forms')
      .select(`
        *,
        form_submissions (
          count
        )
      `)
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;

    forms.value = data.map(form => ({
      ...form,
      submissions_count: form.form_submissions[0]?.count || 0
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const openCreateFormModal = () => {
  isEditing.value = false;
  formData.value = {
    id: '',
    name: '',
    description: '',
    category: '',
    fields: []
  };
  showModal.value = true;
};

const editForm = (form) => {
  isEditing.value = true;
  formData.value = {
    id: form.id,
    name: form.name,
    description: form.description || '',
    category: form.category || '',
    fields: form.fields || []
  };
  showModal.value = true;
};

const viewSubmissions = (form) => {
  router.push(`/forms/${form.id}/submissions`);
};

const viewAnalytics = (form) => {
  router.push(`/forms/${form.id}/analytics`);
};

const addField = () => {
  formData.value.fields.push({
    label: '',
    type: 'text',
    required: false,
    options: ''
  });
};

const removeField = (index: number) => {
  formData.value.fields.splice(index, 1);
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    const formFields = formData.value.fields.map(field => ({
      ...field,
      options: field.type === 'select' ? field.options.split(',').map(opt => opt.trim()) : null
    }));

    const submitData = {
      name: formData.value.name,
      description: formData.value.description,
      category: formData.value.category,
      fields: formFields,
      company_id: authStore.currentCompanyId
    };

    if (isEditing.value) {
      const { error: updateError } = await supabase
        .from('forms')
        .update(submitData)
        .eq('id', formData.value.id);

      if (updateError) throw updateError;
    } else {
      const { error: insertError } = await supabase
        .from('forms')
        .insert(submitData);

      if (insertError) throw insertError;
    }

    showModal.value = false;
    await fetchForms();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteForm = async (form) => {
  if (!confirm('Are you sure you want to delete this form? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('forms')
      .delete()
      .eq('id', form.id);

    if (err) throw err;
    await fetchForms();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};

onMounted(fetchForms);
</script>