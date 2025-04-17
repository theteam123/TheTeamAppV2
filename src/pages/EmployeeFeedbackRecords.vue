<template>
  <div class="p-8">
    <!-- Header Section -->
    <div class="flex justify-between items-start mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Employee Feedback Records</h1>
        <p class="mt-1 text-sm text-gray-500">Manage and track employee feedback and performance reviews</p>
      </div>
      <button
        @click="openNewFeedbackModal"
        class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2"
      >
        <PlusIcon class="w-5 h-5" />
        New Feedback
      </button>
    </div>

    <!-- Search and Filters -->
    <div class="mb-6 space-y-4">
      <!-- Global Search -->
      <div class="relative">
        <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Search feedback records..."
          class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
        />
      </div>

      <!-- Filter Panel -->
      <div class="bg-white rounded-lg shadow p-4">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-sm font-medium text-gray-700">Filters</h2>
          <button
            @click="isFilterPanelExpanded = !isFilterPanelExpanded"
            class="text-sm text-gray-500 hover:text-gray-700 flex items-center gap-1"
          >
            {{ isFilterPanelExpanded ? 'Collapse' : 'Expand' }}
            <ChevronDownIcon
              class="w-4 h-4 transition-transform"
              :class="{ 'rotate-180': isFilterPanelExpanded }"
            />
          </button>
        </div>

        <div v-show="isFilterPanelExpanded" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Date Range -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date Range</label>
              <div class="flex gap-2">
                <input
                  type="date"
                  v-model="filters.dateFrom"
                  class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
                <input
                  type="date"
                  v-model="filters.dateTo"
                  class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
              </div>
            </div>

            <!-- Status -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select
                v-model="filters.status"
                multiple
                class="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              >
                <option value="Pending">Pending</option>
                <option value="In Review">In Review</option>
                <option value="Completed">Completed</option>
              </select>
            </div>

            <!-- Rating Range -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Rating Range</label>
              <div class="flex items-center gap-2">
                <input
                  type="number"
                  v-model="filters.ratingMin"
                  min="1"
                  max="5"
                  class="w-20 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
                <span class="text-gray-500">to</span>
                <input
                  type="number"
                  v-model="filters.ratingMax"
                  min="1"
                  max="5"
                  class="w-20 rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
              </div>
            </div>
          </div>

          <!-- Advanced Filter Options -->
          <div class="border-t pt-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <select
                  v-model="filters.searchLogic"
                  class="rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                >
                  <option value="AND">Match All (AND)</option>
                  <option value="OR">Match Any (OR)</option>
                </select>
                <button
                  @click="clearFilters"
                  class="text-sm text-gray-500 hover:text-gray-700"
                >
                  Clear All
                </button>
              </div>
              <button
                @click="applyFilters"
                class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm"
              >
                Apply Filters
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Saved Searches -->
      <div class="flex items-center gap-4">
        <select
          v-model="selectedSavedSearch"
          class="rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          <option value="">Load Saved Search</option>
          <option v-for="search in savedSearches" :key="search.id" :value="search.id">
            {{ search.name }}
          </option>
        </select>
        <button
          @click="saveCurrentSearch"
          class="text-sm text-green-600 hover:text-green-700"
        >
          Save Current Search
        </button>
      </div>
    </div>

    <!-- Data Grid -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                v-for="column in visibleColumns"
                :key="column.id"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                :style="column.width ? { width: column.width } : {}"
              >
                <div class="flex items-center gap-2">
                  <span>{{ column.label || column.id }}</span>
                  <button
                    v-if="column.sortable"
                    @click="toggleSort(column.id)"
                    class="text-gray-400 hover:text-gray-600"
                  >
                    <ArrowUpDownIcon class="w-4 h-4" />
                  </button>
                </div>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="record in paginatedRecords" :key="record.id">
              <td
                v-for="column in visibleColumns"
                :key="column.id"
                class="px-6 py-4 whitespace-nowrap"
              >
                <!-- Action Column -->
                <div v-if="column.type === 'button'" class="flex gap-2">
                  <button
                    @click="editRecord(record)"
                    class="text-green-600 hover:text-green-700"
                  >
                    <PencilIcon class="w-5 h-5" />
                  </button>
                  <button
                    @click="deleteRecord(record)"
                    class="text-red-600 hover:text-red-700"
                  >
                    <TrashIcon class="w-5 h-5" />
                  </button>
                </div>

                <!-- Date Column -->
                <span v-else-if="column.type === 'date'">
                  {{ formatDate(record[column.id]) }}
                </span>

                <!-- Rating Column -->
                <div v-else-if="column.type === 'number' && column.component === 'StarRating'">
                  <div class="flex items-center gap-1">
                    <StarIcon
                      v-for="i in 5"
                      :key="i"
                      class="w-5 h-5"
                      :class="i <= record[column.id] ? 'text-yellow-400' : 'text-gray-200'"
                    />
                  </div>
                </div>

                <!-- Status Badge -->
                <span
                  v-else-if="column.type === 'badge'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                  :class="getStatusClass(record[column.id])"
                >
                  {{ record[column.id] }}
                </span>

                <!-- Text Column (with truncation) -->
                <div
                  v-else
                  class="text-sm text-gray-900"
                  :class="{ 'truncate max-w-xs': column.truncate }"
                >
                  {{ record[column.id] }}
                  <button
                    v-if="column.expandable && record[column.id].length > 50"
                    @click="toggleExpandedText(record.id, column.id)"
                    class="ml-2 text-xs text-green-600 hover:text-green-700"
                  >
                    {{ isTextExpanded(record.id, column.id) ? 'Show Less' : 'Show More' }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
        <div class="flex-1 flex justify-between sm:hidden">
          <button
            @click="previousPage"
            :disabled="currentPage === 1"
            class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Previous
          </button>
          <button
            @click="nextPage"
            :disabled="currentPage === totalPages"
            class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Next
          </button>
        </div>
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700">
              Showing
              <span class="font-medium">{{ paginationStart }}</span>
              to
              <span class="font-medium">{{ paginationEnd }}</span>
              of
              <span class="font-medium">{{ totalRecords }}</span>
              results
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button
                @click="previousPage"
                :disabled="currentPage === 1"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                <span class="sr-only">Previous</span>
                <ChevronLeftIcon class="h-5 w-5" />
              </button>
              <button
                v-for="page in displayedPages"
                :key="page"
                @click="goToPage(page)"
                :class="[
                  page === currentPage ? 'z-10 bg-green-50 border-green-500 text-green-600' : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50',
                  'relative inline-flex items-center px-4 py-2 border text-sm font-medium'
                ]"
              >
                {{ page }}
              </button>
              <button
                @click="nextPage"
                :disabled="currentPage === totalPages"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                <span class="sr-only">Next</span>
                <ChevronRightIcon class="h-5 w-5" />
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { format } from 'date-fns';
import {
  PlusIcon,
  SearchIcon,
  ChevronDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  ArrowUpDownIcon,
  PencilIcon,
  TrashIcon,
  StarIcon
} from 'lucide-vue-next';

// State
const searchQuery = ref('');
const isFilterPanelExpanded = ref(false);
const currentPage = ref(1);
const pageSize = 20;
const expandedTextCells = ref(new Set());
const selectedSavedSearch = ref('');

const filters = ref({
  dateFrom: '',
  dateTo: '',
  status: [] as string[],
  ratingMin: 1,
  ratingMax: 5,
  searchLogic: 'AND'
});

const savedSearches = ref([
  { id: 1, name: 'Recent High Ratings' },
  { id: 2, name: 'Pending Reviews' },
  { id: 3, name: 'Last Month Reviews' }
]);

// Column definitions
const columns = [
  { id: 'action', type: 'button', width: '80px' },
  { id: 'date', type: 'date', sortable: true, label: 'Date' },
  { id: 'fullName', type: 'string', sortable: true, label: 'Employee Name' },
  { id: 'rating', type: 'number', component: 'StarRating', label: 'Rating' },
  { id: 'status', type: 'badge', options: ['Pending', 'Completed', 'In Review'], label: 'Status' },
  { id: 'recommendation', type: 'text', truncate: true, label: 'Recommendation' },
  { id: 'comments', type: 'text', truncate: true, expandable: true, label: 'Comments' }
];

// Sample data
const records = ref([
  {
    id: 1,
    date: '2025-04-15',
    fullName: 'John Doe',
    rating: 4,
    status: 'Completed',
    recommendation: 'Recommended for promotion',
    comments: 'Excellent performance throughout the year. Shows great leadership potential and consistently delivers high-quality work.'
  },
  // Add more sample records here
]);

// Computed properties
const visibleColumns = computed(() => columns);

const filteredRecords = computed(() => {
  let filtered = [...records.value];

  // Apply search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(record => 
      record.fullName.toLowerCase().includes(query) ||
      record.recommendation.toLowerCase().includes(query) ||
      record.comments.toLowerCase().includes(query)
    );
  }

  // Apply filters
  if (filters.value.dateFrom) {
    filtered = filtered.filter(record => record.date >= filters.value.dateFrom);
  }
  if (filters.value.dateTo) {
    filtered = filtered.filter(record => record.date <= filters.value.dateTo);
  }
  if (filters.value.status.length > 0) {
    filtered = filtered.filter(record => filters.value.status.includes(record.status));
  }
  if (filters.value.ratingMin) {
    filtered = filtered.filter(record => record.rating >= filters.value.ratingMin);
  }
  if (filters.value.ratingMax) {
    filtered = filtered.filter(record => record.rating <= filters.value.ratingMax);
  }

  return filtered;
});

const paginatedRecords = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  const end = start + pageSize;
  return filteredRecords.value.slice(start, end);
});

const totalRecords = computed(() => filteredRecords.value.length);
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize));
const paginationStart = computed(() => ((currentPage.value - 1) * pageSize) + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * pageSize, totalRecords.value));

const displayedPages = computed(() => {
  const total = totalPages.value;
  const current = currentPage.value;
  const pages = [];

  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    if (current <= 3) {
      for (let i = 1; i <= 5; i++) pages.push(i);
      pages.push('...');
      pages.push(total);
    } else if (current >= total - 2) {
      pages.push(1);
      pages.push('...');
      for (let i = total - 4; i <= total; i++) pages.push(i);
    } else {
      pages.push(1);
      pages.push('...');
      for (let i = current - 1; i <= current + 1; i++) pages.push(i);
      pages.push('...');
      pages.push(total);
    }
  }

  return pages;
});

// Methods
const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy');
};

const getStatusClass = (status: string) => {
  switch (status) {
    case 'Pending':
      return 'bg-yellow-100 text-yellow-800';
    case 'Completed':
      return 'bg-green-100 text-green-800';
    case 'In Review':
      return 'bg-blue-100 text-blue-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

const toggleSort = (columnId: string) => {
  // Implement sorting logic
};

const toggleExpandedText = (recordId: number, columnId: string) => {
  const key = `${recordId}-${columnId}`;
  if (expandedTextCells.value.has(key)) {
    expandedTextCells.value.delete(key);
  } else {
    expandedTextCells.value.add(key);
  }
};

const isTextExpanded = (recordId: number, columnId: string) => {
  return expandedTextCells.value.has(`${recordId}-${columnId}`);
};

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const goToPage = (page: number) => {
  if (typeof page === 'number') {
    currentPage.value = page;
  }
};

const clearFilters = () => {
  filters.value = {
    dateFrom: '',
    dateTo: '',
    status: [],
    ratingMin: 1,
    ratingMax: 5,
    searchLogic: 'AND'
  };
};

const applyFilters = () => {
  currentPage.value = 1;
  // Additional filter application logic if needed
};

const saveCurrentSearch = () => {
  // Implement save search logic
};

const openNewFeedbackModal = () => {
  // Implement new feedback modal logic
};

const editRecord = (record: any) => {
  // Implement edit record logic
};

const deleteRecord = (record: any) => {
  // Implement delete record logic
};
</script>

<style scoped>
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>