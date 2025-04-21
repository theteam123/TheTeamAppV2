// Permission keys for different resources
export const PermissionKeys = {
  // User permissions
  users: {
    view: 'users.view',
    create: 'users.create',
    edit: 'users.edit',
    delete: 'users.delete'
  },
  // Company permissions
  companies: {
    view: 'companies.view',
    create: 'companies.create',
    edit: 'companies.edit',
    delete: 'companies.delete'
  },
  // Role permissions
  roles: {
    view: 'roles.view',
    create: 'roles.create',
    edit: 'roles.edit',
    delete: 'roles.delete'
  },
  // Content permissions
  content: {
    view: 'content.view',
    create: 'content.create',
    edit: 'content.edit',
    delete: 'content.delete'
  },
  // Form permissions
  forms: {
    view: 'forms.view',
    create: 'forms.create',
    edit: 'forms.edit',
    delete: 'forms.delete',
    submit: 'forms.submit'
  },
  // Document permissions
  documents: {
    view: 'documents.view',
    create: 'documents.create',
    edit: 'documents.edit',
    delete: 'documents.delete'
  },
  settings: {
    view: 'settings.view',
    edit: 'settings.edit'
  }
} as const;

// Type for permission keys
export type PermissionKey = typeof PermissionKeys[keyof typeof PermissionKeys][keyof typeof PermissionKeys[keyof typeof PermissionKeys]];

// Helper function to check if a user has a specific permission
export async function checkPermission(permissionKey: PermissionKey): Promise<boolean> {
  const { hasPermission } = await import('./role-functions');
  return hasPermission(permissionKey);
}

// Helper function to check if a user has all specified permissions
export async function checkAllPermissions(permissionKeys: PermissionKey[]): Promise<boolean> {
  const { hasAllPermissions } = await import('./role-functions');
  return hasAllPermissions(permissionKeys);
}

// Helper function to check if a user has any of the specified permissions
export async function checkAnyPermission(permissionKeys: PermissionKey[]): Promise<boolean> {
  const { hasAnyPermission } = await import('./role-functions');
  return hasAnyPermission(permissionKeys);
}

// Helper function to check if a user has a specific role
export async function checkRole(roleName: string): Promise<boolean> {
  const { hasRole } = await import('./role-functions');
  return hasRole(roleName);
}

// Helper function to check if a user has a specific system role
export async function checkSystemRole(roleName: string): Promise<boolean> {
  const { hasSystemRole } = await import('./role-functions');
  return hasSystemRole(roleName);
} 