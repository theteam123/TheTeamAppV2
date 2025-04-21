import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://pukoguerqijfsfqrypev.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1a29ndWVycWlqZnNmcXJ5cGV2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDcyMzQzNywiZXhwIjoyMDYwMjk5NDM3fQ.CsvF_rEkTPiURe-cQntSLrD93QYBLxcNI79Z34jcm_4'

const supabase = createClient(supabaseUrl, supabaseKey)

// List of users to delete
const usersToDelete = [
  '589e8bbe-c972-4223-8454-839eab306ca0', // paul@theteam.net.au
  'c194aba1-86a5-4df9-9e3a-b38abbd928fe', // meryl@theteam.net.au
  '3b0040d6-70b9-4f9d-9de7-aa9cee6d3c5f', // rachel@theteam.net.au
  '9dcfbee0-4f72-472d-8c9b-d4bd2de90abe', // paul+super_admin@theteam.net.au
  '4578c9c6-d8f3-4eaf-a476-33bd6ee07f78', // paul+company_admin@theteam.net.au
  'ffc692ce-0eaf-466b-9684-dbf98832f49b'  // paul+company_user@theteam.net.au
]

async function cleanupReferences(userId) {
  console.log(`Cleaning up references for user ${userId}...`)
  
  // Clean up user_roles
  const { error: rolesError } = await supabase
    .from('user_roles')
    .delete()
    .eq('user_id', userId)
  
  if (rolesError) console.error('Error cleaning up user_roles:', rolesError)
  
  // Clean up user_companies
  const { error: companiesError } = await supabase
    .from('user_companies')
    .delete()
    .eq('user_id', userId)
  
  if (companiesError) console.error('Error cleaning up user_companies:', companiesError)
  
  // Clean up audit_log
  const { error: auditError } = await supabase
    .from('audit_log')
    .delete()
    .eq('performed_by', userId)
  
  if (auditError) console.error('Error cleaning up audit_log:', auditError)
  
  // Clean up content
  const { error: contentError } = await supabase
    .from('content')
    .delete()
    .eq('updated_by', userId)
  
  if (contentError) console.error('Error cleaning up content:', contentError)
  
  // Clean up profiles
  const { error: profilesError } = await supabase
    .from('profiles')
    .delete()
    .eq('id', userId)
  
  if (profilesError) console.error('Error cleaning up profiles:', profilesError)
}

async function deleteUser(userId) {
  console.log(`Attempting to delete user ${userId}...`)
  
  // First clean up all references
  await cleanupReferences(userId)
  
  // Then try to delete the user
  const { data, error } = await supabase.auth.admin.deleteUser(userId)
  
  if (error) {
    console.error('Error deleting user:', error)
    return false
  } else {
    console.log('Successfully deleted user:', data)
    return true
  }
}

// Delete all users
async function deleteAllUsers() {
  for (const userId of usersToDelete) {
    const success = await deleteUser(userId)
    if (!success) {
      console.log(`Failed to delete user ${userId}, continuing with next user...`)
    }
    // Add a small delay between deletions
    await new Promise(resolve => setTimeout(resolve, 1000))
  }
}

// Run the deletion process
deleteAllUsers()
  .then(() => console.log('Finished processing all users'))
  .catch(error => console.error('Error in deletion process:', error)) 