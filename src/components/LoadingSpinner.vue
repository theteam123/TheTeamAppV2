<template>
  <div class="flex items-center justify-center p-4" :class="{ 'min-h-[200px]': fullHeight }">
    <div class="animate-spin rounded-full h-8 w-8 border-b-2" :class="colorClass"></div>
    <span v-if="text" class="ml-3 text-sm text-gray-500">{{ text }}</span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  text?: string;
  fullHeight?: boolean;
  variant?: 'primary' | 'secondary' | 'success' | 'danger';
}>();

const colorClass = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'border-indigo-500';
    case 'secondary':
      return 'border-gray-500';
    case 'success':
      return 'border-green-500';
    case 'danger':
      return 'border-red-500';
    default:
      return 'border-indigo-500';
  }
});
</script> 