<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center p-8">
    <div class="text-center">
      <div class="flex justify-center mb-6">
        <div class="h-16 w-16 bg-green-100 rounded-lg flex items-center justify-center">
          <BuildingIcon class="h-10 w-10 text-green-600" />
        </div>
      </div>
      <h1 class="text-4xl font-bold text-gray-900 mb-4">Coming Soon</h1>
      <p class="text-lg text-gray-600 max-w-md mx-auto">
        We're working on something exciting. Stay tuned for updates!
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { BuildingIcon } from 'lucide-vue-next';
</script>