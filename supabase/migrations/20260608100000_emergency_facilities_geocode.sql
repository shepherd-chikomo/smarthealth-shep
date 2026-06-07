-- Geocode key emergency facilities and enable emergency profile flags

BEGIN;

-- St Wilfred's Medical Centre (Kambuzuma, Harare)
UPDATE public.facilities
SET
  latitude = -17.8365,
  longitude = 31.0034,
  geocode_quality = 'manual',
  settings = jsonb_set(
    COALESCE(settings, '{}'::jsonb),
    '{profile,emergency}',
    jsonb_build_object(
      'department', true,
      'ambulance', true,
      'trauma', true,
      'is24Hour', true
    ),
    true
  )
WHERE name ILIKE '%St Wilfred%Medical%'
  AND deleted_at IS NULL;

-- Major government hospitals (Harare) — coordinates from public maps
UPDATE public.facilities
SET
  latitude = COALESCE(latitude, -17.7878),
  longitude = COALESCE(longitude, 31.0444),
  geocode_quality = COALESCE(geocode_quality, 'manual')
WHERE name ILIKE '%Parirenyatwa%'
  AND deleted_at IS NULL
  AND latitude IS NULL;

UPDATE public.facilities
SET
  latitude = COALESCE(latitude, -17.8262),
  longitude = COALESCE(longitude, 31.0495),
  geocode_quality = COALESCE(geocode_quality, 'manual')
WHERE (name ILIKE '%Sally Mugabe%' OR name ILIKE '%Harare Central Hospital%')
  AND deleted_at IS NULL
  AND latitude IS NULL;

UPDATE public.facilities
SET
  latitude = COALESCE(latitude, -17.8420),
  longitude = COALESCE(longitude, 31.0180),
  geocode_quality = COALESCE(geocode_quality, 'manual')
WHERE name ILIKE '%Wilkins%'
  AND deleted_at IS NULL
  AND latitude IS NULL;

UPDATE public.facilities
SET
  latitude = COALESCE(latitude, -17.8194),
  longitude = COALESCE(longitude, 31.0522),
  geocode_quality = COALESCE(geocode_quality, 'manual')
WHERE name ILIKE '%Avenues%'
  AND deleted_at IS NULL
  AND latitude IS NULL;

-- Flag government hospitals with coordinates as emergency-capable when missing profile
UPDATE public.facilities f
SET settings = jsonb_set(
  COALESCE(f.settings, '{}'::jsonb),
  '{profile,emergency}',
  jsonb_build_object('department', true, 'is24Hour', true),
  true
)
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND f.latitude IS NOT NULL
  AND f.longitude IS NOT NULL
  AND (
    f.ownership_type ILIKE '%government%'
    OR f.ownership_type ILIKE '%public%'
    OR f.name ILIKE '%Parirenyatwa%'
    OR f.name ILIKE '%Sally Mugabe%'
    OR f.name ILIKE '%Wilkins%'
    OR f.name ILIKE '%Mpilo%'
    OR f.name ILIKE '%United Bulawayo%'
  )
  AND NOT COALESCE((f.settings->'profile'->'emergency'->>'department')::boolean, false);

-- City emergency numbers in directory (idempotent)
INSERT INTO public.emergency_services (
  name, service_type, phone, address, city, province, latitude, longitude, is_24_hours, is_active
)
SELECT v.name, v.service_type, v.phone, v.address, v.city, v.province, v.latitude, v.longitude, true, true
FROM (VALUES
  ('Harare Central Police', 'police'::public.emergency_service_type, '+263242777777', 'Harare CBD', 'Harare', 'Harare'::public.zimbabwe_province, -17.8290, 31.0520),
  ('Harare Fire Brigade', 'fire'::public.emergency_service_type, '+263242720206', 'Harare', 'Harare', 'Harare'::public.zimbabwe_province, -17.8315, 31.0455),
  ('Harare Ambulance Dispatch', 'ambulance'::public.emergency_service_type, '+263242703999', 'Harare', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Bulawayo Central Police', 'police'::public.emergency_service_type, '+26329271515', 'Bulawayo CBD', 'Bulawayo', 'Bulawayo'::public.zimbabwe_province, -20.1556, 28.5847),
  ('Bulawayo Fire & Ambulance', 'fire'::public.emergency_service_type, '+2632927171', 'Fife Street', 'Bulawayo', 'Bulawayo'::public.zimbabwe_province, -20.1556, 28.5847),
  ('General Emergency (999)', 'disaster_response'::public.emergency_service_type, '999', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335)
) AS v(name, service_type, phone, address, city, province, latitude, longitude)
WHERE NOT EXISTS (
  SELECT 1 FROM public.emergency_services es
  WHERE es.name = v.name AND es.deleted_at IS NULL
);

COMMIT;
