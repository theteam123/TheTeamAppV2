# TheTeam App - Technical Documentation

## 1. Project Description

TheTeam App is a modern web application designed for team management and content organization. It provides a robust platform for companies to manage their teams, content, and access control in a secure and efficient manner. The application is built with a multi-tenant architecture to support multiple companies within a single database.

### Key Features
- User authentication and authorization
- Company management
- Role-based access control (RBAC)
- Content management
- Tag organization
- Menu section management
- Debug tools
- Multi-tenant architecture

### Tech Stack
- **Frontend**: Vue 3 with TypeScript
- **State Management**: Pinia
- **Routing**: Vue Router
- **Backend**: Supabase
- **Styling**: Tailwind CSS
- **Icons**: Lucide Icons

## 2. System Architecture

The application follows a modern client-server architecture:

### Frontend (Vue 3)
- **Components**: Reusable UI elements
- **Pages**: Main application views
- **Stores**: State management using Pinia
- **Composables**: Reusable Vue composition functions
- **Router**: Navigation and route guards
- **Layouts**: Page layout templates

### Backend (Supabase)
- **Authentication**: Built-in auth system
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Storage**: File storage capabilities
- **Real-time**: Subscription-based updates

### Interaction Flow
1. User requests are handled by Vue Router
2. Route guards check authentication and permissions
3. Pinia stores manage application state
4. Supabase client handles API calls
5. Database policies enforce security
6. Real-time subscriptions update UI

## 2.1 Multi-tenant Architecture

TheTeam App is designed as a multi-tenant application with a single multi-tenant database, providing efficient resource utilization and simplified maintenance.

### Multi-tenant Features
- Support for multiple companies (tenants) within a single application instance
- Each company operates independently with its own users, roles, and content
- Data is logically separated by company_id in the database
- Users can belong to multiple companies
- Roles and permissions can be company-specific

### Tenant Isolation
- **Data Separation**: Achieved through Row Level Security (RLS) policies
- **Access Control**: Company-specific access controls and user-company relationships
- **User Management**: Each user has a current_company_id in their profile
- **Permission System**: Role-based permissions per company
- **Security**: Data access controlled by `has_company_access(company_id)` function

### Benefits
- **Efficiency**: Optimal resource utilization
- **Maintenance**: Simplified updates and maintenance
- **Consistency**: Uniform user experience across tenants
- **Scalability**: Efficient data management
- **Cost-effectiveness**: Shared infrastructure

## 3. User Roles and Permissions

### Role Hierarchy
1. **App Admin**
   - System-wide access
   - Can manage all companies
   - Can create/delete system roles
   - Can assign any permissions

2. **Admin**
   - Company-specific access
   - Can manage company users
   - Can manage company roles
   - Can manage company content

3. **User**
   - Basic access
   - Can view assigned content
   - Can perform role-specific actions
   - Limited to their company

### Permission Implementation
- **Database Level**: Row Level Security (RLS) policies
- **Application Level**: Route guards and permission checks
- **Security Functions**:
  - `has_permission(permission_key)`
  - `has_role(role_name)`
  - `is_app_admin()`
  - `has_company_access(company_id)`

## 4. Database Schema

### Core Tables
1. **profiles**
   - User profile information
   - Links to auth.users
   - Current company reference

2. **companies**
   - Company information
   - Name and description
   - Creation metadata

3. **roles**
   - Role definitions
   - System role flag
   - Role metadata

4. **role_permissions**
   - Permission assignments
   - Role-permission mapping
   - Unique constraints

5. **user_roles**
   - User-role assignments
   - Cascade deletion
   - Unique constraints

6. **user_companies**
   - User-company assignments
   - Access control
   - Unique constraints

### Relationships
- Users can belong to multiple companies
- Users can have multiple roles
- Roles can have multiple permissions
- Companies can have multiple users

## 5. Environment Setup

### Local Development
1. **Prerequisites**
   - Node.js 16.x or later
   - npm 7.x or later
   - Supabase account

2. **Setup Steps**
   ```bash
   git clone <repository-url>
   cd theteamapp
   npm install
   ```

3. **Environment Configuration**
   Create `.env` file:
   ```env
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Development Server**
   ```bash
   npm run dev
   ```

### Production Deployment
1. **Build Process**
   ```bash
   npm run build
   ```

2. **Environment Switch**
   - Use `switch-env.sh` script
   - Handles environment-specific configurations
   - Updates necessary environment variables

⚠️ **Warning**: Be cautious when switching environments as it may affect data access and security settings.

## 6. File and Folder Structure

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
```

### Naming Conventions
- **Components**: PascalCase (e.g., `UserProfile.vue`)
- **Composables**: camelCase (e.g., `useAuth.ts`)
- **Stores**: camelCase (e.g., `userStore.ts`)
- **Types**: PascalCase (e.g., `UserProfile.ts`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `