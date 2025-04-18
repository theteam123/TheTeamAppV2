<template>
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
    <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4">
      <div class="p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-medium text-gray-900">
            Status History for {{ user?.full_name }}
          </h3>
          <button
            @click="$emit('close')"
            class="text-gray-400 hover:text-gray-500"
          >
            <XIcon class="h-6 w-6" />
          </button>
        </div>

        <div v-if="loading" class="flex justify-center py-8">
          <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
        </div>

        <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-4">
          {{ error }}
        </div>

        <div v-else-if="statusHistory.length === 0" class="text-center py-8 text-gray-500">
          No status history available
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="(entry, index) in statusHistory"
            :key="index"
            class="flex items-start space-x-4 p-4 bg-gray-50 rounded-lg"
          >
            <div class="flex-shrink-0">
              <span
                class="px-2 py-1 text-xs font-semibold rounded-full"
                :class="{
                  'bg-green-100 text-green-800': entry.new_status === 'active',
                  'bg-gray-100 text-gray-800': entry.new_status === 'inactive',
                  'bg-yellow-100 text-yellow-800': entry.new_status === 'pending',
                  'bg-blue-100 text-blue-800': entry.new_status === 'invited'
                }"
              >
                {{ entry.new_status }}
              </span>
            </div>
            <div class="flex-1">
              <div class="text-sm text-gray-900">
                Changed from
                <span class="font-medium">{{ entry.previous_status || 'N/A' }}</span>
                to
                <span class="font-medium">{{ entry.new_status }}</span>
              </div>
              <div class="text-xs text-gray-500">
                {{ formatDate(entry.created_at) }}
              </div>
              <div v-if="entry.changed_by" class="text-xs text-gray-500 mt-1">
                Changed by: {{ entry.changed_by }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '../../lib/supabase';
import { format } from 'date-fns';
import { LoaderIcon, XIcon } from 'lucide-vue-next';
import type { CompanyUser } from '../../lib/types';

const props = defineProps<{
  user: CompanyUser | null;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
}>();

const loading = ref(true);
const error = ref<string | null>(null);
const statusHistory = ref<any[]>([]);

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy h:mm a');
};

const fetchStatusHistory = async () => {
  if (!props.user) return;

  try {
    loading.value = true;
    error.value = null;

    const { data, error: fetchError } = await supabase
      .from('audit_log')
      .select(`
        id,
        created_at,
        previous_status,
        new_status,
        changed_by:profiles(full_name)
      `)
      .eq('user_id', props.user.id)
      .eq('action', 'status_change')
      .order('created_at', { ascending: false });

    if (fetchError) throw fetchError;

    statusHistory.value = data.map(entry => ({
      ...entry,
      changed_by: entry.changed_by?.full_name
    }));
  } catch (err) {
    console.error('Error fetching status history:', err);
    error.value = err instanceof Error ? err.message : 'Failed to fetch status history';
  } finally {
    loading.value = false;
  }
};

onMounted(fetchStatusHistory);
</script> 