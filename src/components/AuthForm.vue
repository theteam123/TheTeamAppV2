<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div class="text-center">
        <div class="flex justify-center">
          <TeamLogo :height="48" />
        </div>
        <h2 class="mt-6 text-3xl font-extrabold text-gray-900">
          Sign in to your account
        </h2>
      </div>

      <!-- Debug Info -->
      <div v-if="showDebug" class="bg-gray-100 p-4 rounded-lg text-xs font-mono">
        <div class="font-semibold mb-2">Debug Info:</div>
        <div>Form State:</div>
        <pre>{{ {
          email: email || '',
          password: '***',
          rememberMe,
          loading: authStore.loading,
          validationErrors: {
            email: emailError,
            password: passwordError
          }
        } }}</pre>
        <div class="mt-2">Auth Store State:</div>
        <pre>{{ {
          isAuthenticated: authStore.isAuthenticated,
          error: authStore.error,
          loading: authStore.loading
        } }}</pre>
        <button 
          @click="showDebug = false"
          class="mt-2 text-xs text-gray-500 hover:text-gray-700"
        >
          Hide Debug Info
        </button>
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div class="space-y-4">
          <div>
            <label for="auth-email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <div class="mt-1">
              <input
                id="auth-email"
                name="email"
                type="email"
                autocomplete="email"
                required
                v-model="email"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400',
                  'focus:outline-none sm:text-sm',
                  emailError 
                    ? 'border-red-300 text-red-900 focus:ring-red-500 focus:border-red-500' 
                    : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                ]"
                @input="clearErrors"
              />
              <p v-if="emailError" class="mt-2 text-sm text-red-600">{{ emailError }}</p>
            </div>
          </div>

          <div>
            <label for="auth-password" class="block text-sm font-medium text-gray-700">
              Password
            </label>
            <div class="mt-1">
              <input
                id="auth-password"
                name="password"
                :type="showPassword ? 'text' : 'password'"
                autocomplete="current-password"
                required
                v-model="password"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400',
                  'focus:outline-none sm:text-sm',
                  passwordError 
                    ? 'border-red-300 text-red-900 focus:ring-red-500 focus:border-red-500' 
                    : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                ]"
                @input="clearErrors"
              />
              <div class="mt-2 flex justify-between items-center">
                <p v-if="passwordError" class="text-sm text-red-600">{{ passwordError }}</p>
                <button
                  type="button"
                  class="text-sm text-gray-500 hover:text-gray-700"
                  @click="showPassword = !showPassword"
                >
                  {{ showPassword ? 'Hide' : 'Show' }} password
                </button>
              </div>
            </div>
          </div>

          <!-- Remember Me Checkbox -->
          <div class="flex items-center">
            <input
              id="remember-me"
              name="remember-me"
              type="checkbox"
              v-model="rememberMe"
              class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded"
            />
            <label for="remember-me" class="ml-2 block text-sm text-gray-900">
              Remember me
            </label>
          </div>
        </div>

        <div v-if="authStore.error" class="rounded-md bg-red-50 p-4">
          <div class="flex">
            <AlertCircleIcon class="h-5 w-5 text-red-400" />
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">Authentication Error</h3>
              <div class="mt-2 text-sm text-red-700">
                <p>{{ authStore.error }}</p>
              </div>
            </div>
          </div>
        </div>

        <div v-if="authStore.success" class="rounded-md bg-green-50 p-4">
          <div class="flex">
            <CheckCircleIcon class="h-5 w-5 text-green-400" />
            <div class="ml-3">
              <h3 class="text-sm font-medium text-green-800">Success</h3>
              <div class="mt-2 text-sm text-green-700">
                <p>{{ authStore.success }}</p>
              </div>
            </div>
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed disabled:bg-gray-400 disabled:hover:bg-gray-400"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <LockIcon v-if="!loading" class="h-5 w-5 text-green-500 group-hover:text-green-400" />
              <LoaderIcon v-else class="h-5 w-5 text-green-500 group-hover:text-green-400 animate-spin" />
            </span>
            Sign in
          </button>
        </div>

        <div class="flex justify-end text-sm">
          <button
            type="button"
            @click="showDebug = true"
            class="font-medium text-gray-500 hover:text-gray-700"
          >
            Show Debug Info
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { LockIcon, LoaderIcon, AlertCircleIcon, CheckCircleIcon } from 'lucide-vue-next';
import { useRouter } from 'vue-router';
import { z } from 'zod';
import TeamLogo from './TeamLogo.vue';

const router = useRouter();
const authStore = useAuthStore();

const email = ref(localStorage.getItem('rememberedEmail') || '');
const password = ref('');
const showPassword = ref(false);
const showDebug = ref(false);
const rememberMe = ref(localStorage.getItem('rememberMe') === 'true');
const loading = ref(false);
const error = ref<string | null>(null);

const emailError = ref('');
const passwordError = ref('');

const schema = z.object({
  email: z.string()
    .email('Invalid email address')
    .min(1, 'Email is required'),
  password: z.string()
    .min(6, 'Password must be at least 6 characters')
    .max(72, 'Password must be less than 72 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
});

const clearErrors = () => {
  emailError.value = '';
  passwordError.value = '';
  authStore.clearError();
};

const validateForm = () => {
  try {
    schema.parse({
      email: email.value,
      password: password.value,
    });
    return true;
  } catch (error) {
    if (error instanceof z.ZodError) {
      error.errors.forEach((err) => {
        if (err.path[0] === 'email') emailError.value = err.message;
        if (err.path[0] === 'password') passwordError.value = err.message;
      });
    }
    return false;
  }
};

const handleSubmit = async () => {
  clearErrors();
  
  if (!validateForm()) return;

  try {
    loading.value = true;
    error.value = null;
    
    // Store the remember me preference and email if remember me is checked
    localStorage.setItem('rememberMe', rememberMe.value.toString());
    if (rememberMe.value) {
      localStorage.setItem('rememberedEmail', email.value);
    } else {
      localStorage.removeItem('rememberedEmail');
    }
    
    await authStore.signIn(email.value, password.value, rememberMe.value);
    if (authStore.isAuthenticated) {
      router.push('/');
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'An error occurred';
  } finally {
    loading.value = false;
  }
};
</script>