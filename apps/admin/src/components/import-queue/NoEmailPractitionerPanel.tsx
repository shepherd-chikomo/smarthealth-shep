import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import type { ImportReviewQueueItem } from '../../lib/api';

interface Props {
  item: ImportReviewQueueItem;
  onDone: () => void;
}

export function NoEmailPractitionerPanel({ item, onDone }: Props) {
  const qc = useQueryClient();
  const [email, setEmail] = useState('');
  const [notes, setNotes] = useState('');
  const [error, setError] = useState('');

  const resolve = useMutation({
    mutationFn: (body: { action: 'set_email' | 'manual_claim_only'; email?: string; notes?: string }) =>
      api.resolveNoEmailPractitioner(item.id, body),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['import-review-queue'] });
      onDone();
    },
    onError: (err: Error) => setError(err.message),
  });

  return (
    <div className="mt-3 space-y-3 border-t border-slate-200 pt-3 dark:border-slate-700">
      <p className="text-sm">
        <strong>{item.providerName ?? 'Unknown provider'}</strong>
        {item.registrationNumber ? ` · ${item.registrationNumber}` : ''}
      </p>
      <p className="text-xs text-slate-500">{item.notes}</p>

      <div className="space-y-2">
        <input
          className="input w-full"
          type="email"
          placeholder="Set registry email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <button
          type="button"
          className="btn-primary"
          disabled={!email.trim() || resolve.isPending}
          onClick={() => {
            setError('');
            resolve.mutate({ action: 'set_email', email: email.trim() });
          }}
        >
          Save email
        </button>
      </div>

      <div className="space-y-2 border-t border-slate-200 pt-3 dark:border-slate-700">
        <input
          className="input w-full"
          placeholder="Notes (optional)"
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
        />
        <button
          type="button"
          className="btn-secondary"
          disabled={resolve.isPending}
          onClick={() => {
            setError('');
            resolve.mutate({ action: 'manual_claim_only', notes: notes || undefined });
          }}
        >
          Allow manual claim only (no email)
        </button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
