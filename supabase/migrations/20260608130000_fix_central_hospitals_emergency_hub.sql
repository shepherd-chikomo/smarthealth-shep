-- Ensure canonical central/provincial hospitals appear on emergency hub

BEGIN;

UPDATE public.facilities f
SET
  facility_category = v.classification,
  ownership_type = COALESCE(f.ownership_type, v.ownership),
  latitude = COALESCE(f.latitude, v.lat),
  longitude = COALESCE(f.longitude, v.lon),
  geocode_quality = COALESCE(f.geocode_quality, 'manual'),
  settings = jsonb_set(
    COALESCE(f.settings, '{}'::jsonb),
    '{profile,emergency}',
    COALESCE(f.settings->'profile'->'emergency', '{}'::jsonb)
      || jsonb_build_object('department', true, 'is24Hour', true),
    true
  ),
  updated_at = now()
FROM (VALUES
  ('%Parirenyatwa Group%', 'Central Hospital', 'government', -17.7878::float8, 31.0444::float8),
  ('%Parirenyatwa%Hospital%', 'Central Hospital', 'government', -17.7878::float8, 31.0444::float8),
  ('%Sally Mugabe%', 'Central Hospital', 'government', -17.8262::float8, 31.0495::float8),
  ('%Harare Central Hospital%', 'Central Hospital', 'government', -17.8262::float8, 31.0495::float8),
  ('%Wilkins%', 'Central Hospital', 'government', -17.8420::float8, 31.0180::float8),
  ('%Chitungwiza Central%', 'Central Hospital', 'government', -18.0127::float8, 31.0729::float8),
  ('%United Bulawayo%', 'Central Hospital', 'government', -20.1556::float8, 28.5847::float8),
  ('%Mpilo Central%', 'Central Hospital', 'government', -20.1556::float8, 28.5847::float8)
) AS v(name_pattern, classification, ownership, lat, lon)
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND f.name ILIKE v.name_pattern;

COMMIT;
