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

    <!-- Content List -->
    <div v-else-if="content.length > 0" class="space-y-6">
      <div
        v-for="item in content"
        :key="item.id"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="p-6">
          <div class="flex justify-between items-start">
            <div class="flex items-start gap-3">
              <div
                class="p-2 rounded-lg"
                :class="getContentTypeClass(item.content_type)"
              >
                <component
                  :is="getContentTypeIcon(item.content_type)"
                  class="w-8 h-8"
                  :class="getContentTypeIconClass(item.content_type)"
                />
              </div>
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ item.name }}</h3>
                <p class="text-sm text-gray-500 mt-1">{{ item.description }}</p>
              </div>
            </div>
            <div class="flex gap-2">
              <a
                :href="item.url"
                target="_blank"
                rel="noopener noreferrer"
                class="text-gray-400 hover:text-gray-600"
              >
                <ExternalLinkIcon class="w-5 h-5" />
              </a>
              <button
                @click="editContent(item)"
                class="text-gray-400 hover:text-gray-600"
              >
                <PencilIcon class="w-5 h-5" />
              </button>
              <button
                @click="deleteContent(item)"
                class="text-gray-400 hover:text-red-600"
              >
                <TrashIcon class="w-5 h-5" />
              </button>
            </div>
          </div>

          <!-- Tags and Categories -->
          <div class="mt-4">
            <div class="flex flex-wrap gap-2">
              <span
                v-for="tag in item.tags"
                :key="tag.id"
                class="px-2 py-1 text-xs font-medium rounded-full"
                :style="{
                  backgroundColor: tag.color + '20',
                  color: tag.color
                }"
              >
                {{ tag.name }}
              </span>
            </div>
          </div>

          <!-- Metadata -->
          <div class="mt-4 grid grid-cols-2 gap-4 text-sm text-gray-500">
            <div class="flex items-center gap-2">
              <ClockIcon class="w-4 h-4" />
              <span>Updated {{ formatDate(item.updated_at) }}</span>
            </div>
            <div class="flex items-center gap-2">
              <CalendarIcon class="w-4 h-4" />
              <span>Created {{ formatDate(item.created_at) }}</span>
            </div>
            <div class="flex items-center gap-2">
              <UserIcon class="w-4 h-4" />
              <span>{{ item.updated_by_name }}</span>
            </div>
            <div class="flex items-center gap-2">
              <FileTypeIcon class="w-4 h-4" />
              <span>{{ item.content_type }}</span>
            </div>
          </div>

          <!-- Role Permissions -->
          <div class="mt-4 border-t pt-4">
            <h4 class="text-sm font-medium text-gray-700 mb-2">Access Permissions</h4>
            <div class="flex flex-wrap gap-2">
              <div
                v-for="(permission, roleId) in item.role_permissions"
                :key="roleId"
                class="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800"
              >
                {{ getRoleName(roleId) }}: 
                {{ permission.view ? 'View' : '' }}
                {{ permission.view && permission.edit ? '& ' : '' }}
                {{ permission.edit ? 'Edit' : '' }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <FileIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-gray-900">No content</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by adding new content.</p>
      <div class="mt-6">
        <button
          @click="openCreateContentModal"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        >
          <FileEditIcon class="w-5 h-5 mr-2" />
          Add Content
        </button>
      </div>
    </div>

    <!-- Create/Edit Content Modal -->
    <ContentFormModal
      v-if="showModal"
      :isEditing="isEditing"
      :contentData="selectedContent"
      @close="closeModal"
      @submit="handleSubmit"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import { format } from 'date-fns';
import ContentFormModal from '../../components/ContentFormModal.vue';
import {
  FileEditIcon,
  FileIcon,
  ImageIcon,
  VideoIcon,
  LinkIcon,
  FileTextIcon,
  PencilIcon,
  TrashIcon,
  LoaderIcon,
  ClockIcon,
  CalendarIcon,
  UserIcon,
  FileTypeIcon,
  ExternalLinkIcon,
  PlusSquareIcon,
  XIcon
} from 'lucide-vue-next';

const authStore = useAuthStore();
const loading = ref(false);
const error = ref(null);
const content = ref([]);
const showModal = ref(false);
const isEditing = ref(false);
const selectedContent = ref(null);
const roles = ref([]);

const fetchContent = async () => {
  if (!authStore.currentCompanyId) return;
  
  loading.value = true;
  try {
    const { data, error: fetchError } = await supabase
      .from('content')
      .select(`
        *,
        profiles:updated_by (
          full_name
        ),
        content_tags!content_id (
          tag:tag_id (
            id,
            name,
            color
          )
        )
      `)
      .eq('company_id', authStore.currentCompanyId)
      .order('updated_at', { ascending: false });

    if (fetchError) throw fetchError;

    content.value = data.map(item => ({
      ...item,
      updated_by_name: item.profiles?.full_name || 'Unknown',
      tags: item.content_tags.map(ct => ct.tag)
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const fetchRoles = async () => {
  if (!authStore.currentCompanyId) return;
  
  try {
    const { data, error: fetchError } = await supabase
      .from('roles')
      .select('*')
      .eq('company_id', authStore.currentCompanyId);

    if (fetchError) throw fetchError;
    roles.value = data || [];
  } catch (err) {
    console.error('Error fetching roles:', err);
    error.value = 'Error loading roles. Please try again later.';
  }
};

const getRoleName = (roleId: string) => {
  const role = roles.value.find(r => r.id === roleId);
  return role?.name || 'Unknown Role';
};

const getContentTypeClass = (type: string) => {
  switch (type?.toLowerCase()) {
    case 'image':
      return 'bg-purple-50';
    case 'video':
      return 'bg-blue-50';
    case 'link':
      return 'bg-yellow-50';
    default:
      return 'bg-green-50';
  }
};

const getContentTypeIcon = (type: string) => {
  switch (type?.toLowerCase()) {
    case 'image':
      return ImageIcon;
    case 'video':
      return VideoIcon;
    case 'link':
      return LinkIcon;
    default:
      return FileTextIcon;
  }
};

const getContentTypeIconClass = (type: string) => {
  switch (type?.toLowerCase()) {
    case 'image':
      return 'text-purple-600';
    case 'video':
      return 'text-blue-600';
    case 'link':
      return 'text-yellow-600';
    default:
      return 'text-green-600';
  }
};

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy h:mm a');
};

const openCreateContentModal = () => {
  isEditing.value = false;
  selectedContent.value = null;
  showModal.value = true;
};

const editContent = (item) => {
  isEditing.value = true;
  selectedContent.value = item;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedContent.value = null;
};

const handleSubmit = async (formData) => {
  loading.value = true;
  try {
    const contentData = {
      name: formData.name,
      url: formData.url,
      description: formData.description,
      content_type: formData.contentType,
      tags: formData.tags,
      role_permissions: formData.rolePermissions,
      company_id: authStore.currentCompanyId,
      updated_by: authStore.user?.id
    };

    if (isEditing.value && selectedContent.value) {
      const { error: updateError } = await supabase
        .from('content')
        .update(contentData)
        .eq('id', selectedContent.value.id);

      if (updateError) throw updateError;
    } else {
      const { error: insertError } = await supabase
        .from('content')
        .insert(contentData);

      if (insertError) throw insertError;
    }

    closeModal();
    await fetchContent();
  } catch (err: any) {
    console.error('Error saving content:', err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const deleteContent = async (item) => {
  if (!confirm('Are you sure you want to delete this content? This action cannot be undone.')) return;

  loading.value = true;
  try {
    const { error: err } = await supabase
      .from('content')
      .delete()
      .eq('id', item.id);

    if (err) throw err;
    await fetchContent();
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await Promise.all([fetchContent(), fetchRoles()]);
});
</script>