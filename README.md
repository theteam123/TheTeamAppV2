# TheTeam App

A modern web application for team management and content organization, built with a multi-tenant architecture to support multiple companies within a single database.

## Features

- User authentication and authorization
- Company management
- Role-based access control
- Content management
- Tag organization
- Menu section management
- Debug tools
- Multi-tenant support

## Architecture

TheTeam App is designed as a multi-tenant application with a single multi-tenant database, providing:

- Support for multiple companies (tenants) within a single application instance
- Independent operation for each company with its own users, roles, and content
- Data isolation through Row Level Security (RLS) policies
- Company-specific access controls and permissions
- Efficient resource utilization and simplified maintenance

## Tech Stack

- Vue 3 with TypeScript
- Pinia for state management
- Vue Router for navigation
- Supabase for backend services
- Tailwind CSS for styling
- Lucide Icons for icons

## Prerequisites

- Node.js 16.x or later
- npm 7.x or later
- Supabase account and project

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd theteamapp
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory with your Supabase credentials:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Start the development server:
```bash
npm run dev
```

## Project Structure

```
project-root/
├── src/                    # Production source code
│   ├── components/        # Reusable UI components
│   ├── composables/       # Vue composition functions
│   ├── lib/              # Utility functions and types
│   ├── pages/            # Page components
│   ├── router/           # Vue Router configuration
│   ├── stores/           # Pinia stores
│   ├── layouts/          # Layout components
│   ├── __tests__/        # Test files
│   │   └── unit/        # Unit tests
│   ├── App.vue           # Main app component
│   ├── main.ts           # Entry point
│   ├── routes.ts         # Route definitions
│   ├── index.css         # Global styles
│   └── env.d.ts          # Environment type definitions
├── public/               # Static assets
├── archive/             # Archived files
│   ├── migrations/      # Database migration and setup scripts
│   │   ├── backup/     # Backup of previously applied migrations
│   │   └── discarded/  # Historical/replaced migrations
│   └── bolt_backup/    # Old Bolt project files
├── .cursor/             # Cursor IDE settings
├── .husky/              # Git hooks for pre-commit
├── .vscode/            # VS Code settings
├── package.json         # Project dependencies
├── tsconfig.json       # TypeScript configuration
├── vite.config.ts      # Vite configuration
├── vitest.config.ts    # Vitest configuration
├── tailwind.config.js  # Tailwind configuration
├── .eslintrc.json     # ESLint configuration
├── .prettierrc        # Prettier configuration
└── README.md          # Project documentation
```

## Archived Files

The `archive/` directory contains historical and development-related files that are no longer needed for production but are kept for reference:

- `migrations/`: Contains database migration scripts and initial setup files
- `diagnostics/`: Contains verification and diagnostic scripts used during development
- `fixes/`: Contains one-time fix scripts used to resolve specific issues
- `backups/`: Contains database backup files

These files are preserved for:
- Historical reference
- Rollback procedures
- Development documentation
- Troubleshooting reference

## Development

- Use `npm run dev` for development
- Use `npm run build` for production build
- Use `npm run test` to run tests

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT

## Role and Permission System

## Overview
The application uses a role-based access control (RBAC) system with the following key components:
- System Roles (App_Admin)
- Company-specific roles
- Granular permissions
- Row-Level Security (RLS)

## Database Schema

### Tables
- `roles`: Defines available roles
- `role_permissions`: Maps roles to permissions
- `user_roles`: Associates users with roles
- `user_companies`: Maps users to companies

### Security Functions
All security functions use `SECURITY DEFINER` to prevent RLS recursion:

```sql
has_permission(permission_key text) -> boolean
has_role(role_name text) -> boolean
is_app_admin() -> boolean
has_company_access(company_id uuid) -> boolean
has_system_role() -> boolean
```

## Permission Keys

### User Management
- users.view
- users.create
- users.edit
- users.delete

### Company Management
- companies.view
- companies.create
- companies.edit
- companies.delete

### Role Management
- roles.view
- roles.create
- roles.edit
- roles.delete

### Content Management
- content.view
- content.create
- content.edit
- content.delete

### System Management
- system.manage
- system.audit
- system.settings

## Implementation Guide

### Frontend Usage
```typescript
// Check permissions
const canViewUsers = await supabase.rpc('has_permission', { permission_key: 'users.view' });

// Check roles
const isAdmin = await supabase.rpc('is_app_admin');

// Check company access
const hasAccess = await supabase.rpc('has_company_access', { company_id: 'uuid-here' });
```

### Route Guards
```typescript
// Example route guard
const requirePermission = (permission: string) => {
  return async (to: Route, from: Route, next: NavigationGuardNext) => {
    const { data: hasPermission } = await supabase.rpc('has_permission', { 
      permission_key: permission 
    });
    
    if (hasPermission) {
      next();
    } else {
      next('/unauthorized');
    }
  };
};
```

### Database Policies
```sql
-- Example RLS policy using security functions
CREATE POLICY "Users can view companies"
  ON companies
  FOR SELECT
  TO authenticated
  USING (
    is_app_admin() OR 
    has_company_access(id)
  );
```

## Audit Logging
All important role and permission changes are logged in the `audit_logs` table:
- Role assignments
- Permission changes
- Company access modifications

## Best Practices
1. Always use security functions in RLS policies
2. Check permissions at both frontend and backend
3. Use system roles sparingly
4. Keep audit logs for all security changes
5. Test permission changes thoroughly

## Migration Guide
When making changes to the security system:
1. Create new roles/permissions before removing old ones
2. Update RLS policies to use new functions
3. Test thoroughly with different user types
4. Monitor audit logs for unexpected changes

## Troubleshooting
Common issues and solutions:
1. Infinite recursion in RLS policies
   - Use SECURITY DEFINER functions
   - Avoid circular dependencies
2. Permission denied errors
   - Check RLS policies
   - Verify user role assignments
3. Company access issues
   - Verify user_companies entries
   - Check company-specific roles

## Multi-Tenant Architecture

The application implements a multi-tenant architecture with single-tenant logic, ensuring data isolation and security between different companies while maintaining a unified codebase.

### Key Features

#### 1. Data Isolation
- Each company's data is logically separated using Row Level Security (RLS)
- Users can only access data from companies they belong to
- System roles (like App_Admin) can access data across all companies
- Company-specific roles are scoped to their respective companies

#### 2. User Scoping
- Users can belong to multiple companies
- Each user-company relationship can have different roles and permissions
- User access is controlled through the `user_companies` table
- System-wide permissions are managed through the `user_roles` table

#### 3. Audit Logging
- Comprehensive audit logging tracks all significant actions
- Logs include:
  - Action type (CREATE, UPDATE, DELETE)
  - Target entity and ID
  - User who performed the action
  - Timestamp
  - Additional details in JSON format
- Audit logs are protected by RLS policies
- Users can only view their own audit logs

### Database Structure

#### Core Tables
- `companies`: Stores company information
- `profiles`: User profiles with company-specific settings
- `roles`: Defines available roles (system and company-specific)
- `user_roles`: Assigns roles to users
- `user_companies`: Manages user-company relationships
- `role_permissions`: Defines permissions for each role
- `audit_logs`: Tracks all significant actions

#### Security Policies
```sql
-- Example RLS policy for companies
CREATE POLICY "Users can read their companies"
  ON companies
  FOR SELECT
  TO authenticated
  USING (has_company_access(id));

-- Example RLS policy for audit logs
CREATE POLICY "Users can view their own audit logs"
  ON audit_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());
```

### Implementation Guidelines

1. **Data Access**
   - Always use the `has_company_access` function to check company access
   - Use `has_permission` for permission checks
   - Consider company context when performing operations

2. **User Management**
   - Assign users to companies through `user_companies`
   - Set appropriate roles for each user-company relationship
   - Use system roles for cross-company access

3. **Audit Logging**
   - Log all significant actions using the `audit_logs` table
   - Include relevant context in the details JSON
   - Ensure proper RLS policies are in place

4. **Security Considerations**
   - Always check company access before data operations
   - Use SECURITY DEFINER functions for complex checks
   - Implement proper RLS policies for all tables
   - Consider company context in all queries

### Example Workflow

1. **User Authentication**
   ```typescript
   // Check company access
   const hasAccess = await supabase.rpc('has_company_access', {
     company_id: targetCompanyId
   });
   ```

2. **Data Access**
   ```typescript
   // Fetch company-specific data
   const { data } = await supabase
     .from('some_table')
     .select('*')
     .eq('company_id', currentCompanyId);
   ```

3. **Audit Logging**
   ```typescript
   // Log an action
   await supabase.from('audit_logs').insert({
     action: 'CREATE',
     target_id: newItemId,
     target_type: 'item',
     user_id: currentUser.id,
     details: { /* relevant context */ }
   });
   ```

## Multi-Company Access for Users

There will be users who need to log in to multiple companies, and they may have different roles within those companies. For example, a subcontractor might work for two or three different NBN companies, all using our app. That same user, or that same email address, needs to be able to log in to multiple companies.

So, for those edge cases where users need to log in to multiple companies, we will advise them to use email sub-addressing, often referred to as plus addressing. They will use name+companyA@email.com to access Company A and a different name+companyB@email.com to access Company B. This keeps our system simple while still providing a solution for those who need to log in to more than one company.

## Content Management System

## Content Tags

The system includes a robust content tagging system that allows for organization and categorization of content across companies.

### Database Schema

#### Tables

1. `content_tags`
   - Primary table for storing tag definitions
   ```sql
   CREATE TABLE content_tags (
       id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
       created_at timestamptz DEFAULT now(),
       updated_at timestamptz DEFAULT now(),
       name text NOT NULL,
       description text,
       color text DEFAULT '#4F46E5',
       company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE
   );
   ```

2. `content_content_tags`
   - Junction table for many-to-many relationships between content and tags
   ```sql
   CREATE TABLE content_content_tags (
       content_id uuid NOT NULL REFERENCES content(id) ON DELETE CASCADE,
       tag_id uuid NOT NULL REFERENCES content_tags(id) ON DELETE CASCADE,
       created_at timestamptz DEFAULT now(),
       PRIMARY KEY (content_id, tag_id)
   );
   ```

### Security Model

The tagging system implements Row Level Security (RLS) with the following policies:

1. Content Tags Access:
   ```sql
   -- View access
   CREATE POLICY "Users can view content tags they have access to" 
   ON content_tags FOR SELECT
   USING (company_id IN (SELECT company_id FROM user_companies WHERE user_id = auth.uid()));

   -- Full management access
   CREATE POLICY "Users can manage content tags for their companies" 
   ON content_tags FOR ALL
   USING (company_id IN (SELECT company_id FROM user_companies WHERE user_id = auth.uid()))
   WITH CHECK (company_id IN (SELECT company_id FROM user_companies WHERE user_id = auth.uid()));
   ```

2. Tag Relationships Access:
   ```sql
   CREATE POLICY "Users can manage content tag relationships" 
   ON content_content_tags FOR ALL
   USING (tag_id IN (
       SELECT id FROM content_tags
       WHERE company_id IN (SELECT company_id FROM user_companies WHERE user_id = auth.uid())
   ));
   ```

### Features

1. **Company-Specific Tags**
   - Tags are scoped to specific companies
   - Automatic company association based on user context
   - Cross-company content tagging prevention

2. **Tag Management**
   - Create, update, and delete tags
   - Custom color assignment
   - Tag descriptions
   - Usage tracking (number of associated content items)

3. **Content Association**
   - Multiple tags per content item
   - Bulk tag assignment
   - Tag filtering and organization

### Frontend Components

1. **Tag Management Interface** (`/admin/Tags.vue`)
   - Grid view of all company tags
   - Create/Edit/Delete functionality
   - Tag usage statistics
   - Color customization

2. **Content Tagging Interface** (`ContentFormModal.vue`)
   - Tag selection during content creation/editing
   - Dynamic tag creation
   - Tag removal

### Automatic Updates

The system maintains data integrity through:

1. **Timestamp Management**
   ```sql
   CREATE OR REPLACE FUNCTION update_updated_at_column()
   RETURNS TRIGGER
   LANGUAGE plpgsql
   SECURITY DEFINER
   AS $$
   BEGIN
       NEW.updated_at = now();
       RETURN NEW;
   END;
   $$;
   ```

2. **Cascade Deletions**
   - Automatic cleanup of tag relationships when content or tags are deleted
   - Company deletion cascades to associated tags

### Data Validation

The system includes validation functions to ensure:
1. No orphaned tag relationships
2. Proper company associations
3. No duplicate tag assignments
4. Data integrity across tables

### Audit Logging

All major tag operations are logged in the `audit_logs` table, including:
- Tag creation/modification/deletion
- Bulk operations
- Data migrations
- Relationship changes

### Usage Example

```typescript
// Fetch tags for current company
const { data: tags } = await supabase
  .from('content_tags')
  .select(`
    *,
    content_count:content_content_tags_aggregate(count)
  `)
  .eq('company_id', currentCompanyId);

// Assign tags to content
const { error } = await supabase
  .from('content_content_tags')
  .insert([
    { content_id: contentId, tag_id: tagId }
  ]);
```

### Best Practices

1. **Tag Creation**
   - Use descriptive names
   - Assign meaningful colors
   - Include helpful descriptions
   - Avoid duplicate tags

2. **Tag Management**
   - Regularly review and clean up unused tags
   - Maintain consistent naming conventions
   - Document tag purposes
   - Monitor tag usage patterns

3. **Performance Considerations**
   - Use appropriate indexes
   - Implement efficient queries
   - Monitor query performance
   - Cache frequently used tags

### Migrations

The system includes several migrations for managing the tag structure:
1. Initial table creation
2. Policy setup
3. Trigger creation
4. Constraint management
5. Data validation

For detailed migration information, see the `.bolt/supabase/migrations` directory.

## Database Migrations

The project uses Supabase migrations for database schema management. The migration structure is organized as follows:

```
supabase/
├── migrations/        # Active migrations
├── functions/        # Database functions
├── config.toml      # Supabase configuration
└── schema.sql       # Current schema snapshot

archive/
└── migrations/
    ├── backup/      # Backup of previously applied migrations
    └── discarded/   # Historical/replaced migrations
```

### Migration Process

1. **Creating Migrations**
   - New migrations should be created in `supabase/migrations/`
   - Use timestamp prefix: `YYYYMMDDHHMMSS_descriptive_name.sql`
   - Include both up and rollback scripts

2. **Migration Guidelines**
   - Each migration should be atomic and focused
   - Include clear comments explaining the changes
   - Test migrations locally before deployment
   - Consider backwards compatibility

3. **Deployment Process**
   - Migrations are applied in timestamp order
   - Use `supabase db push` to apply migrations
   - Monitor migration logs for any issues
   - Backup database before applying migrations

4. **Rollback Procedure**
   - Each migration should have a corresponding rollback script
   - Test rollback scripts locally
   - Document any manual steps required

### Best Practices

1. **Migration Content**
   - One logical change per migration
   - Include appropriate indexes
   - Consider impact on existing data
   - Add appropriate comments

2. **Security**
   - Update RLS policies as needed
   - Review permission changes
   - Test security changes thoroughly

3. **Performance**
   - Consider impact on large datasets
   - Add appropriate indexes
   - Test with representative data volumes

4. **Documentation**
   - Document schema changes
   - Update API documentation
   - Note any breaking changes