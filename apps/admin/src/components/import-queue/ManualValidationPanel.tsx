import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';

interface Ticket {
  id: string;
  registrationNumber: string;
  specialty: string | null;
  submitterName: string | null;
  submitterEmail: string | null;
  status: string;
}

interface Props {
  ticket: Ticket;
  onDone: () => void;
}

export function ManualValidationPanel({ ticket, onDone }: Props) {
  const qc = useQueryClient();
  const [claimantId, setClaimantId] = useState('');
  const [notes, setNotes] = useState('');
  const [error, setError] = useState('');

  const approve = useMutation({
    mutationFn: () => api.approveManualValidation(ticket.id, { claimantId, mdpczNotes: notes || undefined }),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['manual-validation'] });
      onDone();
    },
    onError: (err: Error) => setError(err.message),
  });

  const reject = useMutation({
    mutationFn: () => api.rejectManualValidation(ticket.id, { mdpczNotes: notes || undefined }),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['manual-validation'] });
      onDone();
    },
    onError: (err: Error) => setError(err.message),
  });

  return (
    <div className="mt-3 space-y-3 border-t border-slate-200 pt-3 dark:border-slate-700">
      <p className="text-sm">
        <strong>{ticket.registrationNumber}</strong>
        {ticket.specialty ? ` · ${ticket.specialty}` : ''}
      </p>
      <p className="text-xs text-slate-500">
        {ticket.submitterName ?? 'Unknown'} · {ticket.submitterEmail ?? 'No email'}
      </p>

      <input
        className="input w-full"
        placeholder="Claimant user ID (UUID) for approved claim"
        value={claimantId}
        onChange={(e) => setClaimantId(e.target.value)}
      />
      <textarea
        className="input w-full min-h-[4rem]"
        placeholder="MDPCZ / admin notes"
        value={notes}
        onChange={(e) => setNotes(e.target.value)}
      />

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          className="btn-primary"
          disabled={!claimantId.trim() || approve.isPending}
          onClick={() => { setError(''); approve.mutate(); }}
        >
          Approve
        </button>
        <button
          type="button"
          className="btn-secondary"
          disabled={reject.isPending}
          onClick={() => { setError(''); reject.mutate(); }}
        >
          Reject
        </button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
