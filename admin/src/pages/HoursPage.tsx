import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader } from '../components/ui';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export function HoursPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['operating-hours'],
    queryFn: () => api.hours(),
  });

  return (
    <div>
      <PageHeader title="Operating Hours" description="Facility hours, doctor availability, holiday closures via app_settings" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <div className="table-wrap">
          <table className="data-table">
            <thead><tr><th>Provider</th><th>Day</th><th>Opens</th><th>Closes</th><th>Closed</th></tr></thead>
            <tbody>
              {(data.hours as Record<string, unknown>[]).map((h) => (
                <tr key={String(h.id)}>
                  <td>{String(h.provider_name)}</td>
                  <td>{DAYS[Number(h.day_of_week)] ?? h.day_of_week}</td>
                  <td>{String(h.opens_at ?? '—')}</td>
                  <td>{String(h.closes_at ?? '—')}</td>
                  <td>{h.is_closed ? 'Yes' : 'No'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <p className="mt-4 text-sm text-slate-500">Holiday closures and temporary overrides are managed under System Settings → closures / feature_flags.</p>
    </div>
  );
}
