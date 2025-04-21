import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { PermissionKeys, checkPermission, checkAllPermissions, checkAnyPermission, checkRole, checkSystemRole } from '../permissions';
import { supabase } from '../supabase';

// Mock supabase
jest.mock('../supabase', () => ({
  supabase: {
    rpc: jest.fn().mockImplementation(() => Promise.resolve({ data: true, error: null }))
  }
}));

describe('Permissions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('PermissionKeys', () => {
    it('should have correct user permissions', () => {
      expect(PermissionKeys.users.view).toBe('users.view');
      expect(PermissionKeys.users.create).toBe('users.create');
      expect(PermissionKeys.users.edit).toBe('users.edit');
      expect(PermissionKeys.users.delete).toBe('users.delete');
    });

    it('should have correct company permissions', () => {
      expect(PermissionKeys.companies.view).toBe('companies.view');
      expect(PermissionKeys.companies.create).toBe('companies.create');
      expect(PermissionKeys.companies.edit).toBe('companies.edit');
      expect(PermissionKeys.companies.delete).toBe('companies.delete');
    });
  });

  describe('checkPermission', () => {
    it('should check a single permission', async () => {
      const result = await checkPermission(PermissionKeys.users.view);
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_permission', { permission_key: 'users.view' });
    });
  });

  describe('checkAllPermissions', () => {
    it('should check multiple permissions', async () => {
      const result = await checkAllPermissions([PermissionKeys.users.view, PermissionKeys.users.edit]);
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledTimes(2);
    });
  });

  describe('checkAnyPermission', () => {
    it('should check if any permission is granted', async () => {
      const result = await checkAnyPermission([PermissionKeys.users.view, PermissionKeys.users.edit]);
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledTimes(2);
    });
  });

  describe('checkRole', () => {
    it('should check if user has a role', async () => {
      const result = await checkRole('App_Admin');
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_role', { role_name: 'App_Admin' });
    });
  });

  describe('checkSystemRole', () => {
    it('should check if user has a system role', async () => {
      const result = await checkSystemRole('App_Admin');
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_system_role', { role_name: 'App_Admin' });
    });
  });
}); 