import { useMemo, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api, type AuditLogEntry } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

type CategoryFilter =
  | ''
  | 'login'
  | 'medical_access'
  | 'appointment'
  | 'billing'
  | 'permission'
  | 'admin'
  | 'security'
  | 'data_change';

const CATEGORIES: { value: CategoryFilter; label: string }[] = [
  { value: '', label: 'All actions' },
  { value: 'login', label: 'Logins' },
  { value: 'medical_access', label: 'Medical access' },
  { value: 'appointment', label: 'Appointments' },
  { value: 'billing', label: 'Billing' },
  { value: 'permission', label: 'Permissions' },
  { value: 'admin', label: 'Admin actions' },
  { value: 'security', label: 'Security' },
  { value: 'data_change', label: 'Data changes' },
];

function outcomeBadge(outcome: string) {
  if (outcome === 'allowed') return <span className="badge badge-green">{outcome}</span>;
  if (outcome === 'denied') return <span className="badge badge-red">{outcome}</span>;
  return <span className="badge badge-yellow">{outcome}</span>;
}

function truncateId(id: string | null) {
  if (!id) return '—';
  return id.length > 12 ? `${id.slice(0, 8)}…` : id;
}

function AuditDetailRow({ log }: { log: AuditLogEntry }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <tr className="cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800/50" onClick={() => setOpen(!open)}>
        <td className="whitespace-nowrap text-sm">{new Date(log.createdAt).toLocaleString()}</td>
        <td><span className="badge">{log.category}</span></td>
        <td className="font-mono text-xs">{log.actionType}</td>
        <td className="font-mono text-xs">{truncateId(log.userId)}</td>
        <td className="font-mono text-xs">{log.entityType ?? '—'}</td>
        <td className="font-mono text-xs">{truncateId(log.entityId)}</td>
        <td>{outcomeBadge(log.outcome)}</td>
        <td className="text-xs">{log.ipAddress ?? '—'}</td>
      </tr>
      {open && (
        <tr>
          <td colSpan={8} className="bg-gray-50 p-4 text-sm dark:bg-gray-900/50">
            <dl className="grid gap-2 sm:grid-cols-2">
              <div><dt className="font-medium text-gray-500">Source</dt><dd>{log.source}</dd></div>
              <div><dt className="font-medium text-gray-500">Facility</dt><dd className="font-mono text-xs">{log.facilityId ?? '—'}</dd></div>
              <div><dt className="font-medium text-gray-500">User agent</dt><dd className="break-all text-xs">{log.userAgent ?? '—'}</dd></div>
              <div className="sm:col-span-2">
                <dt className="font-medium text-gray-500">Details</dt>
                <dd><pre className="mt-1 overflow-auto rounded bg-gray-100 p-2 text-xs dark:bg-gray-800">{JSON.stringify(log.details, null, 2)}</pre></dd>
              </div>
            </dl>
          </td>
        </tr>
      )}
    </>
  );
}

export function SecurityPage() {
  const [page, setPage] = useState(1);
  const [category, setCategory] = useState<CategoryFilter>('');
  const [search, setSearch] = useState('');
  const [outcome, setOutcome] = useState('');
  const [exporting, setExporting] = useState(false);

  const queryParams = useMemo(
    () => ({
      page,
      limit: 25,
      q: search || undefined,
      category: category || undefined,
      outcome: outcome || undefined,
    }),
    [page, search, category, outcome],
  );

  const audit = useQuery({
    queryKey: ['audit-logs', queryParams],
    queryFn: () => api.auditLogs(queryParams),
  });

  const summary = useQuery({
    queryKey: ['audit-summary'],
    queryFn: () => api.auditSummary(),
  });

  const handleExport = async () => {
    setExporting(true);
    try {
      const csv = await api.exportAuditLogs(queryParams);
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `audit-export-${new Date().toISOString().slice(0, 10)}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } finally {
      setExporting(false);
    }
  };

  return (
    <div>
      <PageHeader
        title="Audit Log"
        description="Immutable compliance audit trail — logins, medical access, appointments, billing, permissions, and admin actions"
      />

      {summary.data && (
        <div className="mb-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {summary.data.last24Hours.map((item) => (
            <div key={item.category} className="rounded-lg border p-3 dark:border-gray-700">
              <p className="text-xs uppercase text-gray-500">{item.category.replace('_', ' ')}</p>
              <p className="text-2xl font-semibold">{item.total}</p>
              {item.denied > 0 && (
                <p className="text-xs text-red-600">{item.denied} denied</p>
              )}
            </div>
          ))}
        </div>
      )}

      <div className="mb-4 flex flex-wrap items-end gap-3">
        <label className="flex flex-col gap-1 text-sm">
          Category
          <select
            className="input"
            value={category}
            onChange={(e) => { setCategory(e.target.value as CategoryFilter); setPage(1); }}
          >
            {CATEGORIES.map((c) => (
              <option key={c.value || 'all'} value={c.value}>{c.label}</option>
            ))}
          </select>
        </label>
        <label className="flex flex-col gap-1 text-sm">
          Outcome
          <select
            className="input"
            value={outcome}
            onChange={(e) => { setOutcome(e.target.value); setPage(1); }}
          >
            <option value="">All</option>
            <option value="allowed">Allowed</option>
            <option value="denied">Denied</option>
            <option value="error">Error</option>
          </select>
        </label>
        <label className="flex min-w-[200px] flex-1 flex-col gap-1 text-sm">
          Search
          <input
            className="input"
            placeholder="Action, entity, user ID…"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          />
        </label>
        <button type="button" className="btn-secondary" disabled={exporting} onClick={handleExport}>
          {exporting ? 'Exporting…' : 'Export CSV'}
        </button>
      </div>

      {audit.isLoading && <LoadingState />}
      {audit.error && <ErrorState message={(audit.error as Error).message} />}

      {audit.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Category</th>
                  <th>Action</th>
                  <th>User</th>
                  <th>Entity</th>
                  <th>Entity ID</th>
                  <th>Outcome</th>
                  <th>IP</th>
                </tr>
              </thead>
              <tbody>
                {audit.data.logs.length === 0 ? (
                  <tr><td colSpan={8} className="py-8 text-center text-gray-500">No audit records found</td></tr>
                ) : (
                  audit.data.logs.map((log) => <AuditDetailRow key={log.id} log={log} />)
                )}
              </tbody>
            </table>
          </div>
          <PaginationBar
            page={audit.data.pagination.page}
            totalPages={audit.data.pagination.totalPages}
            onPage={setPage}
          />
        </>
      )}
    </div>
  );
}
