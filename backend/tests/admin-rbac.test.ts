import { ForbiddenError } from '../lib/errors.js';
import { isStaffRole, requireAdmin, requireStaff, requireSuperAdmin } from '../lib/rbac.js';

describe('RBAC', () => {
  it('identifies staff roles', () => {
    expect(isStaffRole('super_admin')).toBe(true);
    expect(isStaffRole('facility_admin')).toBe(true);
    expect(isStaffRole('patient')).toBe(false);
  });

  it('requires admin for admin routes', () => {
    expect(() => requireAdmin({ id: '1', role: 'patient' })).toThrow(ForbiddenError);
    expect(() => requireAdmin({ id: '1', role: 'facility_admin' })).not.toThrow();
  });

  it('requires super admin', () => {
    expect(() => requireSuperAdmin({ id: '1', role: 'facility_admin' })).toThrow(ForbiddenError);
    expect(() => requireSuperAdmin({ id: '1', role: 'super_admin' })).not.toThrow();
  });

  it('requires staff', () => {
    expect(() => requireStaff({ id: '1', role: 'patient' })).toThrow(ForbiddenError);
    expect(() => requireStaff({ id: '1', role: 'doctor' })).not.toThrow();
  });
});
