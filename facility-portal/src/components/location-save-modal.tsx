'use client';

export function LocationSaveModal({
  open,
  saving,
  onKeepPin,
  onRegeocode,
  onCancel,
}: {
  open: boolean;
  saving?: boolean;
  onKeepPin: () => void;
  onRegeocode: () => void;
  onCancel: () => void;
}) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div
        className="w-full max-w-md rounded-xl border border-[var(--border)] bg-[var(--card)] p-6 shadow-xl"
        role="dialog"
        aria-labelledby="location-save-title"
      >
        <h2 id="location-save-title" className="text-lg font-semibold">
          Address and map pin both changed
        </h2>
        <p className="mt-2 text-sm text-[var(--muted)]">
          Choose whether to keep your map pin position or re-geocode from the new address.
        </p>
        <div className="mt-6 flex flex-col gap-2 sm:flex-row sm:justify-end">
          <button type="button" className="btn-secondary" disabled={saving} onClick={onCancel}>
            Cancel
          </button>
          <button type="button" className="btn-secondary" disabled={saving} onClick={onRegeocode}>
            Re-geocode from address
          </button>
          <button type="button" className="btn-primary" disabled={saving} onClick={onKeepPin}>
            Keep map pin
          </button>
        </div>
      </div>
    </div>
  );
}
