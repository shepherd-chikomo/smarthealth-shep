import { z } from 'zod';

export const adminListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z.string().optional(),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
  facilityId: z.string().uuid().optional(),
  status: z.string().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
});

export type AdminListQuery = z.infer<typeof adminListQuerySchema>;

export function adminOffset(page: number, limit: number): number {
  return (page - 1) * limit;
}

export function buildSearchClause(
  fields: string[],
  q: string | undefined,
  params: unknown[],
  startIdx: number,
): { clause: string; nextIdx: number } {
  if (!q?.trim()) return { clause: 'TRUE', nextIdx: startIdx };
  const pattern = `%${q.trim()}%`;
  const parts = fields.map((f) => `${f} ILIKE $${startIdx}`);
  params.push(pattern);
  return { clause: `(${parts.join(' OR ')})`, nextIdx: startIdx + 1 };
}
