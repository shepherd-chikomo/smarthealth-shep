-- Platform broadcast notifications + dashboard dismiss tracking

BEGIN;

CREATE TABLE public.platform_broadcasts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text NOT NULL,
  action_url text,
  created_by uuid REFERENCES public.profiles (id) ON DELETE SET NULL,
  recipient_count int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX platform_broadcasts_created_at_idx
  ON public.platform_broadcasts (created_at DESC);

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS dismissed_at timestamptz;

CREATE INDEX IF NOT EXISTS notifications_dashboard_banner_idx
  ON public.notifications (user_id, created_at DESC)
  WHERE dismissed_at IS NULL
    AND (payload->>'requiresDashboardDismiss')::boolean IS TRUE;

COMMIT;
