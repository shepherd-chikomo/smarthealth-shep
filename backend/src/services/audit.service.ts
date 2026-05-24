import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { isSuperAdmin } from '../lib/rbac.js';
import { adminOffset, type AdminListQuery } from '../lib/admin-query.js';

export interface AuditListQuery extends AdminListQuery {
  category?: string;
  actionType?: string;
  userId?: string;
  entityType?: string;
  outcome?: string;
}

interface ComplianceRow {
  log_key: string;
  id: string;
  source: string;
  actor_id: string | null;
  facility_id: string | null;
  category: string;
  action_type: string;
  entity_type: string | null;
  entity_id: string | null;
  outcome: string;
  ip_address: string | null;
  user_agent: string | null;
  details: Record<string, unknown>;
  created_at: Date;
}

function mapComplianceRow(row: ComplianceRow) {
  return {
    id: row.log_key,
    source: row.source,
    userId: row.actor_id,
    facilityId: row.facility_id,
    category: row.category,
    actionType: row.action_type,
    entityType: row.entity_type,
    entityId: row.entity_id,
    outcome: row.outcome,
    ipAddress: row.ip_address,
    userAgent: row.user_agent,
    details: row.details ?? {},
    createdAt: row.created_at.toISOString(),
  };
}

function buildAuditConditions(
  user: AuthenticatedUser,
  opts: AuditListQuery,
  params: unknown[],
): { conditions: string[]; nextIdx: number } {
  let idx = 1;
  const conditions = ['TRUE'];

  if (!isSuperAdmin(user)) {
    conditions.push(`(
      facility_id IN (
        SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx}
      )
      OR category IN ('login', 'security')
      OR actor_id = $${idx}
    )`);
    params.push(user.id);
    idx++;
  }

  if (opts.facilityId) {
    conditions.push(`facility_id = $${idx++}`);
    params.push(opts.facilityId);
  }
  if (opts.category) {
    conditions.push(`category = $${idx++}`);
    params.push(opts.category);
  }
  if (opts.actionType) {
    conditions.push(`action_type = $${idx++}`);
    params.push(opts.actionType);
  }
  if (opts.userId) {
    conditions.push(`actor_id = $${idx++}`);
    params.push(opts.userId);
  }
  if (opts.entityType) {
    conditions.push(`entity_type = $${idx++}`);
    params.push(opts.entityType);
  }
  if (opts.outcome) {
    conditions.push(`outcome = $${idx++}`);
    params.push(opts.outcome);
  }
  if (opts.from) {
    conditions.push(`created_at >= $${idx++}`);
    params.push(opts.from);
  }
  if (opts.to) {
    conditions.push(`created_at <= $${idx++}`);
    params.push(opts.to);
  }
  if (opts.q?.trim()) {
    conditions.push(`(
      action_type ILIKE $${idx}
      OR entity_type ILIKE $${idx}
      OR coalesce(entity_id::text, '') ILIKE $${idx}
      OR coalesce(actor_id::text, '') ILIKE $${idx}
      OR details::text ILIKE $${idx}
    )`);
    params.push(`%${opts.q.trim()}%`);
    idx++;
  }

  return { conditions, nextIdx: idx };
}

export async function listComplianceLogs(user: AuthenticatedUser, opts: AuditListQuery) {
  const params: unknown[] = [];
  const { conditions, nextIdx } = buildAuditConditions(user, opts, params);
  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM audit.compliance_export_view WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<ComplianceRow>(
    `SELECT log_key, id, source, actor_id, facility_id, category, action_type,
            entity_type, entity_id, outcome, ip_address::text, user_agent, details, created_at
     FROM audit.compliance_export_view
     WHERE ${where}
     ORDER BY created_at DESC
     LIMIT $${nextIdx} OFFSET $${nextIdx + 1}`,
    [...params, opts.limit, offset],
  );

  return {
    logs: result.rows.map(mapComplianceRow),
    pagination: buildPaginationMeta(opts.page, opts.limit, total),
  };
}

export async function exportComplianceLogs(user: AuthenticatedUser, opts: AuditListQuery): Promise<string> {
  const params: unknown[] = [];
  const { conditions } = buildAuditConditions(user, opts, params);
  const where = conditions.join(' AND ');

  const result = await query<ComplianceRow>(
    `SELECT log_key, id, source, actor_id, facility_id, category, action_type,
            entity_type, entity_id, outcome, ip_address::text, user_agent, details, created_at
     FROM audit.compliance_export_view
     WHERE ${where}
     ORDER BY created_at DESC
     LIMIT 10000`,
    params,
  );

  const header =
    'timestamp,source,category,action_type,user_id,facility_id,entity_type,entity_id,outcome,ip_address,user_agent,details\n';

  const escape = (v: string) => `"${v.replace(/"/g, '""')}"`;

  const lines = result.rows.map((row) =>
    [
      row.created_at.toISOString(),
      row.source,
      row.category,
      row.action_type,
      row.actor_id ?? '',
      row.facility_id ?? '',
      row.entity_type ?? '',
      row.entity_id ?? '',
      row.outcome,
      row.ip_address ?? '',
      escape(row.user_agent ?? ''),
      escape(JSON.stringify(row.details ?? {})),
    ].join(','),
  );

  return header + lines.join('\n');
}

export async function getAuditSummary(user: AuthenticatedUser, facilityId?: string) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = [`created_at >= timezone('utc', now()) - interval '24 hours'`];

  if (!isSuperAdmin(user)) {
    conditions.push(`(
      facility_id IN (SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx})
      OR actor_id = $${idx}
    )`);
    params.push(user.id);
    idx++;
  }
  if (facilityId) {
    conditions.push(`facility_id = $${idx++}`);
    params.push(facilityId);
  }

  const where = conditions.join(' AND ');
  const result = await query<{
    category: string;
    total: string;
    denied: string;
  }>(
    `SELECT category,
            COUNT(*)::text AS total,
            COUNT(*) FILTER (WHERE outcome = 'denied')::text AS denied
     FROM audit.compliance_export_view
     WHERE ${where}
     GROUP BY category
     ORDER BY category`,
    params,
  );

  return {
    last24Hours: result.rows.map((r) => ({
      category: r.category,
      total: Number(r.total),
      denied: Number(r.denied),
    })),
  };
}
