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

  // Set up Supabase auth state listener
  supabase.auth.onAuthStateChange(async (event, session) => {
    console.log('[Auth] Auth state change:', { event, session: !!session });
    state.value.loading = true;
    try {
      if (session) {
        state.value.session = session;
        state.value.user = session.user as User;
        // Fetch additional user data
        await Promise.all([
          fetchUserProfile(),
          fetchAvailableCompanies(),
          fetchUserRolesAndPermissions()
        ]);
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

  const isAuthenticated = computed(() => {
    const authenticated = !!state.value.session && !!state.value.user;
    console.log('[Auth] Checking authentication status:', {
      session: !!state.value.session,
      user: !!state.value.user,
      authenticated
    });
    return authenticated;
  });

  const hasPermission = computed(() => (permission: string) => {
    console.log('[Auth] Checking permission:', permission);
    return state.value.permissions.includes(permission);
  });

  const currentCompany = computed(() => {
    console.log('[Auth] Getting current company:', state.value.profile?.current_company_id);
    return state.value.profile?.current_company_id;
  });

  const userRole = computed(() => {
    // Log all roles for debugging
    console.log('[Auth] All roles:', state.value.roles);

    // Find system role first (like SuperAdmin)
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
        await Promise.all([
          fetchUserProfile(),
          fetchAvailableCompanies()
        ]);

        console.log('[Auth Debug] Profile loaded:', {
          hasProfile: !!state.value.profile,
          companyCount: state.value.availableCompanies.length
        });

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

        if (state.value.profile?.current_company_id) {
          console.log('[Auth Debug] Fetching roles and permissions...');
          await fetchUserRolesAndPermissions();
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
          persistSession: true // Always persist the session when Remember Me is checked
        }
      });

      if (error) {
        console.error('[Auth] Sign in error:', error.message);
        state.value.error = error.message;
        throw new AuthError(error.message);
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

      console.log('[Auth] Fetching user data...');
      await Promise.all([
        fetchUserProfile(),
        fetchAvailableCompanies()
      ]);

      // Check if company selection is needed
      if (!state.value.profile?.current_company_id) {
        if (state.value.availableCompanies.length === 1) {
          // Auto-select if only one company
          console.log('[Auth] Single company available, auto-selecting...');
          await setCurrentCompany(state.value.availableCompanies[0].id);
        } else if (state.value.availableCompanies.length > 1) {
          // Set flag for company selection if multiple companies
          console.log('[Auth] Multiple companies available, requiring selection...');
          state.value.needsCompanySelection = true;
          return;
        } else {
          console.warn('[Auth] No companies available for user');
        }
      }

      // Only fetch roles if we have a selected company
      if (state.value.profile?.current_company_id) {
        await fetchUserRolesAndPermissions();
      }

      console.log('[Auth] Sign in complete');
    } catch (error) {
      console.error('[Auth] Sign in error:', error);
      resetState();
      throw error;
    } finally {
      state.value.loading = false;
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
      console.log('[Auth] Fetching user profile...');
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', state.value.user.id)
        .single();

      if (error) {
        console.error('[Auth] Error fetching profile:', error.message);
        throw new AuthError(`Failed to fetch profile: ${error.message}`);
      }

      state.value.profile = data;
      console.log('[Auth] Profile fetched successfully:', data);
    } catch (error) {
      console.error('[Auth] Error in fetchUserProfile:', error);
      throw error;
    }
  }

  async function fetchUserRolesAndPermissions(): Promise<void> {
    if (!state.value.user?.id) {
      console.warn('[Auth] Missing user ID for fetching roles');
      return;
    }

    try {
      console.log('[Auth] Fetching user roles and permissions...');
      
      const { data: userRoles, error } = await supabase
        .from('user_roles')
        .select(`
          user_id,
          role_id,
          company_id,
          role:roles (
            id,
            name,
            description,
            is_system_role,
            role_permissions (
              permission_key
            )
          )
        `)
        .or(`company_id.eq.${state.value.profile?.current_company_id},company_id.is.null`)
        .eq('user_id', state.value.user.id);

      if (error) {
        console.error('[Auth] Error fetching roles:', error.message);
        throw new AuthError(`Failed to fetch roles: ${error.message}`);
      }

      if (!userRoles || !Array.isArray(userRoles)) {
        console.warn('[Auth] No roles found for user');
        state.value.roles = [];
        state.value.permissions = [];
        return;
      }

      console.log('[Auth] Raw user roles data:', userRoles);

      // Type assertion to unknown first, then to the correct type
      const typedUserRoles = (userRoles as unknown) as Array<{
        role: {
          id: string;
          name: string;
          description: string;
          is_system_role: boolean;
          role_permissions: { permission_key: string; }[];
        };
      }>;
      
      const roles = typedUserRoles.map(ur => ({
        id: ur.role.id,
        name: ur.role.name,
        description: ur.role.description,
        is_system_role: ur.role.is_system_role,
        role_permissions: ur.role.role_permissions || []
      }));

      const permissions = roles.flatMap(role => 
        role.role_permissions.map(rp => rp.permission_key)
      );

      state.value.roles = roles;
      state.value.permissions = [...new Set(permissions)];
      console.log('[Auth] Roles and permissions fetched successfully:', {
        roles: roles.map(r => r.name),
        permissions
      });
    } catch (error) {
      console.error('[Auth] Error in fetchUserRolesAndPermissions:', error);
      throw error;
    }
  }

  async function fetchAvailableCompanies(): Promise<void> {
    try {
      console.log('[Auth] Fetching available companies...');
      
      // First get the user's company IDs
      const { data: userCompanies, error: userCompaniesError } = await supabase
        .from('user_companies')
        .select('company_id')
        .eq('user_id', state.value.user?.id);

      if (userCompaniesError) {
        console.error('[Auth] Error fetching user companies:', userCompaniesError.message);
        throw new AuthError(`Failed to fetch user companies: ${userCompaniesError.message}`);
      }

      if (!userCompanies || userCompanies.length === 0) {
        console.warn('[Auth] No companies found for user');
        state.value.availableCompanies = [];
        return;
      }

      const userCompanyIds = (userCompanies as UserCompany[]).map(uc => uc.company_id);

      // Then fetch the company details
      const { data: companies, error: companiesError } = await supabase
        .from('companies')
        .select('id, name, logo_url')
        .in('id', userCompanyIds);

      if (companiesError) {
        console.error('[Auth] Error fetching companies:', companiesError.message);
        throw new AuthError(`Failed to fetch companies: ${companiesError.message}`);
      }

      if (!companies) {
        state.value.availableCompanies = [];
        return;
      }

      // Transform the data to match Company interface
      state.value.availableCompanies = companies.map(company => ({
        id: company.id,
        name: company.name,
        logo_url: company.logo_url || undefined
      }));

      console.log('[Auth] Companies fetched successfully:', state.value.availableCompanies);
    } catch (error) {
      console.error('[Auth] Error in fetchAvailableCompanies:', error);
      state.value.availableCompanies = [];
      throw error;
    }
  }

  async function setCurrentCompany(companyId: string): Promise<void> {
    if (!state.value.user?.id) {
      throw new AuthError('No user logged in');
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
      await fetchUserRolesAndPermissions();
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
      await fetchUserRolesAndPermissions();

      console.log('[Auth] Company selection complete');
    } catch (error) {
      console.error('[Auth] Error selecting company:', error);
      throw error;
    } finally {
      state.value.loading = false;
    }
  }

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
    console.log('[Auth] State reset complete');
  }

  function clearError(): void {
    state.value.error = null;
  }

  return {
    // Expose state properties
    user: computed(() => state.value.user),
    session: computed(() => state.value.session),
    roles: computed(() => state.value.roles),
    permissions: computed(() => state.value.permissions),
    profile: computed(() => state.value.profile),
    loading: computed(() => state.value.loading),
    error: computed(() => state.value.error),
    availableCompanies: computed(() => state.value.availableCompanies),
    currentCompanyId,
    
    // Getters
    isAuthenticated,
    hasPermission,
    currentCompany,
    userRole,
    needsCompanySelection: computed(() => state.value.needsCompanySelection),
    
    // Actions
    initialize,
    signIn,
    signOut,
    clearError,
    setCurrentCompany,
    fetchAvailableCompanies,
    selectCompany,
    
    // Expose supabase client for direct access
    supabase,
    
    // Session management
    setSession: async (session: Session) => {
      state.value.session = session;
      state.value.user = session.user as User;
      
      try {
        await Promise.all([
          fetchUserProfile(),
          fetchAvailableCompanies(),
          fetchUserRolesAndPermissions()
        ]);
      } catch (error) {
        console.error('[Auth] Error fetching user data:', error);
        resetState();
      }
    },
    success: computed(() => state.value.success)
  };
});