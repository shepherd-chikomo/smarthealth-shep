-- Admin-managed facility services and medical aid catalogs with facility submission queues

BEGIN;

CREATE TABLE public.facility_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  label text NOT NULL,
  icon_key text NOT NULL DEFAULT 'custom',
  is_preset boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT facility_services_slug_unique UNIQUE (slug)
);

CREATE INDEX facility_services_preset_idx
  ON public.facility_services (is_preset, sort_order)
  WHERE deleted_at IS NULL AND is_active = true;

CREATE TRIGGER facility_services_set_updated_at
  BEFORE UPDATE ON public.facility_services
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.service_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES public.facilities (id) ON DELETE CASCADE,
  submitted_by uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  proposed_label text NOT NULL,
  proposed_slug text NOT NULL,
  proposed_icon_key text NOT NULL DEFAULT 'custom',
  status public.condition_submission_status NOT NULL DEFAULT 'pending',
  reviewed_by uuid REFERENCES public.profiles (id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  resulting_service_id uuid REFERENCES public.facility_services (id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX service_submissions_status_idx
  ON public.service_submissions (status, created_at DESC);

CREATE UNIQUE INDEX service_submissions_facility_slug_pending_idx
  ON public.service_submissions (facility_id, proposed_slug)
  WHERE status = 'pending';

CREATE TRIGGER service_submissions_set_updated_at
  BEFORE UPDATE ON public.service_submissions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.medical_aid_schemes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scheme_key text NOT NULL,
  name text NOT NULL,
  logo_path text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT medical_aid_schemes_key_unique UNIQUE (scheme_key)
);

CREATE INDEX medical_aid_schemes_active_idx
  ON public.medical_aid_schemes (sort_order)
  WHERE deleted_at IS NULL AND is_active = true;

CREATE TRIGGER medical_aid_schemes_set_updated_at
  BEFORE UPDATE ON public.medical_aid_schemes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.medical_aid_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES public.facilities (id) ON DELETE CASCADE,
  submitted_by uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  proposed_name text NOT NULL,
  proposed_scheme_key text NOT NULL,
  status public.condition_submission_status NOT NULL DEFAULT 'pending',
  reviewed_by uuid REFERENCES public.profiles (id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  resulting_scheme_id uuid REFERENCES public.medical_aid_schemes (id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX medical_aid_submissions_status_idx
  ON public.medical_aid_submissions (status, created_at DESC);

CREATE UNIQUE INDEX medical_aid_submissions_facility_key_pending_idx
  ON public.medical_aid_submissions (facility_id, proposed_scheme_key)
  WHERE status = 'pending';

CREATE TRIGGER medical_aid_submissions_set_updated_at
  BEFORE UPDATE ON public.medical_aid_submissions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

INSERT INTO public.facility_services (slug, label, icon_key, is_preset, sort_order)
SELECT v.slug, v.label, v.icon_key, true, v.sort_order
FROM (VALUES
  ('gp', 'General Practice', 'gp', 1),
  ('emergency', 'Emergency', 'emergency', 2),
  ('maternity', 'Maternity', 'maternity', 3),
  ('paediatrics', 'Paediatrics', 'paediatrics', 4),
  ('gynaecology', 'Gynaecology', 'gynaecology', 5),
  ('laboratory', 'Laboratory', 'laboratory', 6),
  ('radiology', 'Radiology', 'radiology', 7),
  ('pharmacy', 'Pharmacy', 'pharmacy', 8),
  ('surgery', 'Surgery', 'surgery', 9),
  ('physiotherapy', 'Physiotherapy', 'physiotherapy', 10),
  ('dentistry', 'Dentistry', 'dentistry', 11)
) AS v(slug, label, icon_key, sort_order)
WHERE NOT EXISTS (
  SELECT 1 FROM public.facility_services fs WHERE fs.slug = v.slug AND fs.deleted_at IS NULL
);

INSERT INTO public.medical_aid_schemes (scheme_key, name, sort_order)
SELECT v.scheme_key, v.name, v.sort_order
FROM (VALUES
  ('cimas', 'Cimas', 1),
  ('psmas', 'PSMAS', 2),
  ('first_mutual', 'First Mutual', 3),
  ('cellmed', 'CellMed', 4),
  ('alliance_health', 'Alliance Health', 5)
) AS v(scheme_key, name, sort_order)
WHERE NOT EXISTS (
  SELECT 1 FROM public.medical_aid_schemes mas WHERE mas.scheme_key = v.scheme_key AND mas.deleted_at IS NULL
);

COMMIT;
