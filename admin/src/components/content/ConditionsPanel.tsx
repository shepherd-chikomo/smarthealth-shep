import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import type { ConditionSubmissionRecord, ProfileConditionInput, ProfileConditionRecord } from '../../lib/api';
import { ErrorState, LoadingState, Modal, PaginationBar, SearchBar } from '../ui';

function ConditionModal({
  condition,
  saving,
  error,
  onClose,
  onSave,
}: {
  condition?: ProfileConditionRecord | null;
  saving: boolean;
  error: string;
  onClose: () => void;
  onSave: (body: ProfileConditionInput) => void;
}) {
  const [label, setLabel] = useState(condition?.label ?? '');
  const [isCommon, setIsCommon] = useState(condition?.isCommon ?? true);
  const [sortOrder, setSortOrder] = useState(String(condition?.sortOrder ?? 0));
  const [isActive, setIsActive] = useState(condition?.isActive ?? true);

  return (
    <Modal title={condition ? 'Edit condition' : 'Add condition'} onClose={onClose}>
      <div className="space-y-3">
        <input
          className="input w-full"
          placeholder="Condition label"
          value={label}
          onChange={(e) => setLabel(e.target.value)}
        />
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={isCommon} onChange={(e) => setIsCommon(e.target.checked)} />
          Show in common list (default on mobile)
        </label>
        <input
          className="input w-full"
          type="number"
          min={0}
          placeholder="Sort order"
          value={sortOrder}
          onChange={(e) => setSortOrder(e.target.value)}
        />
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} />
          Active
        </label>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex justify-end gap-2">
          <button type="button" className="btn-secondary" onClick={onClose}>Cancel</button>
          <button
            type="button"
            className="btn-primary"
            disabled={!label.trim() || saving}
            onClick={() =>
              onSave({
                label: label.trim(),
                isCommon,
                sortOrder: Number(sortOrder) || 0,
                isActive,
              })
            }
          >
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>
    </Modal>
  );
}

function ApproveModal({
  submission,
  saving,
  onClose,
  onApprove,
}: {
  submission: ConditionSubmissionRecord;
  saving: boolean;
  onClose: () => void;
  onApprove: (isCommon: boolean) => void;
}) {
  const [isCommon, setIsCommon] = useState(false);

  return (
    <Modal title="Approve condition submission" onClose={onClose}>
      <p className="mb-3 text-sm text-slate-600">
        Add <strong>{submission.proposedLabel}</strong> ({submission.proposedSlug}) to the global catalog?
      </p>
      <label className="mb-4 flex items-center gap-2 text-sm">
        <input type="checkbox" checked={isCommon} onChange={(e) => setIsCommon(e.target.checked)} />
        Add to common list (shown by default on mobile)
      </label>
      <div className="flex justify-end gap-2">
        <button type="button" className="btn-secondary" onClick={onClose}>Cancel</button>
        <button
          type="button"
          className="btn-primary"
          disabled={saving}
          onClick={() => onApprove(isCommon)}
        >
          {saving ? 'Approving…' : 'Approve'}
        </button>
      </div>
    </Modal>
  );
}

function ConditionTable({
  title,
  description,
  conditions,
  onEdit,
  onDelete,
  onToggleCommon,
}: {
  title: string;
  description: string;
  conditions: ProfileConditionRecord[];
  onEdit: (c: ProfileConditionRecord) => void;
  onDelete: (id: string) => void;
  onToggleCommon: (c: ProfileConditionRecord) => void;
}) {
  return (
    <div className="card mb-6 overflow-hidden">
      <div className="border-b border-slate-200 px-5 py-4 dark:border-slate-700">
        <h2 className="font-semibold">{title}</h2>
        <p className="text-sm text-slate-500">{description}</p>
      </div>
      {conditions.length === 0 ? (
        <p className="p-5 text-sm text-slate-500">No conditions in this group.</p>
      ) : (
        <div className="table-wrap">
          <table className="data-table">
            <thead>
              <tr>
                <th>Label</th>
                <th>Slug</th>
                <th>Order</th>
                <th>Active</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {conditions.map((c) => (
                <tr key={c.id}>
                  <td className="font-medium">{c.label}</td>
                  <td className="text-xs text-slate-500">{c.slug}</td>
                  <td>{c.sortOrder}</td>
                  <td>{c.isActive ? 'Yes' : 'No'}</td>
                  <td className="space-x-2 whitespace-nowrap">
                    <button type="button" className="text-sm text-teal-600" onClick={() => onEdit(c)}>Edit</button>
                    <button
                      type="button"
                      className="text-sm text-slate-600"
                      onClick={() => onToggleCommon(c)}
                    >
                      Move to {c.isCommon ? 'non-common' : 'common'}
                    </button>
                    <button type="button" className="text-sm text-red-600" onClick={() => onDelete(c.id)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export function ConditionsPanel() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [editing, setEditing] = useState<ProfileConditionRecord | null | undefined>(undefined);
  const [saveError, setSaveError] = useState('');
  const [approving, setApproving] = useState<ConditionSubmissionRecord | null>(null);

  const conditions = useQuery({
    queryKey: ['content-conditions', page, q],
    queryFn: () => api.profileConditions({ page, limit: 100, q }),
  });

  const submissions = useQuery({
    queryKey: ['content-condition-submissions', page],
    queryFn: () => api.conditionSubmissions({ page, limit: 20, status: 'pending' }),
  });

  const saveCondition = useMutation({
    mutationFn: (body: ProfileConditionInput) =>
      editing?.id
        ? api.updateProfileCondition(editing.id, body)
        : api.createProfileCondition(body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['content-conditions'] });
      setEditing(undefined);
      setSaveError('');
    },
    onError: (err: Error) => setSaveError(err.message),
  });

  const deleteCondition = useMutation({
    mutationFn: (id: string) => api.deleteProfileCondition(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['content-conditions'] }),
  });

  const toggleCommon = useMutation({
    mutationFn: (c: ProfileConditionRecord) =>
      api.updateProfileCondition(c.id, { isCommon: !c.isCommon }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['content-conditions'] }),
  });

  const approveSubmission = useMutation({
    mutationFn: ({ id, isCommon }: { id: string; isCommon: boolean }) =>
      api.approveConditionSubmission(id, { isCommon }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['content-condition-submissions'] });
      qc.invalidateQueries({ queryKey: ['content-conditions'] });
      setApproving(null);
    },
  });

  const rejectSubmission = useMutation({
    mutationFn: (id: string) => api.rejectConditionSubmission(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['content-condition-submissions'] }),
  });

  const all = conditions.data?.conditions ?? [];
  const common = all.filter((c) => c.isCommon);
  const nonCommon = all.filter((c) => !c.isCommon);

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search label or slug…" />
        <button
          type="button"
          className="btn-primary"
          onClick={() => { setEditing(null); setSaveError(''); }}
        >
          Add condition
        </button>
      </div>

      {conditions.isLoading && <LoadingState />}
      {conditions.error && <ErrorState message={(conditions.error as Error).message} />}

      {conditions.data && (
        <>
          <ConditionTable
            title="Common conditions"
            description="Shown by default in the mobile medical profile picker."
            conditions={common}
            onEdit={(c) => { setEditing(c); setSaveError(''); }}
            onDelete={(id) => deleteCondition.mutate(id)}
            onToggleCommon={(c) => toggleCommon.mutate(c)}
          />
          <ConditionTable
            title="Non-common conditions"
            description="Shown when the patient taps Show more on mobile."
            conditions={nonCommon}
            onEdit={(c) => { setEditing(c); setSaveError(''); }}
            onDelete={(id) => deleteCondition.mutate(id)}
            onToggleCommon={(c) => toggleCommon.mutate(c)}
          />
          <PaginationBar
            page={page}
            totalPages={conditions.data.pagination.totalPages}
            onPage={setPage}
          />
        </>
      )}

      <div className="card mt-8 overflow-hidden">
        <div className="border-b border-slate-200 px-5 py-4 dark:border-slate-700">
          <h2 className="font-semibold">Pending user submissions</h2>
          <p className="text-sm text-slate-500">
            Conditions typed by patients as Other. Approve to add them to the global catalog.
          </p>
        </div>
        {submissions.isLoading && <LoadingState />}
        {submissions.data && submissions.data.submissions.length === 0 && (
          <p className="p-5 text-sm text-slate-500">No pending submissions.</p>
        )}
        {submissions.data && submissions.data.submissions.length > 0 && (
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Proposed label</th>
                  <th>Slug</th>
                  <th>Submitted by</th>
                  <th>Date</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {submissions.data.submissions.map((s) => (
                  <tr key={s.id}>
                    <td className="font-medium">{s.proposedLabel}</td>
                    <td className="text-xs text-slate-500">{s.proposedSlug}</td>
                    <td className="text-sm">{s.userEmail ?? s.userId.slice(0, 8)}</td>
                    <td className="text-sm">{new Date(s.createdAt).toLocaleString()}</td>
                    <td className="space-x-2 whitespace-nowrap">
                      <button
                        type="button"
                        className="text-sm text-teal-600"
                        onClick={() => setApproving(s)}
                      >
                        Approve
                      </button>
                      <button
                        type="button"
                        className="text-sm text-red-600"
                        onClick={() => rejectSubmission.mutate(s.id)}
                      >
                        Reject
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <PaginationBar
              page={page}
              totalPages={submissions.data.pagination.totalPages}
              onPage={setPage}
            />
          </div>
        )}
      </div>

      {editing !== undefined && (
        <ConditionModal
          condition={editing}
          saving={saveCondition.isPending}
          error={saveError}
          onClose={() => setEditing(undefined)}
          onSave={(body) => saveCondition.mutate(body)}
        />
      )}

      {approving && (
        <ApproveModal
          submission={approving}
          saving={approveSubmission.isPending}
          onClose={() => setApproving(null)}
          onApprove={(isCommon) =>
            approveSubmission.mutate({ id: approving.id, isCommon })
          }
        />
      )}
    </>
  );
}
