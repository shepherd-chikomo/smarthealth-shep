import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader } from '../components/ui';

const SCOPES = ['platform', 'feature_flags', 'pricing', 'notifications', 'banners'] as const;

export function SettingsPage() {
  const qc = useQueryClient();
  const [scope, setScope] = useState<string>('platform');
  const [key, setKey] = useState('');
  const [value, setValue] = useState('{}');

  const { data, isLoading, error } = useQuery({
    queryKey: ['settings', scope],
    queryFn: () => api.settings(scope),
  });

  const save = useMutation({
    mutationFn: () => api.saveSetting({ scope, key, value: JSON.parse(value) }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['settings', scope] }),
  });

  return (
    <div>
      <PageHeader title="System Settings" description="Feature flags, app config, pricing plans, notification templates" />
      <div className="mb-4 flex flex-wrap gap-2">
        {SCOPES.map((s) => (
          <button key={s} type="button" className={scope === s ? 'btn-primary' : 'btn-secondary'} onClick={() => setScope(s)}>
            {s.replace('_', ' ')}
          </button>
        ))}
      </div>
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="card p-4">
            <h2 className="mb-3 font-medium">Current settings</h2>
            <pre className="max-h-96 overflow-auto text-xs">{JSON.stringify(data.settings, null, 2)}</pre>
          </div>
          <div className="card p-4">
            <h2 className="mb-3 font-medium">Upsert setting</h2>
            <input className="input mb-2" placeholder="key" value={key} onChange={(e) => setKey(e.target.value)} />
            <textarea className="input mb-3 min-h-[120px] font-mono text-xs" value={value} onChange={(e) => setValue(e.target.value)} />
            <button type="button" className="btn-primary" onClick={() => save.mutate()} disabled={!key}>Save</button>
          </div>
        </div>
      )}
    </div>
  );
}
