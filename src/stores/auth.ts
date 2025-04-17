import { defineStore } from 'pinia';
import { supabase } from '../lib/supabase';
import type { User } from '@supabase/supabase-js';
import type { Profile } from '../lib/types';

// Custom error classes for better error handling
class AuthError extends Error {
  constructor(message: string, public readonly code?: string) {
    super(message);
    this.name = 'AuthError';
  }
}

class ProfileError extends Error {
  constructor(message: string, public readonly userId?: string) {
    super(message);
    this.name = 'ProfileError';
  }
}

interface AuthState {
  user: User | null;
  session: any;
  roles: string[];
  permissions: string[];
  loading: boolean;
  error: string | null;
  availableCompanies: any[];
  currentCompanyId: string | null;
  retryCount: number;
}

const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // 1 second

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    session: null,
    roles: [],
    permissions: [],
    loading: false,
    error: null,
    availableCompanies: [],
    currentCompanyId: null,
    retryCount: 0
  }),

  getters: {
    isAuthenticated: (state) => !!state.user && !!state.session,
    hasPermission: (state) => (permission: string) => {
      if (!permission || typeof permission !== 'string') {
        console.warn('Invalid permission check:', permission);
        return false;
      }
      return state.permissions.includes(permission);
    },
    currentCompany: (state) => {
      const company = state.availableCompanies.find(c => c.id === state.currentCompanyId);
      if (!company && state.currentCompanyId) {
        console.warn('Current company not found in available companies');
      }
      return company;
    },
    userRole: (state) => state.roles.length > 0 ? state.roles[0] : 'Regular User'
  },

  actions: {
    async fetchUser() {
      const startTime = Date.now();
      console.log('[Auth] fetchUser started', { timestamp: new Date().toISOString() });
      
      this.loading = true;
      try {
        const { data: { user, session }, error } = await supabase.auth.getSession();
        
        if (error) {
          throw new AuthError(error.message, error.status?.toString());
        }

        if (user && session) {
          this.user = user;
          this.session = session;

          try {
            // Fetch all user data in parallel with timeout
            await Promise.race([
              Promise.all([
                this.fetchUserProfile(user.id),
                this.fetchAvailableCompanies(user.id)
              ]),
              new Promise((_, reject) => 
                setTimeout(() => reject(new Error('Data fetch timeout')), 10000)
              )
            ]);

            if (!this.currentCompanyId && this.availableCompanies.length > 0) {
              const defaultCompanyId = this.user?.profile?.current_company_id || this.availableCompanies[0].id;
              await this.setCurrentCompany(defaultCompanyId);
            }

            await this.fetchUserRolesAndPermissions(user.id);

          } catch (dataError: any) {
            console.error('[Auth] Error fetching user data:', {
              error: dataError,
              userId: user.id,
              timestamp: new Date().toISOString()
            });
            
            // Attempt recovery
            if (this.retryCount < MAX_RETRIES) {
              this.retryCount++;
              await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
              return this.fetchUser();
            }
            
            throw dataError;
          }
        } else {
          this.resetState();
        }
      } catch (error: any) {
        const errorContext = {
          timestamp: new Date().toISOString(),
          duration: Date.now() - startTime,
          error: {
            name: error.name,
            message: error.message,
            code: error.code,
            stack: error.stack
          },
          state: {
            hasUser: !!this.user,
            hasSession: !!this.session,
            companyCount: this.availableCompanies.length,
            retryCount: this.retryCount
          }
        };
        
        console.error('[Auth] fetchUser error:', errorContext);
        this.error = error.message;
        this.resetState();
        throw error;
      } finally {
        this.loading = false;
        this.retryCount = 0;
        console.log('[Auth] fetchUser completed', {
          duration: Date.now() - startTime,
          timestamp: new Date().toISOString()
        });
      }
    },

    resetState() {
      const previousState = { ...this.$state };
      
      this.user = null;
      this.session = null;
      this.roles = [];
      this.permissions = [];
      this.availableCompanies = [];
      this.currentCompanyId = null;
      this.error = null;
      
      console.log('[Auth] State reset', {
        timestamp: new Date().toISOString(),
        previousState,
        newState: { ...this.$state }
      });
    },

    async fetchUserProfile(userId: string) {
      if (!userId) {
        throw new ProfileError('User ID is required');
      }

      try {
        const { data: profile, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

        if (error) {
          throw new ProfileError(`Failed to fetch profile: ${error.message}`, userId);
        }

        if (!profile) {
          throw new ProfileError('Profile not found', userId);
        }

        if (this.user) {
          this.user = { ...this.user, profile } as User;
        }
        
        return profile;
      } catch (error: any) {
        console.error('[Auth] Error fetching profile:', {
          error,
          userId,
          timestamp: new Date().toISOString()
        });
        throw error;
      }
    },

    async fetchUserRolesAndPermissions(userId: string) {
      if (!userId || !this.currentCompanyId) {
        throw new Error('User ID and Company ID are required');
      }

      try {
        console.log('[Auth] Fetching roles and permissions:', {
          userId,
          currentCompanyId: this.currentCompanyId,
          timestamp: new Date().toISOString()
        });

        const { data: userRoles, error: userRolesError } = await supabase
          .from('user_roles')
          .select(`
            role_id,
            company_id,
            roles (
              id,
              name,
              description,
              role_permissions (
                permission_key
              )
            )
          `)
          .eq('user_id', userId)
          .eq('company_id', this.currentCompanyId);

        if (userRolesError) {
          throw new Error(`Failed to fetch user roles: ${userRolesError.message}`);
        }

        if (userRoles && userRoles.length > 0) {
          // Safely map roles, filtering out any null values
          this.roles = userRoles
            .filter(ur => ur.roles && ur.roles.name)
            .map(ur => ur.roles.name);

          // Safely map permissions, handling potential null values
          this.permissions = userRoles
            .filter(ur => ur.roles && Array.isArray(ur.roles.role_permissions))
            .flatMap(ur => 
              ur.roles.role_permissions
                .filter(rp => rp && rp.permission_key)
                .map(rp => rp.permission_key)
            );

          console.log('[Auth] Roles and permissions updated:', {
            roles: this.roles,
            permissionCount: this.permissions.length,
            timestamp: new Date().toISOString()
          });
        } else {
          console.warn('[Auth] No roles found for user in company', {
            userId,
            companyId: this.currentCompanyId,
            timestamp: new Date().toISOString()
          });
          this.roles = ['Regular User'];
          this.permissions = [];
        }
        
        return userRoles;
      } catch (error: any) {
        console.error('[Auth] Error in fetchUserRolesAndPermissions:', {
          error,
          userId,
          companyId: this.currentCompanyId,
          timestamp: new Date().toISOString()
        });
        this.roles = ['Regular User'];
        this.permissions = [];
        throw error;
      }
    },

    async fetchAvailableCompanies(userId: string) {
      try {
        const { data: companies, error } = await supabase
          .from('user_companies')
          .select(`
            company_id,
            companies (
              id,
              name,
              website
            )
          `)
          .eq('user_id', userId);

        if (error) throw error;

        this.availableCompanies = companies.map(uc => ({
          id: uc.companies.id,
          name: uc.companies.name,
          website: uc.companies.website
        }));
        
        return companies;
      } catch (error: any) {
        console.error('Error fetching available companies:', error);
        throw error;
      }
    },

    async setCurrentCompany(companyId: string) {
      this.loading = true;
      try {
        console.log('Setting current company:', companyId);

        const { error } = await supabase
          .from('profiles')
          .update({ current_company_id: companyId })
          .eq('id', this.user?.id);

        if (error) throw error;

        this.currentCompanyId = companyId;
        if (this.user?.profile) {
          this.user.profile.current_company_id = companyId;
        }

        // Refresh roles and permissions for new company context
        await this.fetchUserRolesAndPermissions(this.user?.id || '');

        console.log('Current company updated:', {
          companyId: this.currentCompanyId,
          roles: this.roles,
          permissions: this.permissions
        });
      } catch (error: any) {
        console.error('Error setting current company:', error);
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async signUp(email: string, password: string, fullName: string) {
      this.loading = true;
      this.error = null;
      try {
        const { data, error: signUpError } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              full_name: fullName
            }
          }
        });

        if (signUpError) throw signUpError;
        if (!data.user) throw new Error('User creation failed');

        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: data.user.id,
            email,
            full_name: fullName
          });

        if (profileError) throw profileError;

        const { data: company, error: companyError } = await supabase
          .from('companies')
          .insert({
            name: `${fullName}'s Company`
          })
          .select()
          .single();

        if (companyError) throw companyError;

        const { error: userCompanyError } = await supabase
          .from('user_companies')
          .insert({
            user_id: data.user.id,
            company_id: company.id
          });

        if (userCompanyError) throw userCompanyError;

        const { error: roleError } = await supabase
          .from('user_roles')
          .insert({
            user_id: data.user.id,
            role_id: '00000000-0000-0000-0000-000000000001',
            company_id: company.id
          });

        if (roleError) throw roleError;

        const { error: updateError } = await supabase
          .from('profiles')
          .update({ current_company_id: company.id })
          .eq('id', data.user.id);

        if (updateError) throw updateError;

        this.user = data.user;
        this.session = data.session;
        await this.fetchUser();

      } catch (error: any) {
        this.error = error.message;
        this.resetState();
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async signIn(email: string, password: string, rememberMe: boolean = false) {
      this.loading = true;
      this.error = null;
      try {
        const { data: { user, session }, error } = await supabase.auth.signInWithPassword({
          email,
          password,
          options: {
            persistSession: rememberMe
          }
        });

        if (error) throw error;

        this.user = user;
        this.session = session;

        if (user) {
          await Promise.all([
            this.fetchUserProfile(user.id),
            this.fetchAvailableCompanies(user.id)
          ]);

          // Set current company ID if not already set
          if (!this.currentCompanyId && this.availableCompanies.length > 0) {
            const defaultCompanyId = this.user?.profile?.current_company_id || this.availableCompanies[0].id;
            await this.setCurrentCompany(defaultCompanyId);
          }

          // Fetch roles and permissions after company is set
          await this.fetchUserRolesAndPermissions(user.id);
        }
      } catch (error: any) {
        this.error = error.message;
        this.resetState();
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async signOut() {
      this.loading = true;
      try {
        const { error } = await supabase.auth.signOut();
        if (error) throw error;
        this.resetState();
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    clearError() {
      this.error = null;
    }
  }
});