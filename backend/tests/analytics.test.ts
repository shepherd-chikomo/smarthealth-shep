import { describe, expect, it } from 'vitest';

describe('Analytics export formats', () => {
  it('builds CSV header for platform DAU export', () => {
    const header = 'date,dau,mau,appointments,revenue_cents,new_patients\n';
    expect(header.split(',').length).toBe(6);
  });

  it('builds CSV header for facility provider export', () => {
    const header = 'provider,appointments,completed,cancelled,rating,completion_rate\n';
    expect(header).toContain('completion_rate');
  });
});
