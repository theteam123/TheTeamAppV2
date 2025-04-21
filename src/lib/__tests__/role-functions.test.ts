import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { hasRole, hasPermission, hasSystemRole, hasAllPermissions, hasAnyPermission } from '../role-functions';
import { supabase } from '../supabase';

// Mock supabase
jest.mock('../supabase', () => ({
  supabase: {
    rpc: jest.fn()
  }
}));

describe('Role Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('hasRole', () => {
    it('should return true when user has the role', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: true, error: null });
      const result = await hasRole('App_Admin');
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_role', { role_name: 'App_Admin' });
    });

    it('should return false when user does not have the role', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: false, error: null });
      const result = await hasRole('App_Admin');
      expect(result).toBe(false);
    });

    it('should return false on error', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: null, error: new Error('Test error') });
      const result = await hasRole('App_Admin');
      expect(result).toBe(false);
    });
  });

  describe('hasPermission', () => {
    it('should return true when user has the permission', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: true, error: null });
      const result = await hasPermission('users.view');
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_permission', { permission_key: 'users.view' });
    });

    it('should return false when user does not have the permission', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: false, error: null });
      const result = await hasPermission('users.view');
      expect(result).toBe(false);
    });
  });

  describe('hasSystemRole', () => {
    it('should return true when user has the system role', async () => {
      (supabase.rpc as jest.Mock).mockResolvedValueOnce({ data: true, error: null });
      const result = await hasSystemRole('App_Admin');
      expect(result).toBe(true);
      expect(supabase.rpc).toHaveBeenCalledWith('has_system_role', { role_name: 'App_Admin' });
    });
  });

  describe('hasAllPermissions', () => {
    it('should return true when user has all permissions', async () => {
      (supabase.rpc as jest.Mock)
        .mockResolvedValueOnce({ data: true, error: null })
        .mockResolvedValueOnce({ data: true, error: null });
      const result = await hasAllPermissions(['users.view', 'users.edit']);
      expect(result).toBe(true);
    });

    it('should return false when user does not have all permissions', async () => {
      (supabase.rpc as jest.Mock)
        .mockResolvedValueOnce({ data: true, error: null })
        .mockResolvedValueOnce({ data: false, error: null });
      const result = await hasAllPermissions(['users.view', 'users.edit']);
      expect(result).toBe(false);
    });
  });

  describe('hasAnyPermission', () => {
    it('should return true when user has any permission', async () => {
      (supabase.rpc as jest.Mock)
        .mockResolvedValueOnce({ data: false, error: null })
        .mockResolvedValueOnce({ data: true, error: null });
      const result = await hasAnyPermission(['users.view', 'users.edit']);
      expect(result).toBe(true);
    });

    it('should return false when user has no permissions', async () => {
      (supabase.rpc as jest.Mock)
        .mockResolvedValueOnce({ data: false, error: null })
        .mockResolvedValueOnce({ data: false, error: null });
      const result = await hasAnyPermission(['users.view', 'users.edit']);
      expect(result).toBe(false);
    });
  });
}); 