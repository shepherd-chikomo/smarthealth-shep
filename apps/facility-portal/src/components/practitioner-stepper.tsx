import clsx from 'clsx';
import { Check } from 'lucide-react';

const PRACTITIONER_STEPS = [
  { id: 'account', label: 'Account' },
  { id: 'facilities', label: 'Your facilities' },
  { id: 'complete', label: 'Portal' },
] as const;

export type PractitionerStepId = (typeof PRACTITIONER_STEPS)[number]['id'];

interface PractitionerStepperProps {
  current: PractitionerStepId;
}

export function PractitionerStepper({ current }: PractitionerStepperProps) {
  const currentIdx = PRACTITIONER_STEPS.findIndex((s) => s.id === current);

  return (
    <ol className="flex flex-wrap gap-2">
      {PRACTITIONER_STEPS.map((step, idx) => {
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

export { PRACTITIONER_STEPS };
