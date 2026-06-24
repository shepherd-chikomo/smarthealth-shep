'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

export default function SlotsPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['slots', facilityId],
    queryFn: () => api.slots(facilityId!),
    enabled: !!facilityId,
  });

  const [settings, setSettings] = useState({
    slotDurationMinutes: 30,
    bufferMinutes: 5,
    maxAdvanceDays: 30,
  });
  const [initialized, setInitialized] = useState(false);

  if (data?.settings && !initialized) {
    setSettings({
      slotDurationMinutes: Number(data.settings.slotDurationMinutes ?? 30),
      bufferMinutes: Number(data.settings.bufferMinutes ?? 5),
      maxAdvanceDays: Number(data.settings.maxAdvanceDays ?? 30),
    });
    setInitialized(true);
  }

  const save = useMutation({
    mutationFn: () => api.updateSlots(facilityId!, settings),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['slots', facilityId] }),
  });

  return (
    <div>
      <PageHeader title="Appointment Slots" description="Configure booking slot duration and advance booking window" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {initialized && (
        <form className="card max-w-md space-y-4" onSubmit={(e) => { e.preventDefault(); save.mutate(); }}>
          <div>
            <label className="text-sm font-medium">Slot duration (minutes)</label>
            <input type="number" className="input mt-1" value={settings.slotDurationMinutes}
              onChange={(e) => setSettings({ ...settings, slotDurationMinutes: Number(e.target.value) })} />
          </div>
          <div>
            <label className="text-sm font-medium">Buffer between slots (minutes)</label>
            <input type="number" className="input mt-1" value={settings.bufferMinutes}
              onChange={(e) => setSettings({ ...settings, bufferMinutes: Number(e.target.value) })} />
          </div>
          <div>
            <label className="text-sm font-medium">Max advance booking (days)</label>
            <input type="number" className="input mt-1" value={settings.maxAdvanceDays}
              onChange={(e) => setSettings({ ...settings, maxAdvanceDays: Number(e.target.value) })} />
          </div>
          <button type="submit" className="btn-primary" disabled={save.isPending}>Save settings</button>
        </form>
      )}
    </div>
  );
}
