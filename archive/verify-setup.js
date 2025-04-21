import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://pukoguerqijfsfqrypev.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1a29ndWVycWlqZnNmcXJ5cGV2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDcyMzQzNywiZXhwIjoyMDYwMjk5NDM3fQ.CsvF_rEkTPiURe-cQntSLrD93QYBLxcNI79Z34jcm_4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function verifySetup() {
  try {
    // 1. Check if tables exist
    const tables = ['profiles', 'companies', 'roles', 'role_permissions', 'user_roles', 'user_companies']
    for (const table of tables) {
      const { error } = await supabase.from(table).select('*').limit(1)
      if (error) {
        console.error(`Table ${table} does not exist or is not accessible:`, error)
      } else {
        console.log(`Table ${table} exists and is accessible`)
      }
    }

    // 2. Check if App_Admin role exists
    const { data: roleData, error: roleError } = await supabase
      .from('roles')
      .select('*')
      .eq('name', 'App_Admin')
      .single()

    if (roleError) {
      console.error('App_Admin role not found:', roleError)
    } else {
      console.log('App_Admin role exists:', roleData)
    }

    // 3. Check if admin user exists
    const { data: adminData, error: adminError } = await supabase
      .from('profiles')
      .select('*')
      .eq('email', 'paul+app_admin@theteam.net.au')
      .single()

    if (adminError) {
      console.error('Admin user not found:', adminError)
    } else {
      console.log('Admin user exists:', adminData)
    }

    // 4. Check if admin has App_Admin role
    if (adminData) {
      const { data: userRoleData, error: userRoleError } = await supabase
        .from('user_roles')
        .select('*')
        .eq('user_id', adminData.id)
        .eq('role_id', roleData?.id)
        .single()

      if (userRoleError) {
        console.error('Admin role assignment not found:', userRoleError)
      } else {
        console.log('Admin role assignment exists:', userRoleData)
      }
    }

    // 5. Check RLS policies
    const { data: policies, error: policiesError } = await supabase
      .from('pg_policies')
      .select('*')
      .in('tablename', tables)

    if (policiesError) {
      console.error('Error checking RLS policies:', policiesError)
    } else {
      console.log('RLS policies exist for tables:', policies.map(p => p.tablename))
    }

  } catch (error) {
    console.error('Error verifying setup:', error)
  }
}

verifySetup() 