import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';

export function ContentPage() {
  const [tab, setTab] = useState<'emergency' | 'specialties' | 'notifications'>('emergency');
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');

  const emergency = useQuery({
    queryKey: ['content-emergency', page, q],
    queryFn: () => api.emergencyServices({ page, limit: 20, q }),
    enabled: tab === 'emergency',
  });

  const specialties = useQuery({
    queryKey: ['content-specialties', page, q],
    queryFn: () => api.specialties({ page, limit: 20, q }),
    enabled: tab === 'specialties',
  });

  const notifications = useQuery({
    queryKey: ['content-notifications'],
    queryFn: () => api.settings('notifications'),
    enabled: tab === 'notifications',
  });

  const active = tab === 'emergency' ? emergency : tab === 'specialties' ? specialties : notifications;

  return (
    <div>
      <PageHeader title="Content Management" description="Emergency services, specialties, notifications, featured providers, banners" />
      <div className="mb-4 flex gap-2">
        {(['emergency', 'specialties', 'notifications'] as const).map((t) => (
          <button key={t} type="button" className={tab === t ? 'btn-primary' : 'btn-secondary'} onClick={() => { setTab(t); setPage(1); }}>
            {t.charAt(0).toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>
      {tab !== 'notifications' && <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} />}
      {active.isLoading && <LoadingState />}
      {active.error && <ErrorState message={(active.error as Error).message} />}

      {tab === 'emergency' && emergency.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Name</th><th>City</th><th>Phone</th><th>24h</th></tr></thead>
              <tbody>
                {(emergency.data.services as Record<string, unknown>[]).map((s) => (
                  <tr key={String(s.id)}><td>{String(s.name)}</td><td>{String(s.city)}</td><td>{String(s.phone)}</td><td>{s.is_24_hours ? 'Yes' : 'No'}</td></tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={emergency.data.pagination.page} totalPages={emergency.data.pagination.totalPages} onPage={setPage} />
        </>
      )}

      {tab === 'specialties' && specialties.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Name</th><th>Category</th><th>Slug</th></tr></thead>
              <tbody>
                {(specialties.data.specialties as Record<string, string>[]).map((s) => (
                  <tr key={s.id}><td>{s.name}</td><td>{s.category}</td><td>{s.slug}</td></tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={specialties.data.pagination.page} totalPages={specialties.data.pagination.totalPages} onPage={setPage} />
        </>
      )}

      {tab === 'notifications' && notifications.data && (
        <div className="card p-4">
          <pre className="overflow-auto text-xs">{JSON.stringify(notifications.data.settings, null, 2)}</pre>
          <p className="mt-2 text-sm text-slate-500">Edit notification templates and featured providers in System Settings.</p>
        </div>
      )}
    </div>
  );
}
