import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface CreateUserRequest {
  email: string
  password: string
  full_name: string
  role_id: string
  company_id: string
  created_by: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders
    })
  }

  try {
    // Create a Supabase client with the service role key
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Get the authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header is required' }),
        { 
          status: 401,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Verify the JWT token
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(
      authHeader.replace('Bearer ', '')
    )

    if (authError || !user) {
      console.error('Auth error:', authError)
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { 
          status: 401,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Check if the user has permission to create users
    const { data: userRole, error: roleError } = await supabaseAdmin
      .from('user_roles')
      .select('role_id, roles!inner(permissions)')
      .eq('user_id', user.id)
      .single()

    if (roleError || !userRole?.roles?.permissions?.includes('users.create')) {
      console.error('Permission error:', roleError)
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions' }),
        { 
          status: 403,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Parse the request body
    const body: CreateUserRequest = await req.json()

    // Create the user
    const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email: body.email,
      password: body.password,
      email_confirm: true,
      user_metadata: {
        full_name: body.full_name,
        created_by: body.created_by,
        created_at: new Date().toISOString()
      }
    })

    if (createError || !newUser.user) {
      console.error('User creation error:', createError)
      return new Response(
        JSON.stringify({ error: 'Failed to create user' }),
        { 
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Create the profile
    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: newUser.user.id,
        full_name: body.full_name,
        email: body.email,
        created_by: body.created_by,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })

    if (profileError) {
      console.error('Profile creation error:', profileError)
      return new Response(
        JSON.stringify({ error: 'Failed to create profile' }),
        { 
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Add to company
    const { error: companyError } = await supabaseAdmin
      .from('user_companies')
      .insert({
        user_id: newUser.user.id,
        company_id: body.company_id,
        status: 'pending',
        created_by: body.created_by,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })

    if (companyError) {
      console.error('Company assignment error:', companyError)
      return new Response(
        JSON.stringify({ error: 'Failed to add user to company' }),
        { 
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Assign role
    const { error: roleAssignError } = await supabaseAdmin
      .from('user_roles')
      .insert({
        user_id: newUser.user.id,
        role_id: body.role_id,
        company_id: body.company_id,
        created_by: body.created_by,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })

    if (roleAssignError) {
      console.error('Role assignment error:', roleAssignError)
      return new Response(
        JSON.stringify({ error: 'Failed to assign role' }),
        { 
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        user: {
          id: newUser.user.id,
          email: newUser.user.email,
          full_name: body.full_name
        }
      }),
      { 
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 200
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )
  }
}) 