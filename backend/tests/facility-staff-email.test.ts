import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockQuery = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  query: (...args: unknown[]) => mockQuery(...args),
}));

const { assertCanAddStaffByEmail } = await import(
  '../src/services/practitioner-claim.service.js'
);

describe('assertCanAddStaffByEmail', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('allows email that is not on an MDPCZ provider record', async () => {
    mockQuery.mockResolvedValueOnce({ rows: [] });
    await expect(assertCanAddStaffByEmail('new.staff@example.com')).resolves.toBeUndefined();
  });

  it('rejects email registered to a practitioner in MDPCZ', async () => {
    mockQuery
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'prov-1',
            name: 'Wazara Matthew',
            specialty: 'General Practice',
            registration_number: 'A12345',
            is_claimed: true,
            owner_id: 'user-wazara',
          },
        ],
      });

    await expect(assertCanAddStaffByEmail('shepherd@tambarara.co.zw')).rejects.toMatchObject({
      code: 'CONFLICT',
      message: expect.stringMatching(/Wazara Matthew.*registration number/s),
    });
  });

  it('rejects ambiguous MDPCZ email matches', async () => {
    mockQuery.mockResolvedValueOnce({
      rows: [
        {
          id: 'prov-1',
          name: 'Dr One',
          specialty: null,
          registration_number: 'A1',
          is_claimed: false,
          owner_id: null,
        },
        {
          id: 'prov-2',
          name: 'Dr Two',
          specialty: null,
          registration_number: 'A2',
          is_claimed: false,
          owner_id: null,
        },
      ],
    });

    await expect(assertCanAddStaffByEmail('shared@example.com')).rejects.toMatchObject({
      code: 'CONFLICT',
      message: expect.stringContaining('multiple practitioners'),
    });
  });
});
