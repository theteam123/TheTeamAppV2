import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl) {
  throw new Error('Missing VITE_SUPABASE_URL environment variable')
}

if (!supabaseAnonKey) {
  throw new Error('Missing VITE_SUPABASE_ANON_KEY environment variable')
}

console.log('[Supabase] Initializing client with URL:', supabaseUrl)

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    storageKey: 'theteam-auth',
    storage: window.localStorage,
    flowType: 'pkce',
    detectSessionInUrl: true
  }
})

// Test the connection
supabase.auth.getSession().then(({ data, error }) => {
  if (error) {
    console.error('[Supabase] Initial connection test failed:', error)
  } else {
    console.log('[Supabase] Initial connection test successful')
  }
})