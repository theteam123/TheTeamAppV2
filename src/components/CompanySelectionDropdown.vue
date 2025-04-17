<template>
  <div class="relative">
    <!-- Selected Company Display -->
    <button
      type="button"
      @click="toggleDropdown"
      class="w-full bg-white relative flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-lg shadow-sm text-left focus:outline-none focus:ring-1 focus:ring-green-500 focus:border-green-500"
    >
      <BuildingIcon 
        v-if="!currentCompany?.logo_url"
        class="h-5 w-5 text-gray-400 flex-shrink-0"
      />
      <img
        v-else
        :src="currentCompany.logo_url"
        class="h-5 w-5 rounded flex-shrink-0"
        alt=""
      />
      <span class="flex-1 block truncate text-sm">
        {{ currentCompany?.name || 'Select Company' }}
      </span>
      <ChevronDownIcon
        class="h-4 w-4 text-gray-400 transition-transform"
        :class="{ 'rotate-180': isOpen }"
      />
    </button>

    <!-- Dropdown -->
    <div
      v-if="isOpen"
      class="absolute z-10 mt-1 w-full rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
    >
      <!-- Search Input -->
      <div class="px-3 py-2">
        <div class="relative">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search companies..."
            class="w-full pl-9 pr-3 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-green-500 focus:border-green-500"
          />
        </div>
      </div>

      <!-- Companies List -->
      <div class="max-h-60 overflow-auto">
        <div
          v-for="company in filteredCompanies"
          :key="company.id"
          @click="selectCompany(company)"
          class="relative cursor-pointer select-none py-2 px-3 hover:bg-gray-100"
          :class="{ 'bg-green-50': company.id === authStore.currentCompanyId }"
        >
          <div class="flex items-center">
            <BuildingIcon 
              v-if="!company.logo_url"
              class="h-5 w-5 text-gray-400 flex-shrink-0"
            />
            <img
              v-else
              :src="company.logo_url"
              class="h-5 w-5 rounded flex-shrink-0"
              alt=""
            />
            <span 
              class="ml-3 block truncate text-sm"
              :class="{ 'font-semibold': company.id === authStore.currentCompanyId }"
            >
              {{ company.name }}
            </span>
            <CheckIcon
              v-if="company.id === authStore.currentCompanyId"
              class="ml-auto h-4 w-4 text-green-600 flex-shrink-0"
            />
          </div>
        </div>

        <!-- Empty State -->
        <div
          v-if="filteredCompanies.length === 0"
          class="relative cursor-default select-none py-2 px-3 text-gray-500 text-sm"
        >
          No companies found
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import { BuildingIcon, CheckIcon, SearchIcon, ChevronDownIcon } from 'lucide-vue-next';

const authStore = useAuthStore();
const searchQuery = ref('');
const isOpen = ref(false);

const currentCompany = computed(() => 
  authStore.availableCompanies.find(company => company.id === authStore.currentCompanyId)
);

const filteredCompanies = computed(() => {
  if (!searchQuery.value) return authStore.availableCompanies;
  
  const query = searchQuery.value.toLowerCase();
  return authStore.availableCompanies.filter(company =>
    company.name.toLowerCase().includes(query)
  );
});

const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
  if (isOpen.value) {
    searchQuery.value = '';
  }
};

const selectCompany = async (company: { id: string; name: string }) => {
  if (company.id === authStore.currentCompanyId) {
    isOpen.value = false;
    return;
  }

  try {
    await authStore.setCurrentCompany(company.id);
    isOpen.value = false;
    searchQuery.value = '';
  } catch (error) {
    console.error('Error switching company:', error);
  }
};

// Close dropdown when clicking outside
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement;
  if (!target.closest('.relative')) {
    isOpen.value = false;
  }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});
</script>
```