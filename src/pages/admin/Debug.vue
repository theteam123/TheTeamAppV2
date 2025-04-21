<template>
  <div class="p-8 max-w-7xl mx-auto">
    <!-- Toast Notification -->
    <div
      v-if="showToast"
      class="fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg transform transition-all duration-300"
      :class="{ 'opacity-0 translate-y-4': !showToast, 'opacity-100 translate-y-0': showToast }"
    >
      Copied to clipboard!
    </div>

    <h1 class="text-2xl font-bold mb-4">Debug Information</h1>
    
    <div class="space-y-6">
      <!-- User Info -->
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex justify-between items-center mb-2">
          <h2 class="text-lg font-semibold">
            <button @click="sections.userInfo = !sections.userInfo" class="flex items-center space-x-2">
              <ChevronRightIcon class="w-5 h-5 transform transition-transform" :class="{ 'rotate-90': sections.userInfo }" />
              <span>User Information</span>
            </button>
          </h2>
          <button
            @click="copyToClipboard('userInfo')"
            class="p-1 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-colors duration-200"
            title="Copy to clipboard"
          >
            <ClipboardIcon class="w-5 h-5" />
          </button>
        </div>
        <div v-if="sections.userInfo" class="overflow-x-auto">
          <pre class="bg-gray-50 p-4 rounded whitespace-pre-wrap">{{ userInfo }}</pre>
        </div>
      </div>

      <!-- Role Details -->
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex justify-between items-center mb-2">
          <h2 class="text-lg font-semibold">
            <button @click="sections.roleDetails = !sections.roleDetails" class="flex items-center space-x-2">
              <ChevronRightIcon class="w-5 h-5 transform transition-transform" :class="{ 'rotate-90': sections.roleDetails }" />
              <span>Role Details</span>
            </button>
          </h2>
          <button
            @click="copyToClipboard('roleDetails')"
            class="p-1 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-colors duration-200"
            title="Copy to clipboard"
          >
            <ClipboardIcon class="w-5 h-5" />
          </button>
        </div>
        <div v-if="sections.roleDetails" class="overflow-x-auto">
          <pre class="bg-gray-50 p-4 rounded whitespace-pre-wrap">{{ roleDetails }}</pre>
        </div>
      </div>

      <!-- Roles and Permissions -->
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex justify-between items-center mb-2">
          <h2 class="text-lg font-semibold">
            <button @click="sections.rolesAndPermissions = !sections.rolesAndPermissions" class="flex items-center space-x-2">
              <ChevronRightIcon class="w-5 h-5 transform transition-transform" :class="{ 'rotate-90': sections.rolesAndPermissions }" />
              <span>Roles and Permissions</span>
            </button>
          </h2>
          <button
            @click="copyToClipboard('rolesAndPermissions')"
            class="p-1 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-colors duration-200"
            title="Copy to clipboard"
          >
            <ClipboardIcon class="w-5 h-5" />
          </button>
        </div>
        <div v-if="sections.rolesAndPermissions" class="overflow-x-auto">
          <pre class="bg-gray-50 p-4 rounded whitespace-pre-wrap">{{ rolesAndPermissions }}</pre>
        </div>
      </div>

      <!-- Company Info -->
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex justify-between items-center mb-2">
          <h2 class="text-lg font-semibold">
            <button @click="sections.companyInfo = !sections.companyInfo" class="flex items-center space-x-2">
              <ChevronRightIcon class="w-5 h-5 transform transition-transform" :class="{ 'rotate-90': sections.companyInfo }" />
              <span>Company Information</span>
            </button>
          </h2>
          <button
            @click="copyToClipboard('companyInfo')"
            class="p-1 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-colors duration-200"
            title="Copy to clipboard"
          >
            <ClipboardIcon class="w-5 h-5" />
          </button>
        </div>
        <div v-if="sections.companyInfo" class="overflow-x-auto">
          <pre class="bg-gray-50 p-4 rounded whitespace-pre-wrap">{{ companyInfo }}</pre>
        </div>
      </div>

      <!-- Session Details -->
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex justify-between items-center mb-2">
          <h2 class="text-lg font-semibold">
            <button @click="sections.sessionDetails = !sections.sessionDetails" class="flex items-center space-x-2">
              <ChevronRightIcon class="w-5 h-5 transform transition-transform" :class="{ 'rotate-90': sections.sessionDetails }" />
              <span>Session Details</span>
            </button>
          </h2>
          <button
            @click="copyToClipboard('sessionDetails')"
            class="p-1 text-gray-500 hover:text-gray-700 rounded-full hover:bg-gray-100 transition-colors duration-200"
            title="Copy to clipboard"
          >
            <ClipboardIcon class="w-5 h-5" />
          </button>
        </div>
        <div v-if="sections.sessionDetails" class="overflow-x-auto">
          <div class="bg-gray-50 p-4 rounded">
            <div class="grid grid-cols-2 gap-4">
              <div class="col-span-2">
                <p class="text-sm text-gray-600">Session ID:</p>
                <p class="font-mono text-sm break-all">{{ authStore.session?.access_token || 'Not available' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600">Expires At:</p>
                <p class="font-mono text-sm">{{ authStore.session?.expires_at ? new Date(authStore.session.expires_at * 1000).toLocaleString() : 'Not available' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600">Remember Me:</p>
                <p class="font-mono text-sm">{{ isRememberMe ? 'Yes' : 'No' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600">Storage Type:</p>
                <p class="font-mono text-sm">{{ isRememberMe ? 'Local Storage' : 'Session Storage' }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600">Auth Status:</p>
                <p class="font-mono text-sm">{{ authStore.isAuthenticated ? 'Authenticated' : 'Not Authenticated' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { supabase } from '../../lib/supabase';
import { ClipboardIcon, ChevronRightIcon } from 'lucide-vue-next';
import { useRoute } from 'vue-router';

const authStore = useAuthStore();
const userInfo = ref({});
const rolesAndPermissions = ref({});
const companyInfo = ref({});
const roleDetails = ref({});
const showToast = ref(false);
let toastTimeout: number | null = null;

// Computed properties for session info
const session = computed(() => authStore.session);
const isRememberMe = computed(() => {
  if (typeof window !== 'undefined') {
    return window.localStorage.getItem('rememberMe') === 'true';
  }
  return false;
});

// Section visibility state
const sections = ref({
  userInfo: false,
  roleDetails: false,
  rolesAndPermissions: false,
  companyInfo: false,
  sessionDetails: false
});

const copyToClipboard = (section: 'userInfo' | 'rolesAndPermissions' | 'companyInfo' | 'roleDetails' | 'sessionDetails') => {
  let data;
  switch (section) {
    case 'userInfo':
      data = userInfo.value;
      break;
    case 'rolesAndPermissions':
      data = rolesAndPermissions.value;
      break;
    case 'companyInfo':
      data = companyInfo.value;
      break;
    case 'roleDetails':
      data = roleDetails.value;
      break;
    case 'sessionDetails':
      data = {
        sessionId: authStore.session?.access_token,
        expiresAt: authStore.session?.expires_at,
        expiresAtFormatted: authStore.session?.expires_at ? new Date(authStore.session.expires_at * 1000).toLocaleString() : null,
        rememberMe: isRememberMe.value,
        storageType: isRememberMe.value ? 'Local Storage' : 'Session Storage',
        authStatus: authStore.isAuthenticated ? 'Authenticated' : 'Not Authenticated'
      };
      break;
  }
  
  navigator.clipboard.writeText(JSON.stringify(data, null, 2))
    .then(() => {
      if (toastTimeout) {
        clearTimeout(toastTimeout);
      }
      showToast.value = true;
      toastTimeout = window.setTimeout(() => {
        showToast.value = false;
      }, 2000);
    })
    .catch(err => {
      console.error('Failed to copy:', err);
    });
};

const fetchDebugInfo = async () => {
  try {
    // Fetch user roles with complete role information using RPC instead of direct query
    let userRolesData = [];
    const { data, error: userRolesError } = await supabase
      .rpc('get_user_roles', {
        user_id: authStore.user?.id
      });

    if (userRolesError) {
      console.error('Error fetching user roles:', userRolesError);
    } else {
      userRolesData = data || [];
    }

    rolesAndPermissions.value = {
      userRoles: [],
      storeRoles: (authStore.roles || []).map(role => ({
        id: role.id,
        name: role.name,
        description: role.description,
        is_system_role: role.is_system_role,
        permissions: (role.role_permissions || []).map(p => p.permission_key)
      })),
      storePermissions: authStore.permissions || [],
      rawUserRoles: userRolesData
    };

    // Fetch user info with extended role information
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', authStore.user?.id)
      .single();

    if (profileError) {
      console.error('Error fetching profile:', profileError);
    }

    userInfo.value = {
      user: authStore.user,
      profile: profile || null,
      session: authStore.session,
      currentRole: authStore.userRole,
      roles: authStore.roles || []
    };

    // Fetch company info
    if (authStore.currentCompanyId) {
      const { data: company, error: companyError } = await supabase
        .from('companies')
        .select('*')
        .eq('id', authStore.currentCompanyId)
        .single();

      if (companyError) {
        console.error('Error fetching company:', companyError);
      }

      companyInfo.value = {
        currentCompany: company || null,
        availableCompanies: authStore.availableCompanies || []
      };
    } else {
      companyInfo.value = {
        currentCompany: null,
        availableCompanies: authStore.availableCompanies || []
      };
    }

    // Set role details using store data instead of direct query
    roleDetails.value = {
      currentUserRole: {
        name: authStore.userRole,
        isSystemRole: (authStore.roles || []).some(r => r.is_system_role),
        allRoles: authStore.roles || []
      },
      systemRoles: (authStore.roles || [])
        .filter(role => role.is_system_role)
        .map(role => ({
          name: role.name,
          description: role.description,
          permissions: (role.role_permissions || []).map(p => p.permission_key)
        })),
      allUserRoles: [],
      debug: {
        rawSystemRoles: [],
        rawUserRoles: userRolesData || [],
        storeRoles: authStore.roles || [],
        allRoles: []
      }
    };

    // Log debug information
    console.log('[Debug] Role Details:', roleDetails.value);
    console.log('[Debug] User Info:', userInfo.value);
    console.log('[Debug] Roles and Permissions:', rolesAndPermissions.value);
    console.log('[Debug] Company Info:', companyInfo.value);
  } catch (error) {
    console.error('[Debug] Error fetching debug information:', error);
    // Set default values on error
    rolesAndPermissions.value = { error: 'Failed to fetch roles and permissions' };
    userInfo.value = { error: 'Failed to fetch user information' };
    companyInfo.value = { error: 'Failed to fetch company information' };
    roleDetails.value = { error: 'Failed to fetch role details' };
  }
};

const route = useRoute();
const searchInput = ref('');
const showSearchResults = ref(false);
const searchResults = ref([]);

watch(route, () => {
  searchInput.value = '';
  showSearchResults.value = false;
  searchResults.value = [];
});

onMounted(() => {
  fetchDebugInfo();
});
</script> 