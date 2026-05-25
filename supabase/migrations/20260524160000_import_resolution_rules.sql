-- Persistent admin resolutions for import review queues (replayed on re-import)

BEGIN;

CREATE TYPE public.import_resolution_type AS ENUM (
  'ambiguous_merged',
  'ambiguous_distinct',
  'practitioner_facility_link',
  'practitioner_no_link',
  'provider_email_override',
  'provider_manual_claim_allowed',
  'manual_validation_approved',
  'manual_validation_rejected'
);

CREATE TABLE public.import_resolution_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resolution_type public.import_resolution_type NOT NULL,
  stable_key text NOT NULL,
  facility_id uuid REFERENCES public.facilities (id) ON DELETE SET NULL,
  provider_id uuid REFERENCES public.providers (id) ON DELETE SET NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  source_queue_id uuid REFERENCES public.import_review_queue (id) ON DELETE SET NULL,
  created_by uuid REFERENCES public.profiles (id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT import_resolution_rules_type_key_unique UNIQUE (resolution_type, stable_key)
);

CREATE INDEX import_resolution_rules_stable_key_idx
  ON public.import_resolution_rules (stable_key);

CREATE INDEX import_resolution_rules_provider_idx
  ON public.import_resolution_rules (provider_id)
  WHERE provider_id IS NOT NULL;

COMMIT;
