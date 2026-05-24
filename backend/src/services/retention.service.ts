import { query } from '../lib/db.js';

export interface RetentionResult {
  tableSchema: string;
  tableName: string;
  deletedCount: number;
}

export async function applyRetentionPolicies(): Promise<RetentionResult[]> {
  const result = await query<{
    table_schema: string;
    table_name: string;
    deleted_count: string;
  }>(`SELECT * FROM audit.apply_retention_policies()`);

  return result.rows.map((row) => ({
    tableSchema: row.table_schema,
    tableName: row.table_name,
    deletedCount: Number(row.deleted_count),
  }));
}

export async function listRetentionPolicies() {
  const result = await query(
    `SELECT id, table_schema, table_name, retention_days, is_active, last_purged_at
     FROM audit.retention_policies
     ORDER BY table_schema, table_name`,
  );
  return result.rows;
}
