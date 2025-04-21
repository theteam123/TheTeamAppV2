import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { supabase } from '../lib/supabase';
import type { Session } from '@supabase/supabase-js';
import type { Profile, User, Role, UserRole, RolePermission } from '../lib/types';

// Custom error classes for better error handling
class AuthError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AuthError';
  }
}

// Helper function to format errors in plain English
function formatError(error: any): string {
  console.log('[Auth Debug] Raw error:', error);
  
  // Handle Supabase PostgREST errors
  if (error.code === 'PGRST116') {
    return 'No profile found for this user. This is normal for new users.';
  }
  
  if (error.code === '23505') {
    return 'A profile with this email already exists. Please contact support if this is unexpected.';
  }
  
  // Handle common Supabase auth errors
  if (error.message?.includes('Invalid login credentials')) {
    return 'The email or password you entered is incorrect.';
  }
  
  if (error.message?.includes('Email not confirmed')) {
    return 'Please check your email to confirm your account before signing in.';
  }
  
  if (error.message?.includes('User not found')) {
    return 'No account found with this email address.';
  }
  
  // Handle network errors
  if (error.message?.includes('Failed to fetch')) {
    return 'Unable to connect to the server. Please check your internet connection.';
  }
  
  // Handle permission errors
  if (error.message?.includes('permission denied')) {
    return 'You do not have permission to perform this action.';
  }
  
  // Default case - return the error message if it exists, otherwise a generic message
  return error.message || 'An unexpected error occurred. Please try again.';
}

interface Company {
  id: string;
  name: string;
  logo_url?: string;
}

interface AuthState {
  user: User | null;
  session: Session | null;
  roles: Role[];
  permissions: string[];
  loading: boolean;
  profile: Profile | null;
  error: string | null;
  availableCompanies: Company[];
  needsCompanySelection: boolean;
  success: string | null;
}

interface DbRolePermission {
  permission_key: string;
}

interface DbRole {
  id: string;
  name: string;
  description: string;
  role_permissions: DbRolePermission[];
}

interface DbUserRole {
  roles: DbRole;
}

interface DbCompany {
  id: string;
  name: string;
  logo_url: string | null;
}

interface SupabaseUserRole {
  roles: {
    id: string;
    name: string;
    description: string;
    is_system_role: boolean;
    role_permissions: {
      permission_key: string;
    }[];
  };
}

interface SupabaseCompany {
  id: string;
  name: string;
  logo_url: string | null;
}

interface UserCompany {
  company_id: string;
}

// Add cache interface
interface AuthCache {
  profile: Profile | null;
  roles: Role[];
  permissions: string[];
  lastUpdated: number;
}

// Add cache state
const cache = ref<AuthCache>({
  profile: null,
  roles: [],
  permissions: [],
  lastUpdated: 0
});

// Cache duration in milliseconds (5 minutes)
const CACHE_DURATION = 5 * 60 * 1000;

// Helper function to check if cache is valid
function isCacheValid(): boolean {
  return Date.now() - cache.value.lastUpdated < CACHE_DURATION;
}

// Add type for the get_user_roles function response
interface UserRoleResponse {
  role_id: string;
  role_name: string;
  is_system_role: boolean;
  permissions: { permission_key: string }[];  // Add permissions field
}

export const useAuthStore = defineStore('auth', () => {
  const state = ref<AuthState>({
    user: null,
    session: null,
    roles: [],
    permissions: [],
    loading: true,
    profile: null,
    error: null,
    availableCompanies: [],
    needsCompanySelection: false,
    success: null
  });

  // Function definitions
  function resetState(): void {
    console.log('[Auth] Resetting state...');
    state.value = {
      user: null,
      session: null,
      roles: [],
      permissions: [],
      loading: false,
      profile: null,
      error: null,
      availableCompanies: [],
      needsCompanySelection: false,
      success: null
    };
    clearCache();
    console.log('[Auth] State reset complete');
  }

  async function setSession(session: Session) {
    console.log('[Auth] Setting session:', { user: session?.user?.email });
    state.value.loading = true;
    try {
      state.value.session = session;
      state.value.user = session?.user as User || null;

      if (session?.user) {
        // Ensure profile exists first
        await ensureProfileExists(session.user.id);
        
        // Fetch profile
        await fetchUserProfile();
        
        // Fetch roles first, as we need to know if user is system role
        await fetchUserRoles();
        
        // Then fetch companies
        await fetchAvailableCompanies();

        // Check if user has system role
        const hasSystemRole = state.value.roles.some(role => role.name === 'App_Admin');
        
        // Only handle company selection for non-system roles
        if (!hasSystemRole && !state.value.profile?.current_company_id && state.value.availableCompanies.length > 0) {
          if (state.value.availableCompanies.length === 1) {
            await setCurrentCompany(state.value.availableCompanies[0].id);
          } else {
            state.value.needsCompanySelection = true;
          }
        }
      }
    } catch (error) {
      console.error('[Auth] Error setting session:', error);
      resetState();
      throw error;
    } finally {
      state.value.loading = false;
    }
  }

  function clearError(): void {
    state.value.error = null;
  }

  // Set up Supabase auth state listener
  function registerAuthListener() {
    supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('[Auth] Auth state change:', { event, session: !!session });
      state.value.loading = true;

      try {
        if (session) {
          state.value.session = session;
          state.value.user = session.user as User;

          // Ensure profile exists first
          await ensureProfileExists(session.user.id);

          // Then load all data in parallel
          await Promise.all([
            fetchUserProfile(),
            fetchUserRoles(),
            fetchAvailableCompanies()
          ]);

          // Check if user has system role
          const hasSystemRole = state.value.roles.some(role => role.name === 'App_Admin');
          
          // Only handle company selection for non-system roles
          if (!hasSystemRole && !state.value.profile?.current_company_id && state.value.availableCompanies.length > 0) {
            if (state.value.availableCompanies.length === 1) {
              await setCurrentCompany(state.value.availableCompanies[0].id);
            } else {
              state.value.needsCompanySelection = true;
            }
          }
        } else {
          resetState();
        }
      } catch (error) {
        console.error('[Auth] Error in auth state change:', error);
        resetState();
      } finally {
        state.value.loading = false;
      }
    });
  }

  async function initialize(): Promise<void> {
    console.log('[Auth Debug] Starting initialization...', {
      currentState: {
        loading: state.value.loading,
        isAuthenticated: isAuthenticated.value,
        hasSession: !!state.value.session,
        hasUser: !!state.value.user
      }
    });

    try {
      state.value.loading = true;
      const { data: { session }, error } = await supabase.auth.getSession();
      
      console.log('[Auth Debug] getSession result:', {
        hasSession: !!session,
        hasError: !!error,
        errorMessage: error?.message
      });

      if (error) {
        console.error('[Auth Debug] Error getting session:', error);
        throw error;
      }

      if (session) {
        console.log('[Auth Debug] Session recovered, setting state...');
        state.value.session = session;
        state.value.user = session.user as User;

        console.log('[Auth Debug] Fetching user data...');
        // First fetch profile
        await fetchUserProfile();
        
        // Always fetch available companies
        await fetchAvailableCompanies();

        console.log('[Auth Debug] Profile and companies loaded:', {
          hasProfile: !!state.value.profile,
          companyCount: state.value.availableCompanies.length,
          currentCompanyId: state.value.profile?.current_company_id
        });

        // Handle company selection if needed
        if (!state.value.profile?.current_company_id) {
          if (state.value.availableCompanies.length === 1) {
            console.log('[Auth Debug] Single company available, auto-selecting...');
            await setCurrentCompany(state.value.availableCompanies[0].id);
          } else if (state.value.availableCompanies.length > 1) {
            console.log('[Auth Debug] Multiple companies available, requiring selection...');
            state.value.needsCompanySelection = true;
            return;
          }
        }

        // Only fetch roles if we have a selected company
        if (state.value.profile?.current_company_id) {
          console.log('[Auth Debug] Fetching roles and permissions...');
          await fetchUserRoles();
          console.log('[Auth Debug] Roles loaded:', {
            rolesCount: state.value.roles.length,
            permissionsCount: state.value.permissions.length
          });
        }
      } else {
        console.log('[Auth Debug] No session found, resetting state...');
        resetState();
      }
    } catch (error) {
      console.error('[Auth Debug] Initialization error:', error);
      resetState();
    } finally {
      state.value.loading = false;
      console.log('[Auth Debug] Initialization complete:', {
        isAuthenticated: isAuthenticated.value,
        hasSession: !!state.value.session,
        hasUser: !!state.value.user,
        loading: state.value.loading
      });
    }
  }

  async function signIn(email: string, password: string, rememberMe: boolean = false): Promise<void> {
    try {
      state.value.loading = true;
      state.value.error = null;
      console.log('[Auth] Signing in...', { rememberMe });
      
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
        options: {
          // Remove persistSession as it's not a valid option
          // Session persistence is handled by the Supabase client configuration
        }
      });

      if (error) {
        const friendlyError = formatError(error);
        console.error('[Auth] Sign in error:', friendlyError);
        state.value.error = friendlyError;
        throw new AuthError(friendlyError);
      }

      if (!data.session) {
        const msg = 'Failed to create session';
        console.error('[Auth] No session after sign in');
        state.value.error = msg;
        throw new AuthError(msg);
      }

      console.log('[Auth] Sign in successful, setting session...');
      state.value.session = data.session;
      state.value.user = data.user as User;

      // Try to fetch profile, but don't fail if it doesn't exist
      try {
        await ensureProfileExists(data.user.id);
      } catch (error) {
        const friendlyError = formatError(error);
        console.warn('[Auth] Profile fetch failed, continuing with login:', friendlyError);
      }

      // Fetch the profile, but don't fail if it doesn't exist
      await fetchUserProfile();
      console.log('[Auth] Profile loaded:', state.value.profile);

      // Always fetch available companies
      await fetchAvailableCompanies();
      console.log('[Auth] Available companies:', state.value.availableCompanies);

      // Handle company selection based on available companies
      if (state.value.availableCompanies.length === 0) {
        const msg = 'No companies available for this user. Please contact your administrator.';
        console.warn('[Auth]', msg);
        state.value.error = msg;
        throw new AuthError(msg);
      } else if (state.value.availableCompanies.length === 1) {
        // Auto-select if only one company
        console.log('[Auth] Single company available, auto-selecting...');
        await setCurrentCompany(state.value.availableCompanies[0].id);
      } else {
        // Multiple companies available, show selection modal
        console.log('[Auth] Multiple companies available, requiring selection...');
        state.value.needsCompanySelection = true;
        return;
      }

      // Only fetch roles if we have a selected company
      if (state.value.profile?.current_company_id) {
        await fetchUserRoles();
      }

      console.log('[Auth] Sign in complete');
    } catch (error) {
      const friendlyError = formatError(error);
      console.error('[Auth] Sign in error:', friendlyError);
      state.value.error = friendlyError;
      resetState();
      throw new AuthError(friendlyError);
    } finally {
      state.value.loading = false;
    }
  }

  async function ensureProfileExists(userId: string): Promise<void> {
    try {
      console.log('[Auth] Fetching profile for user:', userId);
      
      const { data: profile, error: fetchError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      // PGRST116 is "no rows returned" which is expected if no profile exists
      if (fetchError && fetchError.code !== 'PGRST116') {
        console.error('[Auth] Error fetching profile:', fetchError);
        throw fetchError;
      }

      if (!profile) {
        console.warn('[Auth] No profile found for user:', userId);
        // We don't create profiles during login - that should only happen during signup
        return;
      }

      console.log('[Auth] Profile fetched successfully');
    } catch (error) {
      // Only log the error, don't throw it
      console.error('[Auth] Error fetching profile:', error);
    }
  }

  async function signUp(email: string, password: string, fullName: string): Promise<void> {
    try {
      state.value.loading = true;
      state.value.error = null;
      console.log('[Auth] Signing up...', { email, fullName });
      
      // Sign up with Supabase - this will trigger email verification
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName
          },
          emailRedirectTo: `${window.location.origin}/auth`
        }
      });

      if (error) {
        console.error('[Auth] Sign up error:', error.message);
        state.value.error = error.message;
        throw new AuthError(error.message);
      }

      if (!data.user) {
        const msg = 'Failed to create user';
        console.error('[Auth] No user after sign up');
        state.value.error = msg;
        throw new AuthError(msg);
      }

      console.log('[Auth] Sign up successful, verification email sent');
      
      // Show success message instead of error
      state.value.error = null;
      state.value.success = 'Please check your email to verify your account. After verification, you can sign in.';
    } catch (error) {
      console.error('[Auth] Sign up error:', error);
      resetState();
      throw error;
    } finally {
      state.value.loading = false;
    }
  }

  async function signOut(): Promise<void> {
    try {
      state.value.loading = true;
      console.log('[Auth] Signing out...');
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        console.error('[Auth] Sign out error:', error.message);
        throw error;
      }
      
      console.log('[Auth] Sign out successful');
      resetState();
    } catch (error) {
      console.error('[Auth] Sign out error:', error);
      throw error;
    } finally {
      state.value.loading = false;
    }
  }

  async function fetchUserProfile(): Promise<void> {
    if (!state.value.user?.id) {
      console.warn('[Auth] No user ID available for fetching profile');
      return;
    }

    try {
      // Check cache first
      if (isCacheValid() && cache.value.profile) {
        console.log('[Auth] Using cached profile');
        state.value.profile = cache.value.profile;
        return;
      }

      console.log('[Auth] Fetching user profile...');
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', state.value.user.id)
        .single();

      if (error && error.code !== 'PGRST116') {
        const friendlyError = formatError(error);
        console.error('[Auth] Error fetching profile:', friendlyError);
        throw new AuthError(friendlyError);
      }

      state.value.profile = data || null;
      
      // Update cache
      cache.value.profile = data || null;
      cache.value.lastUpdated = Date.now();
      
      console.log('[Auth] Profile fetched successfully:', data);
    } catch (error) {
      const friendlyError = formatError(error);
      console.error('[Auth] Error in fetchUserProfile:', friendlyError);
      state.value.profile = null;
    }
  }

  async function fetchUserRoles() {
    try {
      // Check cache first
      if (isCacheValid() && cache.value.roles.length > 0) {
        console.log('[Auth] Using cached roles');
        state.value.roles = cache.value.roles;
        state.value.permissions = cache.value.permissions;
        return;
      }

      console.log('[Auth] Fetching user roles and permissions...');
      
      // Use the new get_user_roles function
      const { data: roles, error: rolesError } = await supabase
        .rpc('get_user_roles', { user_id: state.value.user?.id });

      if (rolesError) throw rolesError;

      // Process roles and permissions
      const processedRoles: Role[] = [];
      const permissions = new Set<string>();

      if (roles) {
        (roles as UserRoleResponse[]).forEach(role => {
          // Extract permissions from the role
          const rolePermissions = role.permissions?.map(p => ({
            permission_key: p.permission_key
          })) || [];

          // Add permissions to the set
          rolePermissions.forEach(p => permissions.add(p.permission_key));

          // Create the processed role
          processedRoles.push({
            id: role.role_id,
            name: role.role_name,
            description: '', // Default empty description
            is_system_role: role.is_system_role,
            role_permissions: rolePermissions
          });
        });
      }

      // Update state and cache
      state.value.roles = processedRoles;
      state.value.permissions = Array.from(permissions);
      
      cache.value.roles = processedRoles;
      cache.value.permissions = Array.from(permissions);
      cache.value.lastUpdated = Date.now();

      console.log('[Auth] Roles loaded:', {
        rolesCount: state.value.roles.length,
        permissionsCount: state.value.permissions.length,
        permissions: Array.from(permissions) // Log the actual permissions
      });
    } catch (error) {
      console.error('[Auth] Error fetching roles:', error);
      state.value.roles = [];
      state.value.permissions = [];
    }
  }

  async function fetchAvailableCompanies(): Promise<void> {
    try {
      console.log('[Auth] Fetching available companies...');
      
      // Check if user has system role
      const hasSystemRole = state.value.roles.some(role => role.name === 'App_Admin');
      
      if (hasSystemRole) {
        // For system roles, fetch all companies directly
        const { data: companies, error: companiesError } = await supabase
          .from('companies')
          .select('id, name, logo_url')
          .order('name');

        if (companiesError) throw companiesError;
        
        state.value.availableCompanies = companies || [];
        console.log('[Auth] All companies fetched for system role:', companies);
        return;
      }
      
      // For non-system roles, use the function to get associated companies
      const { data: companies, error: companiesError } = await supabase
        .rpc('get_user_companies');

      if (companiesError) {
        console.error('[Auth] Error fetching companies:', companiesError.message);
        throw new AuthError(`Failed to fetch companies: ${companiesError.message}`);
      }

      state.value.availableCompanies = companies || [];
      console.log('[Auth] Companies fetched successfully:', state.value.availableCompanies);
    } catch (error) {
      console.error('[Auth] Error in fetchAvailableCompanies:', error);
      state.value.availableCompanies = [];
    }
  }

  async function setCurrentCompany(companyId: string): Promise<void> {
    if (!state.value.user?.id) {
      throw new AuthError('No user logged in');
    }

    // Check if user has system role - if so, don't set a company
    const hasSystemRole = state.value.roles.some(role => role.name === 'App_Admin');
    if (hasSystemRole) {
      console.log('[Auth] System role detected, skipping company assignment');
      state.value.needsCompanySelection = false;
      return;
    }

    try {
      console.log('[Auth] Setting current company:', companyId);
      const { error } = await supabase
        .from('profiles')
        .update({ current_company_id: companyId })
        .eq('id', state.value.user.id);

      if (error) {
        console.error('[Auth] Error setting current company:', error.message);
        throw new AuthError(`Failed to set current company: ${error.message}`);
      }

      if (state.value.profile) {
        state.value.profile.current_company_id = companyId;
      }

      // Clear the company selection flag
      state.value.needsCompanySelection = false;

      // Refresh roles and permissions for new company
      await fetchUserRoles();
      console.log('[Auth] Current company updated successfully');
    } catch (error) {
      console.error('[Auth] Error in setCurrentCompany:', error);
      throw error;
    }
  }

  async function selectCompany(companyId: string): Promise<void> {
    try {
      state.value.loading = true;
      console.log('[Auth] Selecting company:', companyId);

      await setCurrentCompany(companyId);
      state.value.needsCompanySelection = false;

      // Fetch roles and permissions for the selected company
      await fetchUserRoles();

      console.log('[Auth] Company selection complete');
    } catch (error) {
      console.error('[Auth] Error selecting company:', error);
      throw error;
    } finally {
      state.value.loading = false;
    }
  }

  // Computed properties
  const isAuthenticated = computed(() => {
    const authenticated = !!state.value.session && !!state.value.user && !state.value.loading;
    console.log('[Auth] Checking authentication status:', {
      session: !!state.value.session,
      user: !!state.value.user,
      loading: state.value.loading,
      authenticated
    });
    return authenticated;
  });

  const hasSystemRole = computed(() => {
    return state.value.roles.some(role => role.is_system_role);
  });

  const hasPermission = (permission: string): boolean => {
    return state.value.permissions.includes(permission);
  };

  const isAppAdmin = computed(() => {
    return state.value.roles.some(role => role.name === 'App_Admin');
  });

  const currentCompany = computed(() => {
    console.log('[Auth] Getting current company:', state.value.profile?.current_company_id);
    return state.value.profile?.current_company_id;
  });

  const userRole = computed(() => {
    // Log all roles for debugging
    console.log('[Auth] All roles:', state.value.roles);

    // Find system role first (like App_Admin)
    const systemRole = state.value.roles.find(r => r.is_system_role);
    if (systemRole) {
      console.log('[Auth] Found system role:', systemRole.name);
      return systemRole.name;
    }

    // Fall back to first company role or 'User'
    const companyRole = state.value.roles[0];
    const roleName = companyRole?.name || 'User';
    console.log('[Auth] Using company role or default:', roleName);
    return roleName;
  });

  const currentCompanyId = computed(() => {
    return state.value.profile?.current_company_id;
  });

  // Add cache clearing function
  function clearCache(): void {
    cache.value = {
      profile: null,
      roles: [],
      permissions: [],
      lastUpdated: 0
    };
  }

  // Return object
  return {
    // State
    user: computed(() => state.value.user),
    session: computed(() => state.value.session),
    roles: computed(() => state.value.roles),
    permissions: computed(() => state.value.permissions),
    profile: computed(() => state.value.profile),
    loading: computed(() => state.value.loading),
    error: computed(() => state.value.error),
    availableCompanies: computed(() => state.value.availableCompanies),
    currentCompanyId,
    needsCompanySelection: computed(() => state.value.needsCompanySelection),
    success: computed(() => state.value.success),

    // Getters
    isAuthenticated,
    hasSystemRole,
    hasPermission,
    isAppAdmin,
    currentCompany,
    userRole,

    // Actions
    setSession,
    resetState,
    registerAuthListener,
    initialize,
    signIn,
    signOut,
    clearError,
    setCurrentCompany,
    fetchAvailableCompanies,
    selectCompany,

    // Expose supabase client for direct access
    supabase
  };
});