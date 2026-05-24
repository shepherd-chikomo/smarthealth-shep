import { z } from 'zod';

export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export type PaginationQuery = z.infer<typeof paginationQuerySchema>;

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export function buildPaginationMeta(
  page: number,
  limit: number,
  total: number,
): PaginationMeta {
  const totalPages = Math.max(1, Math.ceil(total / limit));
  return {
    page,
    limit,
    total,
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1,
  };
}

export function paginationOffset(page: number, limit: number): number {
  return (page - 1) * limit;
}

export function parseSort(
  sortBy: string | undefined,
  allowed: Record<string, string>,
  defaultColumn: string,
): { column: string; order: 'ASC' | 'DESC' } {
  const order = 'DESC';
  if (!sortBy) {
    return { column: allowed[defaultColumn] ?? defaultColumn, order };
  }

  const descending = sortBy.startsWith('-');
  const key = descending ? sortBy.slice(1) : sortBy;
  const column = allowed[key];
  if (!column) {
    return { column: allowed[defaultColumn] ?? defaultColumn, order };
  }
  return { column, order: descending ? 'DESC' : 'ASC' };
}
