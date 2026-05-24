'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

export default function EmergencyPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['emergency', facilityId],
    queryFn: () => api.emergency(facilityId!),
    enabled: !!facilityId,
  });

  const [form, setForm] = useState({
    acceptsEmergency: false,
    emergencyPhone: '',
    notes: '',
    afterHoursContact: '',
  });
  const [initialized, setInitialized] = useState(false);

  if (data?.availability && !initialized) {
    const a = data.availability;
    setForm({
      acceptsEmergency: Boolean(a.acceptsEmergency),
      emergencyPhone: String(a.emergencyPhone ?? ''),
      notes: String(a.notes ?? ''),
      afterHoursContact: String(a.afterHoursContact ?? ''),
    });
    setInitialized(true);
  }

  const save = useMutation({
    mutationFn: () => api.updateEmergency(facilityId!, form),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['emergency', facilityId] }),
  });

  return (
    <div>
      <PageHeader title="Emergency Availability" description="Configure emergency and after-hours contact settings" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {initialized && (
        <form className="card max-w-lg space-y-4" onSubmit={(e) => { e.preventDefault(); save.mutate(); }}>
          <label className="flex items-center gap-2">
            <input type="checkbox" checked={form.acceptsEmergency}
              onChange={(e) => setForm({ ...form, acceptsEmergency: e.target.checked })} />
            Accepts emergency walk-ins
          </label>
          <div>
            <label className="text-sm font-medium">Emergency phone</label>
            <input className="input mt-1" value={form.emergencyPhone}
              onChange={(e) => setForm({ ...form, emergencyPhone: e.target.value })} />
          </div>
          <div>
            <label className="text-sm font-medium">After-hours contact</label>
            <input className="input mt-1" value={form.afterHoursContact}
              onChange={(e) => setForm({ ...form, afterHoursContact: e.target.value })} />
          </div>
          <div>
            <label className="text-sm font-medium">Notes</label>
            <textarea className="input mt-1 min-h-[80px]" value={form.notes}
              onChange={(e) => setForm({ ...form, notes: e.target.value })} />
          </div>
          <button type="submit" className="btn-primary" disabled={save.isPending}>Save</button>
        </form>
      )}
    </div>
  );
}
