import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockQuery = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  query: (...args: unknown[]) => mockQuery(...args),
}));

const { resolveOtpSend } = await import('../src/lib/otp-policy.js');

describe('resolveOtpSend staff login', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('sends OTP to registry email for a claimed MDPCZ provider owner', async () => {
    mockQuery
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({
        rows: [
          {
            owner_id: 'owner-1',
            profile_id: 'owner-1',
            is_claimed: true,
          },
        ],
      })
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'owner-1',
            email: 'other@example.com',
            phone: null,
            primary_role: 'doctor',
          },
        ],
      });

    const result = await resolveOtpSend({
      context: 'staff',
      email: 'shepherd@totalit.org',
      channel: 'email',
    });

    expect(result).toMatchObject({
      channel: 'email',
      identifier: 'shepherd@totalit.org',
      createUser: false,
      authUserId: 'owner-1',
    });
  });
});
