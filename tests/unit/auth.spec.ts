import { describe, it, expect, beforeEach, vi } from 'vitest';
import { setActivePinia, createPinia } from 'pinia';
import { useAuthStore } from '../../src/stores/auth';
import { supabase } from '../../src/lib/supabase';
import { AuthError, User, Session } from '@supabase/supabase-js';
import { PostgrestResponse, PostgrestSingleResponse, PostgrestQueryBuilder } from '@supabase/postgrest-js';
import type { Mock } from 'vitest';

// Mock Supabase client
vi.mock('../../src/lib/supabase', () => ({
  supabase: {
    auth: {
      signInWithPassword: vi.fn(),
      signOut: vi.fn(),
      getSession: vi.fn(),
      onAuthStateChange: vi.fn()
    },
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          single: vi.fn(),
          in: vi.fn()
        })),
        in: vi.fn()
      })),
      update: vi.fn(() => ({
        eq: vi.fn()
      }))
    }))
  }
}));

describe('Auth Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    vi.clearAllMocks();
  });

  describe('signIn', () => {
    it('should sign in successfully with single company', async () => {
      const authStore = useAuthStore();
      const mockUser: User = {
        id: 'test-user-id',
        app_metadata: {},
        user_metadata: {},
        aud: 'authenticated',
        created_at: '',
        role: '',
        email: 'test@example.com'
      };
      const mockSession: Session = {
        access_token: 'test-token',
        token_type: 'bearer',
        expires_in: 3600,
        refresh_token: 'test-refresh',
        user: mockUser
      };

      (supabase.auth.signInWithPassword as any).mockResolvedValue({
        data: { user: mockUser, session: mockSession },
        error: null
      });

      const mockPostgrestResponse = {
        data: [{ company_id: 'test-company-id', name: 'Test Company' }],
        error: null,
        status: 200,
        statusText: 'OK',
        count: null
      };

      const mockQueryBuilder = {
        select: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        update: vi.fn().mockReturnThis(),
        delete: vi.fn().mockReturnThis(),
        upsert: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        filter: vi.fn().mockReturnThis(),
        order: vi.fn().mockReturnThis(),
        limit: vi.fn().mockReturnThis(),
        single: vi.fn().mockReturnThis(),
        then: vi.fn().mockReturnThis(),
        throwOnError: vi.fn().mockReturnThis(),
        url: new URL('http://localhost:3000'),
        headers: {},
        schema: 'public',
        body: null,
        method: 'GET' as const,
        allowEmpty: false,
        shouldThrowOnError: false,
        signal: undefined,
        fetch: vi.fn(),
        abortController: new AbortController(),
        count: vi.fn().mockReturnThis(),
        maybeSingle: vi.fn().mockReturnThis(),
        range: vi.fn().mockReturnThis(),
        match: vi.fn().mockReturnThis(),
        neq: vi.fn().mockReturnThis(),
        gt: vi.fn().mockReturnThis(),
        gte: vi.fn().mockReturnThis(),
        lt: vi.fn().mockReturnThis(),
        lte: vi.fn().mockReturnThis(),
        like: vi.fn().mockReturnThis(),
        ilike: vi.fn().mockReturnThis(),
        is: vi.fn().mockReturnThis(),
        in: vi.fn().mockReturnThis(),
        contains: vi.fn().mockReturnThis(),
        containedBy: vi.fn().mockReturnThis(),
        overlaps: vi.fn().mockReturnThis(),
        textSearch: vi.fn().mockReturnThis(),
        not: vi.fn().mockReturnThis(),
        or: vi.fn().mockReturnThis()
      } as PostgrestQueryBuilder<any, any, string, unknown>;

      const mockFrom = vi.fn().mockReturnValue(mockQueryBuilder);

      (supabase.from as any).mockImplementation(mockFrom);

      await authStore.signIn('test@example.com', 'password');

      expect(authStore.user).toBeTruthy();
      expect(authStore.session).toBeTruthy();
    });

    it('should handle login failure', async () => {
      const authStore = useAuthStore();
      const mockError = new Error('Invalid credentials') as AuthError;
      mockError.status = 400;
      mockError.name = 'AuthError';

      (supabase.auth.signInWithPassword as any).mockResolvedValue({
        data: { user: null, session: null },
        error: mockError
      });

      await expect(authStore.signIn('test@example.com', 'wrong-password'))
        .rejects.toThrow('Invalid credentials');
    });
  });

  describe('selectCompany', () => {
    it('should select company successfully', async () => {
      const authStore = useAuthStore();
      const mockPostgrestResponse: PostgrestResponse<any> = {
        data: [{ role: 'admin' }],
        error: null,
        count: null,
        status: 200,
        statusText: 'OK'
      };

      const mockFrom = vi.fn().mockReturnValue({
        update: vi.fn().mockResolvedValue(mockPostgrestResponse),
        select: vi.fn().mockResolvedValue(mockPostgrestResponse)
      } as unknown as PostgrestQueryBuilder<any, any>);

      (supabase.from as any).mockImplementation(mockFrom);

      await authStore.selectCompany('test-company-id');

      expect(authStore.currentCompanyId).toBe('test-company-id');
    });

    it('should handle company selection failure', async () => {
      const auth = useAuthStore();
      
      vi.mocked(supabase.from).mockImplementation((table) => ({
        update: vi.fn().mockReturnValue({
          eq: vi.fn().mockResolvedValue({ error: new Error('Update failed') })
        })
      }));

      await expect(auth.selectCompany('invalid')).rejects.toThrow();
      expect(auth.needsCompanySelection).toBe(true);
    });
  });
}); 