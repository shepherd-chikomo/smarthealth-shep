import type { AuthenticatedUser } from './auth.js';
import { ForbiddenError } from './errors.js';

export const AdminRoles = {
  superAdmin: 'super_admin',
  facilityAdmin: 'facility_admin',
  doctor: 'doctor',
  receptionist: 'receptionist',
} as const;

export type AdminRole = (typeof AdminRoles)[keyof typeof AdminRoles];

const STAFF_ROLES = new Set<string>([
  AdminRoles.superAdmin,
  AdminRoles.facilityAdmin,
  AdminRoles.doctor,
  AdminRoles.receptionist,
]);

const ADMIN_ROLES = new Set<string>([
  AdminRoles.superAdmin,
  AdminRoles.facilityAdmin,
]);

export function isStaffRole(role: string): boolean {
  return STAFF_ROLES.has(role);
}

export function isAdminRole(role: string): boolean {
  return ADMIN_ROLES.has(role);
}

export function isSuperAdmin(user: AuthenticatedUser): boolean {
  return user.role === AdminRoles.superAdmin;
}

export function requireStaff(user: AuthenticatedUser): void {
  if (!isStaffRole(user.role)) {
    throw new ForbiddenError('Staff access required');
  }
}

export function requireAdmin(user: AuthenticatedUser): void {
  if (!isAdminRole(user.role)) {
    throw new ForbiddenError('Admin access required');
  }
}

export function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) {
    throw new ForbiddenError('Super admin access required');
  }
}
