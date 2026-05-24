import clsx from 'clsx';
import { Check } from 'lucide-react';

const STEPS = [
  { id: 'account', label: 'Account' },
  { id: 'verify', label: 'Verify' },
  { id: 'upload', label: 'Documents' },
  { id: 'select', label: 'Select listing' },
  { id: 'submit', label: 'Submit' },
  { id: 'pending', label: 'Review' },
  { id: 'approved', label: 'Approved' },
] as const;

export type ClaimStepId = (typeof STEPS)[number]['id'];

interface ClaimStepperProps {
  current: ClaimStepId;
}

export function ClaimStepper({ current }: ClaimStepperProps) {
  const currentIdx = STEPS.findIndex((s) => s.id === current);

  return (
    <ol className="flex flex-wrap gap-2">
      {STEPS.map((step, idx) => {
        const done = idx < currentIdx;
        const active = idx === currentIdx;
        return (
          <li
            key={step.id}
            className={clsx(
              'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium',
              done && 'bg-teal-100 text-teal-800 dark:bg-teal-950 dark:text-teal-300',
              active && 'bg-teal-600 text-white',
              !done && !active && 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
            )}
          >
            {done ? <Check className="h-3 w-3" /> : null}
            {step.label}
          </li>
        );
      })}
    </ol>
  );
}

export { STEPS };
