import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import type { EmergencyServiceInput, EmergencyServiceRecord } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';
import { EmergencyServiceModal } from '../components/content/EmergencyServiceModal';

export function ContentPage() {
  const qc = useQueryClient();
  const [tab, setTab] = useState<'emergency' | 'notifications'>('emergency');
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [editing, setEditing] = useState<EmergencyServiceRecord | null | undefined>(undefined);
  const [saveError, setSaveError] = useState('');

  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastBody, setBroadcastBody] = useState('');
  const [broadcastResult, setBroadcastResult] = useState<string | null>(null);

  const emergency = useQuery({
    queryKey: ['content-emergency', page, q],
    queryFn: () => api.emergencyServices({ page, limit: 20, q }),
    enabled: tab === 'emergency',
  });

  const broadcasts = useQuery({
    queryKey: ['platform-broadcasts', page],
    queryFn: () => api.listBroadcasts({ page, limit: 20 }),
    enabled: tab === 'notifications',
  });

  const saveEmergency = useMutation({
    mutationFn: (body: EmergencyServiceInput) =>
      editing?.id
        ? api.updateEmergencyService(editing.id, body)
        : api.createEmergencyService(body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['content-emergency'] });
      setEditing(undefined);
      setSaveError('');
    },
    onError: (err: Error) => setSaveError(err.message),
  });

  const deleteEmergency = useMutation({
    mutationFn: (id: string) => api.deleteEmergencyService(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['content-emergency'] }),
  });

  const sendBroadcast = useMutation({
    mutationFn: () =>
      api.broadcastNotification({
        title: broadcastTitle.trim(),
        body: broadcastBody.trim(),
        actionUrl: '/home',
      }),
    onSuccess: (data) => {
      setBroadcastResult(`Sent to ${data.recipientCount} user(s).`);
      setBroadcastTitle('');
      setBroadcastBody('');
      qc.invalidateQueries({ queryKey: ['platform-broadcasts'] });
    },
    onError: (err: Error) => setBroadcastResult(err.message),
  });

  return (
    <div>
      <PageHeader
        title="Content Management"
        description="Emergency services directory and platform notifications"
      />
      <div className="mb-4 flex gap-2">
        {(['emergency', 'notifications'] as const).map((t) => (
          <button
            key={t}
            type="button"
            className={tab === t ? 'btn-primary' : 'btn-secondary'}
            onClick={() => { setTab(t); setPage(1); }}
          >
            {t.charAt(0).toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>

      {tab === 'emergency' && (
        <>
          <div className="mb-4 flex flex-wrap items-center gap-3">
            <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search name, city, phone…" />
            <button type="button" className="btn-primary" onClick={() => { setEditing(null); setSaveError(''); }}>
              Add emergency service
            </button>
          </div>
          {emergency.isLoading && <LoadingState />}
          {emergency.error && <ErrorState message={(emergency.error as Error).message} />}
          {emergency.data && emergency.data.services.length === 0 && (
            <div className="card p-8 text-center">
              <p className="text-slate-500">No emergency services yet.</p>
              <p className="mt-1 text-sm text-slate-400">Add national hotlines and hospital ER contacts for the mobile app.</p>
              <button type="button" className="btn-primary mt-4" onClick={() => setEditing(null)}>Add first service</button>
            </div>
          )}
          {emergency.data && emergency.data.services.length > 0 && (
            <>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Type</th>
                      <th>City</th>
                      <th>Phone</th>
                      <th>24h</th>
                      <th>Active</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {emergency.data.services.map((s) => (
                      <tr key={s.id}>
                        <td className="font-medium">{s.name}</td>
                        <td className="text-xs capitalize">{s.serviceType.replace(/_/g, ' ')}</td>
                        <td>{s.city}</td>
                        <td>{s.phone}</td>
                        <td>{s.is24Hours ? 'Yes' : 'No'}</td>
                        <td>{s.isActive ? 'Yes' : 'No'}</td>
                        <td className="space-x-2 whitespace-nowrap">
                          <button type="button" className="text-sm text-teal-600" onClick={() => { setEditing(s); setSaveError(''); }}>Edit</button>
                          <button type="button" className="text-sm text-red-600" onClick={() => deleteEmergency.mutate(s.id)}>Delete</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <PaginationBar page={page} totalPages={emergency.data.pagination.totalPages} onPage={setPage} />
            </>
          )}
        </>
      )}

      {tab === 'notifications' && (
        <>
          <div className="card mb-6 space-y-3 p-5">
            <h2 className="font-semibold">Send platform notification</h2>
            <p className="text-sm text-slate-500">Pushes to all patient app users. Shows as a popup on the home dashboard until dismissed.</p>
            <input className="input w-full" placeholder="Title" value={broadcastTitle} onChange={(e) => setBroadcastTitle(e.target.value)} />
            <textarea className="input min-h-[5rem] w-full" placeholder="Message body" value={broadcastBody} onChange={(e) => setBroadcastBody(e.target.value)} />
            <button
              type="button"
              className="btn-primary"
              disabled={!broadcastTitle.trim() || !broadcastBody.trim() || sendBroadcast.isPending}
              onClick={() => { setBroadcastResult(null); sendBroadcast.mutate(); }}
            >
              {sendBroadcast.isPending ? 'Sending…' : 'Send to all app users'}
            </button>
            {broadcastResult && <p className="text-sm text-slate-600">{broadcastResult}</p>}
          </div>
          {broadcasts.isLoading && <LoadingState />}
          {broadcasts.data && (
            <div className="table-wrap">
              <table className="data-table">
                <thead>
                  <tr><th>Title</th><th>Sent</th><th>Recipients</th><th>By</th></tr>
                </thead>
                <tbody>
                  {broadcasts.data.broadcasts.map((b) => (
                    <tr key={b.id}>
                      <td>
                        <p className="font-medium">{b.title}</p>
                        <p className="text-xs text-slate-500">{b.body}</p>
                      </td>
                      <td className="text-sm">{new Date(b.createdAt).toLocaleString()}</td>
                      <td>{b.recipientCount}</td>
                      <td className="text-sm">{b.createdByEmail ?? '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <PaginationBar page={page} totalPages={broadcasts.data.pagination.totalPages} onPage={setPage} />
            </div>
          )}
        </>
      )}

      {editing !== undefined && (
        <EmergencyServiceModal
          service={editing}
          saving={saveEmergency.isPending}
          error={saveError}
          onClose={() => setEditing(undefined)}
          onSave={(body) => saveEmergency.mutate(body)}
        />
      )}
    </div>
  );
}
