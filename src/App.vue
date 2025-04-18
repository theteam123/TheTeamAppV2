<template>
  <div class="min-h-screen bg-gray-50">
    <ErrorBoundary>
      <div v-if="!authStore.loading">
        <div v-if="authStore.isAuthenticated" class="flex h-screen">
          <!-- Sidebar -->
          <aside class="w-64 bg-white border-r border-gray-200 flex flex-col">
            <!-- Logo -->
            <div class="flex items-center justify-start h-16 px-4 border-b border-gray-200">
              <TeamLogo :height="48" />
            </div>
            
            <!-- Search Bar -->
            <div class="px-4 py-3 border-b border-gray-200">
              <div class="relative">
                <input
                  v-model="searchInput"
                  type="text"
                  placeholder="Search content..."
                  class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <div
                  v-if="showSearchResults"
                  class="absolute z-50 w-full mt-2 bg-white border rounded-lg shadow-lg"
                >
                  <div v-if="searchLoading" class="p-4 text-center text-gray-500">
                    Loading...
                  </div>
                  <div v-else-if="searchResults.length === 0" class="p-4 text-center text-gray-500">
                    No results found
                  </div>
                  <div v-else class="max-h-96 overflow-y-auto">
                    <router-link
                      v-for="result in searchResults"
                      :key="result.id"
                      :to="result.url"
                      class="block p-4 hover:bg-gray-100"
                      @click="showSearchResults = false"
                    >
                      <div class="font-medium">{{ result.title }}</div>
                      <div class="text-sm text-gray-600">{{ result.description }}</div>
                    </router-link>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Navigation -->
            <nav class="flex-1 p-4 space-y-1">
              <router-link 
                to="/" 
                class="flex items-center px-4 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100"
                :class="{ 'bg-green-50 text-green-700': $route.path === '/' }"
              >
                <HomeIcon class="w-5 h-5 mr-3" />
                Home
              </router-link>
            </nav>

            <!-- Admin Settings Section -->
            <div class="p-4 border-t border-gray-200">
              <details class="group">
                <summary class="flex items-center px-4 py-2 text-sm font-medium text-gray-700 cursor-pointer hover:bg-gray-100 rounded-lg">
                  <SettingsIcon class="w-5 h-5 mr-3" />
                  Admin Settings
                  <ChevronDownIcon class="w-4 h-4 ml-auto transition-transform group-open:rotate-180" />
                </summary>
                <div class="mt-1 space-y-1">
                  <router-link 
                    v-for="item in adminItems" 
                    :key="item.path"
                    :to="item.path"
                    class="flex items-center px-4 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 pl-12"
                    :class="{ 'bg-green-50 text-green-700': $route.path === item.path }"
                  >
                    <component :is="item.icon" class="w-5 h-5 mr-3" />
                    {{ item.name }}
                  </router-link>
                </div>
              </details>
            </div>

            <!-- User Menu -->
            <div class="border-t border-gray-200">
              <div class="p-4">
                <div class="flex items-center">
                  <div class="flex-shrink-0">
                    <img
                      :src="authStore.user?.profile?.avatar_url || 'https://www.gravatar.com/avatar/?d=mp'"
                      class="h-8 w-8 rounded-full"
                      alt=""
                    />
                  </div>
                  <div class="ml-3">
                    <p class="text-sm font-medium text-gray-900">
                      {{ authStore.user?.profile?.full_name }}
                    </p>
                    <div class="flex items-center gap-2">
                      <span class="text-xs font-medium px-2 py-0.5 rounded-full"
                        :class="roleColorClass"
                      >
                        {{ authStore.userRole }}
                      </span>
                      <button
                        @click="handleSignOut"
                        class="text-sm font-medium text-gray-500 hover:text-gray-700"
                      >
                        Sign out
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </aside>

          <div class="flex-1 flex flex-col">
            <!-- Header -->
            <header class="bg-white border-b border-gray-200">
              <div class="flex items-center justify-between h-16 px-8">
                <div>
                  <h1 class="text-2xl font-semibold text-gray-900">
                    {{ currentPageTitle }}
                  </h1>
                  <p v-if="currentPageDescription" class="text-sm text-gray-500">
                    {{ currentPageDescription }}
                  </p>
                </div>
                <div class="w-64">
                  <CompanySelectionDropdown />
                </div>
              </div>
            </header>

            <!-- Main Content -->
            <main class="flex-1 overflow-auto">
              <router-view></router-view>
            </main>
          </div>
        </div>
        <router-view v-else></router-view>
      </div>
      <div v-else class="min-h-screen flex items-center justify-center">
        <div class="text-center">
          <LoadingSpinner class="w-8 h-8 mx-auto text-gray-400" />
          <p class="mt-4 text-gray-500">Loading application...</p>
        </div>
      </div>
    </ErrorBoundary>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted, onBeforeMount } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { useDebounce } from '@/composables/useDebounce';
import { useContentSearch } from '@/composables/useContentSearch';
import CompanySelectionDropdown from '@/components/CompanySelectionDropdown.vue';
import ErrorBoundary from '@/components/ErrorBoundary.vue';
import LoadingSpinner from '@/components/LoadingSpinner.vue';
import { TeamLogo } from '@/components';
import { 
  HomeIcon,
  FileIcon,
  SettingsIcon,
  UsersIcon,
  BuildingIcon,
  ShieldIcon,
  FileEditIcon,
  TagIcon,
  FolderIcon,
  ChevronDownIcon,
  SearchIcon,
  BookIcon,
  BugIcon
} from 'lucide-vue-next';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const { searchContent } = useContentSearch();

const searchInput = ref('');
const debouncedSearchQuery = ref('');
const showSearchResults = ref(false);
const searchResults = ref<SearchResult[]>([]);
const searchLoading = ref(false);

const adminItems = [
  { name: 'Users', path: '/admin/users', icon: UsersIcon, description: 'Manage users and their roles within your organization' },
  { name: 'Companies', path: '/admin/companies', icon: BuildingIcon, description: "Manage your organization's companies and their settings" },
  { name: 'Roles', path: '/admin/roles', icon: ShieldIcon, description: 'Configure and manage user roles and permissions' },
  { name: 'Content', path: '/admin/content', icon: FileEditIcon, description: 'Organize and manage all content types' },
  { name: 'Tags', path: '/admin/tags', icon: TagIcon, description: 'Manage and organize content tags' },
  { name: 'Menu Sections', path: '/admin/menu-sections', icon: FolderIcon, description: 'Manage menu sections and hierarchies' },
  { name: 'Debug', path: '/admin/debug', icon: BugIcon, description: 'View debug information and system status' },
];

const allMenuItems = [...adminItems];

const currentPageTitle = computed(() => {
  if (route.path === '/') return 'Welcome';
  const currentItem = adminItems.find(item => item.path === route.path);
  return currentItem?.name || 'TheTeam';
});

const currentPageDescription = computed(() => {
  if (route.path === '/') return '';
  const currentItem = adminItems.find(item => item.path === route.path);
  return currentItem?.description || '';
});

const filteredMenuItems = computed(() => {
  if (!debouncedSearchQuery.value) return [];
  const query = debouncedSearchQuery.value.toLowerCase();
  return allMenuItems.filter(item => 
    item.name && item.name.toLowerCase().includes(query)
  );
});

const roleColorClass = computed(() => {
  const role = authStore.userRole;
  switch (role) {
    case 'SuperAdmin':
      return 'bg-purple-100 text-purple-800';
    case 'Manager':
      return 'bg-blue-100 text-blue-800';
    case 'User':
      return 'bg-gray-100 text-gray-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
});

const handleSearchBlur = () => {
  // Delay hiding results to allow clicking them
  setTimeout(() => {
    showSearchResults.value = false;
  }, 200);
};

const handleMenuItemClick = (item) => {
  router.push(item.path);
  searchInput.value = '';
  showSearchResults.value = false;
};

const handleSearchResultClick = (result) => {
  // Navigate to the appropriate page based on content type
  const path = `/${result.type.toLowerCase()}s/${result.id}`;
  router.push(path);
  searchInput.value = '';
  showSearchResults.value = false;
};

const getContentIcon = (type: string) => {
  switch (type?.toLowerCase()) {
    case 'policy':
      return BookIcon;
    default:
      return FileIcon;
  }
};

watch(searchInput, (newValue) => {
  debouncedSearchQuery.value = newValue;
});

watch(debouncedSearchQuery, async (newQuery) => {
  if (!newQuery || typeof newQuery !== 'string') {
    searchResults.value = [];
    showSearchResults.value = false;
    return;
  }

  searchLoading.value = true;
  try {
    const results = await searchContent(newQuery);
    searchResults.value = results;
    showSearchResults.value = true;
  } catch (error) {
    console.error('Search error:', error);
    searchResults.value = [];
  } finally {
    searchLoading.value = false;
  }
});

watch(route, () => {
  searchInput.value = '';
  showSearchResults.value = false;
  searchResults.value = [];
});

const handleSignOut = async () => {
  await authStore.signOut();
  router.push('/auth');
};

onBeforeMount(() => {
  console.log('[App Debug] Before mount:', {
    isAuthenticated: authStore.isAuthenticated,
    loading: authStore.loading,
    timestamp: new Date().toISOString()
  });
});

onMounted(() => {
  console.log('[App Debug] Mounted:', {
    isAuthenticated: authStore.isAuthenticated,
    loading: authStore.loading,
    timestamp: new Date().toISOString()
  });
});
</script>

<style>
details > summary {
  list-style: none;
}
details > summary::-webkit-details-marker {
  display: none;
}
</style>