<template>
  <div v-if="error" class="p-4 bg-red-50 rounded-lg">
    <div class="flex">
      <div class="flex-shrink-0">
        <AlertTriangleIcon class="h-5 w-5 text-red-400" />
      </div>
      <div class="ml-3">
        <h3 class="text-sm font-medium text-red-800">Something went wrong</h3>
        <div class="mt-2 text-sm text-red-700">
          <p>{{ error.message }}</p>
        </div>
        <div class="mt-4">
          <div class="-mx-2 -my-1.5 flex">
            <button
              type="button"
              @click="resetError"
              class="rounded-md bg-red-50 px-2 py-1.5 text-sm font-medium text-red-800 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-red-600 focus:ring-offset-2 focus:ring-offset-red-50"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
  <slot v-else></slot>
</template>

<script setup lang="ts">
import { ref, onErrorCaptured } from 'vue';
import { AlertTriangleIcon } from 'lucide-vue-next';

const error = ref<Error | null>(null);

onErrorCaptured((err) => {
  error.value = err;
  return false; // Prevent error from propagating further
});

function resetError() {
  error.value = null;
}
</script> 