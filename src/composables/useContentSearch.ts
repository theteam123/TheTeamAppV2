import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';

interface SearchResult {
  id: string;
  name: string;
  type: string;
  description?: string;
}

export function useContentSearch() {
  const authStore = useAuthStore();
  const loading = ref(false);
  const error = ref<string | null>(null);

  const searchContent = async (query: string): Promise<SearchResult[]> => {
    if (!query || typeof query !== 'string') {
      return [];
    }

    const trimmedQuery = query.trim();
    if (!trimmedQuery) {
      return [];
    }

    loading.value = true;
    error.value = null;

    try {
      // Search in content table
      const { data: contentResults, error: contentError } = await supabase
        .from('content')
        .select('id, name, type, description')
        .eq('company_id', authStore.currentCompanyId)
        .ilike('name', `%${trimmedQuery}%`);

      if (contentError) throw contentError;

      // Search in policies table
      const { data: policyResults, error: policyError } = await supabase
        .from('policies')
        .select('id, name, type, description')
        .eq('company_id', authStore.currentCompanyId)
        .ilike('name', `%${trimmedQuery}%`);

      if (policyError) throw policyError;

      // Combine and format results
      const results: SearchResult[] = [
        ...(contentResults || []).map(item => ({
          id: item.id,
          name: item.name,
          type: item.type || 'content',
          description: item.description
        })),
        ...(policyResults || []).map(item => ({
          id: item.id,
          name: item.name,
          type: 'policy',
          description: item.description
        }))
      ];

      return results;
    } catch (err: any) {
      console.error('Search error:', err);
      error.value = err.message;
      return [];
    } finally {
      loading.value = false;
    }
  };

  return {
    loading,
    error,
    searchContent
  };
} 