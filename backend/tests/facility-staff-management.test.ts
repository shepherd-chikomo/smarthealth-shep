import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockQuery = vi.fn();
const mockRequireFacilityAdmin = vi.fn();
const mockEnsureAuthUserEmail = vi.fn();
const mockAssertCanAddStaffByEmail = vi.fn();
const mockLogPermissionAudit = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  query: (...args: unknown[]) => mockQuery(...args),
  withTransaction: vi.fn(),
}));

vi.mock('../src/lib/facility-access.js', () => ({
  assertFacilityAccess: vi.fn(),
  requireFacilityAdmin: (...args: unknown[]) => mockRequireFacilityAdmin(...args),
  getFacilityOrThrow: vi.fn(),
  getUserFacilityMemberships: vi.fn(),
}));

vi.mock('../src/lib/supabase-auth.js', () => ({
  normalizeEmail: (email: string) => email.trim().toLowerCase(),
  normalizeZimbabwePhone: (phone: string) => phone.trim(),
  ensureAuthUserEmail: (...args: unknown[]) => mockEnsureAuthUserEmail(...args),
}));

vi.mock('../src/lib/audit-log.js', () => ({
  logAppointmentAudit: vi.fn(),
  logPermissionAudit: (...args: unknown[]) => mockLogPermissionAudit(...args),
}));

vi.mock('../src/services/practitioner-claim.service.js', () => ({
  assertCanAddStaffByEmail: (...args: unknown[]) => mockAssertCanAddStaffByEmail(...args),
}));

const { removeStaffMember, updateStaffMember } = await import(
  '../src/services/facility.service.js'
);

const admin = { id: 'admin-1', email: 'admin@test.com', role: 'facility_admin' } as const;

describe('staff membership management', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockRequireFacilityAdmin.mockResolvedValue(undefined);
    mockAssertCanAddStaffByEmail.mockResolvedValue(undefined);
    mockEnsureAuthUserEmail.mockResolvedValue(undefined);
    mockLogPermissionAudit.mockResolvedValue(undefined);
  });

  it('blocks removing yourself', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [{ user_id: 'admin-1', role: 'facility_admin' }],
    });

    await expect(removeStaffMember(admin, 'fac-1', 'mem-1')).rejects.toMatchObject({
      code: 'CONFLICT',
      message: expect.stringContaining('cannot remove yourself'),
    });
  });

  it('blocks removing the last facility administrator', async () => {
    mockQuery
      .mockResolvedValueOnce({
        rows: [{ user_id: 'user-2', role: 'facility_admin' }],
      })
      .mockResolvedValueOnce({ rows: [{ count: '1' }] });

    await expect(removeStaffMember(admin, 'fac-1', 'mem-1')).rejects.toMatchObject({
      code: 'CONFLICT',
      message: expect.stringContaining('last facility administrator'),
    });
  });

  it('updates staff member profile and role', async () => {
    mockQuery
      .mockResolvedValueOnce({
        rows: [{ user_id: 'user-2', role: 'receptionist' }],
      })
      .mockResolvedValueOnce({ rows: [{ email: 'staff@test.com' }] })
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });

    const result = await updateStaffMember(admin, 'fac-1', 'mem-1', {
      fullName: 'Jane Doe',
      email: 'jane@test.com',
      phone: '0771234567',
      role: 'doctor',
    });

    expect(result).toEqual({ id: 'mem-1', userId: 'user-2' });
    expect(mockAssertCanAddStaffByEmail).toHaveBeenCalledWith('jane@test.com');
    expect(mockEnsureAuthUserEmail).toHaveBeenCalledWith('user-2', 'jane@test.com');
  });
});
