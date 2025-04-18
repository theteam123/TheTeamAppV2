<template>
  <div class="p-8">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Tags</h1>
        <p class="text-sm text-gray-500 mt-1">Manage and organize content tags</p>
      </div>
      <button
        @click="openCreateTagModal"
        class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
      >
        <TagPlusIcon class="w-5 h-5" />
        Create Tag
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
    </div>

    <!-- Tags Grid -->
    <div v-else-if="tags.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="tag in tags"
        :key="tag.id"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-center gap-3">
              <div
                class="w-8 h-8 rounded-lg flex items-center justify-center"
                :style="{ backgroundColor: tag.color + '20' }"
              >
                <TagIcon class="w-5 h-5" :style="{ color: tag.color }" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ tag.name }}</h3>
                <p class="text-sm text-gray-500">{{ tag.description }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <button
                @click="editTag(tag)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteTag(tag)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <div class="flex items-center gap-2 text-sm text-gray-600">
              <HashIcon class="w-4 h-4" />
              <span>{{ tag.usage_count }} items tagged</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <FolderIcon class="w-4 h-4" />
              <span>{{ tag.categories.join(', ') || 'All categories' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <TagIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No tags</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new tag.</p>
      <div class="mt-6">
        <button
          @click="openCreateTagModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <TagPlusIcon class="w-5 h-5 mr-2" />
          Create Tag
        </button>
      </div>
    </div>

    <!-- Create/Edit Tag Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Tag' : 'Create New Tag' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label for="tag-name" class="block text-sm font-medium text-gray-700">Tag Name</label>
            <input
              id="tag-name"
              type="text"
              v-model="formData.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label for="tag-description" class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              id="tag-description"
              v-model="formData.description"
              rows="2"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            ></textarea>
          </div>

          <div>
            <label for="tag-color" class="block text-sm font-medium text-gray-700">Color</label>
            <div class="mt-1 flex gap-2">
              <input
                id="tag-color"
                type="color"
                v-model="formData.color"
                class="h-9 w-16 rounded border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
              <input
                id="tag-color-hex"
                type="text"
                v-model="formData.color"
                class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                pattern="#[0-9A-Fa-f]{6}"
                placeholder="#000000"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Categories</label>
            <div class="mt-2 space-y-2">
              <label
                v-for="category in availableCategories"
                :key="category"
                :class="'inline-flex items-center mr-4'"
              >
                <input
                  type="checkbox"
                  :id="'category-' + category"
                  :value="category"
                  v-model="formData.categories"
                  class="rounded border-gray-300 text-green-600 focus:ring-green-500"
                />
                <span class="ml-2 text-sm text-gray-700">{{ category }}</span>
              </label>
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
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import {
  TagIcon,
  TagPlusIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  XIcon,
  HashIcon,
  FolderIcon,
} from 'lucide-vue-next';

const authStore = useAuthStore();
const loading = ref(false);
const error = ref(null);
const tags = ref([]);
const showModal = ref(false);
const isEditing = ref(false);

const availableCategories = [
  'Records',
  'Users',
  'Companies'
];

const formData = ref({
  id: '',
  name: '',
  description: '',
  color: '#4F46E5',
  categories: [] as string[]
});

const fetchTags = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('tags')
      .select(`
        *,
        tagged_items (
          count
        )
      `)
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;

    tags.value = data.map(tag => ({
      ...tag,
      usage_count: tag.tagged_items[0]?.count || 0
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const openCreateTagModal = () => {
  isEditing.value = false;
  formData.value = {
    id: '',
    name: '',
    description: '',
    color: '#4F46E5',
    categories: []
  };
  showModal.value = true;
};

const editTag = (tag) => {
  isEditing.value = true;
  formData.value = {
    id: tag.id,
    name: tag.name,
    description: tag.description || '',
    color: tag.color,
    categories: tag.categories || []
  };
  showModal.value = true;
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    const tagData = {
      name: formData.value.name,
      description: formData.value.description,
      color: formData.value.color,
      categories: formData.value.categories,
      company_id: authStore.currentCompanyId
    };

    if (isEditing.value) {
      const { error: updateError } = await supabase
        .from('tags')
        .update(tagData)
        .eq('id', formData.value.id);

      if (updateError) throw updateError;
    } else {
      const { error: insertError } = await supabase
        .from('tags')
        .insert(tagData);

      if (insertError) throw insertError;
    }

    showModal.value = false;
    await fetchTags();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteTag = async (tag) => {
  if (!confirm('Are you sure you want to delete this tag? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('tags')
      .delete()
      .eq('id', tag.id);

    if (err) throw err;
    await fetchTags();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(fetchTags);
</script>