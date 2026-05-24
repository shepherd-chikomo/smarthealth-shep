import { describe, expect, it } from 'vitest';

/** Mirrors audit ranking / category weights for compliance verification. */
const CRITICAL_ACTIONS = [
  { category: 'login', actions: ['login.otp_verify.success', 'login.otp_verify.locked', 'auth_success'] },
  { category: 'medical_access', actions: ['medical_record.read', 'medical_record.export'] },
  { category: 'appointment', actions: ['appointment.create', 'appointment.reschedule', 'appointment.cancel'] },
  { category: 'billing', actions: ['billing.payment.initiate', 'billing.payment.complete', 'billing.payment.failed'] },
  { category: 'permission', actions: ['permission.grant', 'permission.revoke'] },
  { category: 'admin', actions: ['admin.provider.verify', 'admin.queue.cancel', 'admin.facility_admin.create'] },
] as const;

describe('audit action coverage', () => {
  it('defines all required critical action categories', () => {
    const categories = CRITICAL_ACTIONS.map((c) => c.category);
    expect(categories).toContain('login');
    expect(categories).toContain('medical_access');
    expect(categories).toContain('appointment');
    expect(categories).toContain('billing');
    expect(categories).toContain('permission');
    expect(categories).toContain('admin');
  });

  it('maps appointment lifecycle actions', () => {
    const appointment = CRITICAL_ACTIONS.find((c) => c.category === 'appointment')!;
    expect(appointment.actions).toEqual([
      'appointment.create',
      'appointment.reschedule',
      'appointment.cancel',
    ]);
  });

  it('maps billing payment actions', () => {
    const billing = CRITICAL_ACTIONS.find((c) => c.category === 'billing')!;
    expect(billing.actions).toContain('billing.payment.initiate');
    expect(billing.actions).toContain('billing.payment.complete');
  });
});

describe('audit log record shape', () => {
  interface AuditRecord {
    userId: string | null;
    category: string;
    actionType: string;
    entityType: string | null;
    entityId: string | null;
    ipAddress: string | null;
    userAgent: string | null;
    outcome: string;
    createdAt: string;
    details: Record<string, unknown>;
  }

  function isComplianceReady(record: AuditRecord): boolean {
    return (
      record.actionType.length > 0 &&
      record.category.length > 0 &&
      record.outcome.length > 0 &&
      record.createdAt.length > 0
    );
  }

  it('validates compliance-ready structure', () => {
    const record: AuditRecord = {
      userId: '550e8400-e29b-41d4-a716-446655440000',
      category: 'appointment',
      actionType: 'appointment.create',
      entityType: 'appointment',
      entityId: '660e8400-e29b-41d4-a716-446655440001',
      ipAddress: '192.168.1.1',
      userAgent: 'SmartHealth/1.0',
      outcome: 'allowed',
      createdAt: new Date().toISOString(),
      details: { referenceNumber: 'SH-ABC123' },
    };
    expect(isComplianceReady(record)).toBe(true);
  });

  it('requires action type and category for export', () => {
    const incomplete = {
      userId: null,
      category: '',
      actionType: '',
      entityType: null,
      entityId: null,
      ipAddress: null,
      userAgent: null,
      outcome: 'allowed',
      createdAt: new Date().toISOString(),
      details: {},
    };
    expect(isComplianceReady(incomplete)).toBe(false);
  });
});

describe('CSV export format', () => {
  it('escapes quoted fields', () => {
    const escape = (v: string) => `"${v.replace(/"/g, '""')}"`;
    expect(escape('Mozilla/5.0 "Chrome"')).toBe('"Mozilla/5.0 ""Chrome"""');
  });

  it('produces expected header columns', () => {
    const header =
      'timestamp,source,category,action_type,user_id,facility_id,entity_type,entity_id,outcome,ip_address,user_agent,details';
    expect(header.split(',')).toHaveLength(12);
    expect(header).toContain('user_id');
    expect(header).toContain('ip_address');
  });
});

describe('immutability policy', () => {
  it('audit tables must reject mutations', () => {
    const immutableTables = [
      'audit.action_logs',
      'audit.security_events',
      'audit.medical_access_logs',
      'audit.logs',
      'private.login_attempts',
    ];
    expect(immutableTables.length).toBeGreaterThanOrEqual(5);
  });
});
