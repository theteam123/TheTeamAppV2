import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://pukoguerqijfsfqrypev.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1a29ndWVycWlqZnNmcXJ5cGV2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDcyMzQzNywiZXhwIjoyMDYwMjk5NDM3fQ.CsvF_rEkTPiURe-cQntSLrD93QYBLxcNI79Z34jcm_4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function runMigration() {
  try {
    console.log('Starting migration...')

    // 1. Create helper functions
    console.log('Creating helper functions...')
    const { error: functionError } = await supabase.rpc('create_helper_functions')
    if (functionError) throw functionError

    // 2. Create tables
    console.log('Creating tables...')
    const { error: tableError } = await supabase.rpc('create_tables')
    if (tableError) throw tableError

    // 3. Enable RLS
    console.log('Enabling RLS...')
    const { error: rlsError } = await supabase.rpc('enable_rls')
    if (rlsError) throw rlsError

    // 4. Create policies
    console.log('Creating policies...')
    const { error: policyError } = await supabase.rpc('create_policies')
    if (policyError) throw policyError

    // 5. Create indexes
    console.log('Creating indexes...')
    const { error: indexError } = await supabase.rpc('create_indexes')
    if (indexError) throw indexError

    // 6. Create App_Admin role
    console.log('Creating App_Admin role...')
    const { error: roleError } = await supabase.rpc('create_app_admin_role')
    if (roleError) throw roleError

    console.log('Migration completed successfully!')
  } catch (error) {
    console.error('Migration failed:', error)
  }
}

runMigration() 