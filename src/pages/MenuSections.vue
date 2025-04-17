<!-- Rename Categories.vue to MenuSections.vue with updated content -->
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

    <!-- Menu Sections Grid -->
    <div v-else-if="menuSections.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="section in menuSections"
        :key="section.id"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-center gap-3">
              <div
                class="w-8 h-8 rounded-lg flex items-center justify-center"
                :style="{ backgroundColor: section.color + '20' }"
              >
                <FolderIcon class="w-5 h-5" :style="{ color: section.color }" />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ section.name }}</h3>
                <p class="text-sm text-gray-500">{{ section.description }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <button
                @click="editSection(section)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteSection(section)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <div class="mt-4">
            <div class="flex items-center gap-2 text-sm text-gray-600">
              <LayoutGridIcon class="w-4 h-4" />
              <span>{{ section.item_count }} items</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <TagIcon class="w-4 h-4" />
              <span>{{ section.tags.length }} associated tags</span>
            </div>
            <div v-if="section.parent_id" class="flex items-center gap-2 text-sm text-gray-600 mt-1">
              <FolderTreeIcon class="w-4 h-4" />
              <span>Subsection of {{ getSectionName(section.parent_id) }}</span>
            </div>
          </div>

          <div v-if="section.subsections.length > 0" class="mt-4">
            <p class="text-sm font-medium text-gray-700 mb-2">Subsections:</p>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="subsection in section.subsections"
                :key="subsection.id"
                class="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800"
              >
                {{ subsection.name }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <FolderIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No menu sections</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new menu section.</p>
      <div class="mt-6">
        <button
          @click="openCreateSectionModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <FolderPlusIcon class="w-5 h-5 mr-2" />
          Create Menu Section
        </button>
      </div>
    </div>

    <!-- Create/Edit Menu Section Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Edit Menu Section' : 'Create New Menu Section' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label for="section-name" class="block text-sm font-medium text-gray-700">Section Name</label>
            <input
              id="section-name"
              type="text"
              v-model="formData.name"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label for="section-description" class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              id="section-description"
              v-model="formData.description"
              rows="2"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            ></textarea>
          </div>

          <div>
            <label for="section-color" class="block text-sm font-medium text-gray-700">Color</label>
            <div class="mt-1 flex gap-2">
              <input
                id="section-color"
                type="color"
                v-model="formData.color"
                class="h-9 w-16 rounded border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
              <input
                id="section-color-hex"
                type="text"
                v-model="formData.color"
                class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                pattern="#[0-9A-Fa-f]{6}"
                placeholder="#000000"
              />
            </div>
          </div>

          <div>
            <label for="section-parent" class="block text-sm font-medium text-gray-700">Parent Section</label>
            <select
              id="section-parent"
              v-model="formData.parent_id"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="">None (Top Level)</option>
              <option
                v-for="section in availableParentSections"
                :key="section.id"
                :value="section.id"
              >
                {{ section.name }}
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
const menuSections = ref([]);
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

const availableParentSections = computed(() => {
  if (!isEditing.value) return menuSections.value;
  return menuSections.value.filter(c => c.id !== formData.value.id);
});

const fetchMenuSections = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('menu_sections')
      .select(`
        *,
        subsections:menu_sections!parent_id(id, name),
        tags:menu_section_tags(
          tag:tags(
            id,
            name
          )
        )
      `)
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;

    menuSections.value = data.map(section => ({
      ...section,
      item_count: 0,
      tags: section.tags.map(ct => ct.tag),
      subsections: section.subsections || []
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

const getSectionName = (sectionId: string) => {
  return menuSections.value.find(s => s.id === sectionId)?.name || '';
};

const openCreateSectionModal = () => {
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

const editSection = (section) => {
  isEditing.value = true;
  formData.value = {
    id: section.id,
    name: section.name,
    description: section.description || '',
    color: section.color,
    parent_id: section.parent_id || '',
    tag_ids: section.tags.map(t => t.id)
  };
  showModal.value = true;
};

const handleSubmit = async () => {
  loading.value = true;
  try {
    const sectionData = {
      name: formData.value.name,
      description: formData.value.description,
      color: formData.value.color,
      parent_id: formData.value.parent_id || null,
      company_id: authStore.currentCompanyId
    };

    let sectionId;

    if (isEditing.value) {
      const { error: updateError } = await supabase
        .from('menu_sections')
        .update(sectionData)
        .eq('id', formData.value.id);

      if (updateError) throw updateError;
      sectionId = formData.value.id;

      // Delete existing tag associations
      const { error: deleteError } = await supabase
        .from('menu_section_tags')
        .delete()
        .eq('menu_section_id', sectionId);

      if (deleteError) throw deleteError;
    } else {
      const { data: newSection, error: insertError } = await supabase
        .from('menu_sections')
        .insert(sectionData)
        .select()
        .single();

      if (insertError) throw insertError;
      sectionId = newSection.id;
    }

    // Create new tag associations
    if (formData.value.tag_ids.length > 0) {
      const tagAssociations = formData.value.tag_ids.map(tagId => ({
        menu_section_id: sectionId,
        tag_id: tagId
      }));

      const { error: tagError } = await supabase
        .from('menu_section_tags')
        .insert(tagAssociations);

      if (tagError) throw tagError;
    }

    showModal.value = false;
    await fetchMenuSections();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteSection = async (section) => {
  if (!confirm('Are you sure you want to delete this menu section? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('menu_sections')
      .delete()
      .eq('id', section.id);

    if (err) throw err;
    await fetchMenuSections();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await Promise.all([fetchMenuSections(), fetchTags()]);
});
</script>