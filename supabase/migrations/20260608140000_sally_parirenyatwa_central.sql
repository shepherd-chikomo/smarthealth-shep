-- Broaden central hospital matching for emergency hub

BEGIN;

UPDATE public.facilities f
SET
  facility_category = 'Central Hospital',
  ownership_type = COALESCE(f.ownership_type, 'government'),
  latitude = COALESCE(f.latitude, -17.8262),
  longitude = COALESCE(f.longitude, 31.0495),
  geocode_quality = COALESCE(f.geocode_quality, 'manual'),
  settings = jsonb_set(
    COALESCE(f.settings, '{}'::jsonb),
    '{profile,emergency}',
    COALESCE(f.settings->'profile'->'emergency', '{}'::jsonb)
      || jsonb_build_object('department', true, 'is24Hour', true),
    true
  ),
  updated_at = now()
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND (
    f.name ILIKE '%Sally Mugabe%'
    OR f.name ILIKE '%Harare Central Hospital%'
    OR f.name ILIKE '%Parirenyatwa%Group%'
    OR f.slug ILIKE '%sally-mugabe%'
    OR f.slug ILIKE '%parirenyatwa%'
  );

COMMIT;
