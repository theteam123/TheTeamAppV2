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

    <!-- Categories Grid -->
    <div v-else-if="categories.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="category in categories"
        :key="category.id"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-center gap-3">
              <div
                class="w-8 h-8 rounded-lg flex items-center justify-center"
                :style="{ backgroundColor: category.color + '20' }"
              >
                <FolderIcon class="w-5 h-5" :style="{ color: category.color }" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ category.name }}</h3>
                <p class="text-sm text-gray-500">{{ category.description }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <button
                @click="editCategory(category)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteCategory(category)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <div class="flex items-center gap-2 text-sm text-gray-600">
              <LayoutGridIcon class="w-4 h-4" />
              <span>{{ category.item_count }} items</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <TagIcon class="w-4 h-4" />
              <span>{{ category.tags.length }} associated tags</span>
            </div>
            <div v-if="category.parent_id" class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <FolderTreeIcon class="w-4 h-4" />
              <span>Subcategory of {{ getCategoryName(category.parent_id) }}</span>
            </div>
          </div>

          <div v-if="category.subcategories.length > 0" class="mt-4">
            <p class="text-sm font-medium text-gray-700 mb-2">Subcategories:</p>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="subcategory in category.subcategories"
                :key="subcategory.id"
                class="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800"
              >
                {{ subcategory.name }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <TagIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No categories</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new category.</p>
      <div class="mt-6">
        <button
          @click="openCreateCategoryModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <FolderPlusIcon class="w-5 h-5 mr-2" />
          Create Category
        </button>
      </div>
    </div>

    <!-- Create/Edit Category Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Category' : 'Create New Category' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label for="category-name" class="block text-sm font-medium text-gray-700">Category Name</label>
            <input
              id="category-name"
              type="text"
              v-model="formData.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label for="category-description" class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              id="category-description"
              v-model="formData.description"
              rows="2"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            ></textarea>
          </div>

          <div>
            <label for="category-color" class="block text-sm font-medium text-gray-700">Color</label>
            <div class="mt-1 flex gap-2">
              <input
                id="category-color"
                type="color"
                v-model="formData.color"
                class="h-9 w-16 rounded border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
              <input
                id="category-color-hex"
                type="text"
                v-model="formData.color"
                class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                pattern="#[0-9A-Fa-f]{6}"
                placeholder="#000000"
              />
            </div>
          </div>

          <div>
            <label for="category-parent" class="block text-sm font-medium text-gray-700">Parent Category</label>
            <select
              id="category-parent"
              v-model="formData.parent_id"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="">None (Top Level)</option>
              <option
                v-for="category in availableParentCategories"
                :key="category.id"
                :value="category.id"
              >
                {{ category.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Associated Tags</label>
            <div class="mt-2 space-y-2">
              <label
                v-for="tag in availableTags"
                :key="tag.id"
                :class="'inline-flex items-center mr-4'"
              >
                <input
                  type="checkbox"
                  :id="'tag-' + tag.id"
                  :value="tag.id"
                  v-model="formData.tag_ids"
                  class="rounded border-gray-300 text-green-600 focus:ring-green-500"
                />
                <span class="ml-2 text-sm text-gray-700">{{ tag.name }}</span>
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
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import {
  FolderIcon,
  FolderPlusIcon,
  FolderTreeIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  LayoutGridIcon,
  TagIcon,
} from 'lucide-vue-next';

const authStore = useAuthStore();
const loading = ref(false);
const error = ref(null);
const categories = ref([]);
const availableTags = ref([]);
const showModal = ref(false);
const isEditing = ref(false);

const formData = ref({
  id: '',
  name: '',
  description: '',
  color: '#4F46E5',
  parent_id: '',
  tag_ids: [] as string[]
});

const availableParentCategories = computed(() => {
  if (!isEditing.value) return categories.value;
  return categories.value.filter(c => c.id !== formData.value.id);
});

const fetchCategories = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('categories')
      .select(`
        *,
        subcategories:categories!parent_id(id, name),
        tags:category_tags(
          tag:tags(
            id,
            name
          )
        )
      `)
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;

    categories.value = data.map(category => ({
      ...category,
      item_count: 0, // Since category_items table doesn't exist in schema
      tags: category.tags.map(ct => ct.tag),
      subcategories: category.subcategories || []
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const fetchTags = async () => {
  try {
    const { data, error: fetchError } = await supabase
      .from('tags')
      .select('id, name')
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;
    availableTags.value = data;
  } catch (err) {
    console.error('Error fetching tags:', err);
  }
};

const getCategoryName = (categoryId: string) => {
  return categories.value.find(c => c.id === categoryId)?.name || '';
};

const openCreateCategoryModal = () => {
  isEditing.value = false;
  formData.value = {
    id: '',
    name: '',
    description: '',
    color: '#4F46E5',
    parent_id: '',
    tag_ids: []
  };
  showModal.value = true;
};

const editCategory = (category) => {
  isEditing.value = true;
  formData.value = {
    id: category.id,
    name: category.name,
    description: category.description || '',
    color: category.color,
    parent_id: category.parent_id || '',
    tag_ids: category.tags.map(t => t.id)
  };
  showModal.value = true;
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    const categoryData = {
      name: formData.value.name,
      description: formData.value.description,
      color: formData.value.color,
      parent_id: formData.value.parent_id || null,
      company_id: authStore.currentCompanyId
    };

    let categoryId;

    if (isEditing.value) {
      const { error: updateError } = await supabase
        .from('categories')
        .update(categoryData)
        .eq('id', formData.value.id);

      if (updateError) throw updateError;
      categoryId = formData.value.id;

      // Delete existing tag associations
      const { error: deleteError } = await supabase
        .from('category_tags')
        .delete()
        .eq('category_id', categoryId);

      if (deleteError) throw deleteError;
    } else {
      const { data: newCategory, error: insertError } = await supabase
        .from('categories')
        .insert(categoryData)
        .select()
        .single();

      if (insertError) throw insertError;
      categoryId = newCategory.id;
    }

    // Create new tag associations
    if (formData.value.tag_ids.length > 0) {
      const tagAssociations = formData.value.tag_ids.map(tagId => ({
        category_id: categoryId,
        tag_id: tagId
      }));

      const { error: tagError } = await supabase
        .from('category_tags')
        .insert(tagAssociations);

      if (tagError) throw tagError;
    }

    showModal.value = false;
    await fetchCategories();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteCategory = async (category) => {
  if (!confirm('Are you sure you want to delete this category? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('categories')
      .delete()
      .eq('id', category.id);

    if (err) throw err;
    await fetchCategories();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await Promise.all([fetchCategories(), fetchTags()]);
});
</script>