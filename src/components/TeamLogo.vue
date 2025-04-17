<template>
  <router-link :to="link" class="flex items-center">
    <img
      :src="src"
      :alt="alt"
      :class="[
        'object-contain transition-opacity duration-200',
        { 'opacity-0': error }
      ]"
      :style="{ height: `${height}px` }"
      @error="handleImageError"
    />
    <span
      v-if="error"
      class="text-xl font-semibold text-gray-900"
      :style="{ height: `${height}px`, lineHeight: `${height}px` }"
    >
      {{ fallbackText }}
    </span>
  </router-link>
</template>

<script setup lang="ts">
import { ref } from 'vue';

interface Props {
  height?: number;
  link?: string;
  src?: string;
  alt?: string;
  fallbackText?: string;
}

const props = withDefaults(defineProps<Props>(), {
  height: 32,
  link: '/',
  src: '/TeamLogo.png',
  alt: 'Team Logo',
  fallbackText: 'TheTeam'
});

const error = ref(false);

const handleImageError = () => {
  console.error('Failed to load logo:', props.src);
  error.value = true;
};
</script>