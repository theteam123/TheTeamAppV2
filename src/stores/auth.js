import { defineStore } from 'pinia';
import { supabase } from '../lib/supabase';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    session: null,
    roles: [],
    permissions: [],
    loading: false,
    error: null,
    availableCompanies: [],
    currentCompanyId: null
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    hasPermission: (state) => (permission) => state.permissions.includes(permission),
    currentCompany: (state) => state.availableCompanies.find(c => c.id === state.currentCompanyId),
    userRole: (state) => state.roles[0] || 'User'
  },

  actions: {
    async fetchUser() {
      this.loading = true;
      try {
        const { data: { user, session }, error } = await supabase.auth.getSession();

        if (error) throw error;

        this.user = user;
        this.session = session;

        if (user) {
          await this.fetchUserProfile(user.id);
          await this.fetchUserRolesAndPermissions(user.id);
          await this.fetchAvailableCompanies(user.id);
          this.currentCompanyId = this.user.profile?.current_company_id || null;
        }
      } catch (error) {
        this.error = error.message;
        this.user = null;
        this.session = null;
        this.roles = [];
        this.permissions = [];
        this.availableCompanies = [];
        this.currentCompanyId = null;
      } finally {
        this.loading = false;
      }
    },

    async fetchUserProfile(userId) {
      try {
        const { data: profile, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

        if (error) throw error;

        this.user = { ...this.user, profile };
      } catch (error) {
        console.error('Error fetching profile:', error);
      }
    },

    async fetchUserRolesAndPermissions(userId) {
      try {
        const { data: userRoles, error: userRolesError } = await supabase
          .from('user_roles')
          .select(`
            *,
            roles (
              name
            )
          `)
          .eq('user_id', userId);

        if (userRolesError) throw userRolesError;

        this.roles = userRoles
          .filter(ur => ur.roles && ur.roles.name)
          .map(ur => ur.roles.name);

        if (userRoles.length > 0) {
          const roleIds = userRoles.map(ur => ur.role_id);
          const { data: rolePermissions, error: rolePermissionsError } = await supabase
            .from('role_permissions')
            .select('*')
            .in('role_id', roleIds);

          if (rolePermissionsError) throw rolePermissionsError;

          this.permissions = rolePermissions.map(rp => rp.permission_key);
        } else {
          this.roles = ['User'];
          this.permissions = [];
        }

      } catch (error) {
        console.error('Error fetching roles and permissions:', error);
        this.roles = ['User'];
        this.permissions = [];
      }
    },

    async fetchAvailableCompanies(userId) {
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
      } catch (error) {
        console.error('Error fetching available companies:', error);
        this.availableCompanies = [];
      }
    },

    async setCurrentCompany(companyId) {
      this.loading = true;
      try {
        const { error } = await supabase
          .from('profiles')
          .update({ current_company_id: companyId })
          .eq('id', this.user.id);

        if (error) throw error;

        this.currentCompanyId = companyId;
        this.user.profile.current_company_id = companyId;
      } catch (error) {
        console.error('Error setting current company:', error);
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },

    async signIn(email, password) {
      this.loading = true;
      this.error = null;
      try {
        const { data: { user, session }, error } = await supabase.auth.signInWithPassword({
          email,
          password
        });

        if (error) throw error;

        this.user = user;
        this.session = session;

        await this.fetchUserProfile(user.id);
        await this.fetchUserRolesAndPermissions(user.id);
        await this.fetchAvailableCompanies(user.id);
        this.currentCompanyId = this.user.profile?.current_company_id || null;
      } catch (error) {
        this.error = error.message;
        this.user = null;
        this.session = null;
        this.roles = ['User'];
        this.permissions = [];
        this.availableCompanies = [];
        this.currentCompanyId = null;
      } finally {
        this.loading = false;
      }
    },

    async signOut() {
      this.loading = true;
      try {
        const { error } = await supabase.auth.signOut();
        if (error) throw error;
        
        this.user = null;
        this.session = null;
        this.roles = ['User'];
        this.permissions = [];
        this.availableCompanies = [];
        this.currentCompanyId = null;
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },

    clearError() {
      this.error = null;
    }
  }
});