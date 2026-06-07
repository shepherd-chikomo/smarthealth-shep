import { describe, expect, it, beforeAll, afterAll } from 'vitest';
import { pool } from '../src/lib/db.js';
import * as profileConditions from '../src/services/profile-conditions.service.js';

const hasDb = Boolean(process.env.DATABASE_URL);

describe.skipIf(!hasDb)('profile conditions service', () => {
  let testUserId: string | undefined;
  let reviewerId: string | undefined;
  let createdConditionId: string | undefined;
  let createdSubmissionId: string | undefined;
  let dbReady = false;

  beforeAll(async () => {
    try {
      const userRow = await pool.query(
        `SELECT id FROM public.profiles ORDER BY created_at ASC LIMIT 1`,
      );
      testUserId = userRow.rows[0]?.id;
      reviewerId = testUserId;
      dbReady = Boolean(testUserId);
    } catch {
      dbReady = false;
      return;
    }
    if (!testUserId) return;

    await pool.query(
      `DELETE FROM public.condition_submissions
       WHERE proposed_slug = 'sickle_cell_anemia_test'`,
    );
    await pool.query(
      `DELETE FROM public.profile_conditions
       WHERE slug IN ('sickle_cell_anemia_test', 'epilepsy_test')`,
    );
  });

  afterAll(async () => {
    if (!dbReady) return;
    if (createdSubmissionId) {
      await pool.query(`DELETE FROM public.condition_submissions WHERE id = $1`, [
        createdSubmissionId,
      ]);
    }
    if (createdConditionId) {
      await pool.query(
        `UPDATE public.profile_conditions SET deleted_at = timezone('utc', now()) WHERE id = $1`,
        [createdConditionId],
      );
    }
    await pool.query(
      `DELETE FROM public.profile_conditions WHERE slug IN ('sickle_cell_anemia_test', 'epilepsy_test')`,
    );
    await pool.query(
      `DELETE FROM public.condition_submissions WHERE proposed_slug = 'sickle_cell_anemia_test'`,
    );
  });

  it('lists seeded common conditions', async () => {
    if (!dbReady) return;
    const result = await profileConditions.listProfileConditions();
    expect(result.common.length).toBeGreaterThanOrEqual(8);
    expect(result.common.some((c) => c.id === 'diabetes')).toBe(true);
    expect(result.other).toBeInstanceOf(Array);
  });

  it('suggests matches for partial label input', async () => {
    if (!dbReady) return;
    const result = await profileConditions.suggestProfileConditions('diab', 5);
    expect(result.suggestions.some((s) => s.id.includes('diabetes'))).toBe(true);
  });

  it('skips submission when slug already exists in catalog', async () => {
    if (!dbReady || !testUserId) return;
    const result = await profileConditions.createConditionSubmission(testUserId, {
      label: 'Diabetes',
    });
    expect(result.skipped).toBe(true);
    expect(result.reason).toBe('already_in_catalog');
    expect(result.submission).toBeNull();
  });

  it('creates pending submission for unknown condition', async () => {
    if (!dbReady || !testUserId) return;
    const result = await profileConditions.createConditionSubmission(testUserId, {
      label: 'Sickle Cell Anemia Test',
    });
    expect(result.skipped).toBe(false);
    expect(result.submission?.status).toBe('pending');
    expect(result.submission?.proposedSlug).toBe('sickle_cell_anemia_test');
    createdSubmissionId = result.submission?.id;
  });

  it('approves submission and adds condition to catalog', async () => {
    if (!dbReady || !testUserId || !createdSubmissionId || !reviewerId) return;
    const result = await profileConditions.approveSubmission(
      createdSubmissionId,
      reviewerId,
      { isCommon: false },
    );
    expect(result.submission.status).toBe('approved');
    expect(result.condition.slug).toBe('sickle_cell_anemia_test');
    expect(result.condition.isCommon).toBe(false);
    createdConditionId = result.condition.id;

    const listed = await profileConditions.listProfileConditions();
    expect(listed.other.some((c) => c.id === 'sickle_cell_anemia_test')).toBe(true);
  });
});

describe('profile conditions slug helpers', () => {
  it('returns empty suggestions for blank query', async () => {
    const result = await profileConditions.suggestProfileConditions('   ');
    expect(result.suggestions).toEqual([]);
  });
});
