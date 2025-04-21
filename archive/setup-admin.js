import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://pukoguerqijfsfqrypev.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1a29ndWVycWlqZnNmcXJ5cGV2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDcyMzQzNywiZXhwIjoyMDYwMjk5NDM3fQ.CsvF_rEkTPiURe-cQntSLrD93QYBLxcNI79Z34jcm_4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function setupAdmin() {
  try {
    // 1. Create the admin user
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: 'paul+app_admin@theteam.net.au',
      password: 'YourSecurePassword123!',
      email_confirm: true
    })

    if (authError) throw authError
    console.log('Admin user created:', authData.user.id)

    // 2. Create the admin profile
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        id: authData.user.id,
        email: 'paul+app_admin@theteam.net.au',
        full_name: 'Paul Johnson (Admin)'
      })

    if (profileError) throw profileError
    console.log('Admin profile created')

    // 3. Get the App_Admin role ID
    const { data: roleData, error: roleError } = await supabase
      .from('roles')
      .select('id')
      .eq('name', 'App_Admin')
      .single()

    if (roleError) throw roleError
    console.log('App_Admin role found:', roleData.id)

    // 4. Assign the App_Admin role
    const { error: userRoleError } = await supabase
      .from('user_roles')
      .insert({
        user_id: authData.user.id,
        role_id: roleData.id
      })

    if (userRoleError) throw userRoleError
    console.log('App_Admin role assigned')

    console.log('Admin setup completed successfully!')
  } catch (error) {
    console.error('Error setting up admin:', error)
  }
}

setupAdmin() 