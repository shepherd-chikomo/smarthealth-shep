-- Map alias facilities to canonical classifications (keep existing names).
-- Seed missing canonical hospitals with geocoded addresses and pending_review status.

BEGIN;

-- 1) Alias mappings — classify existing facilities without renaming
UPDATE public.facilities f
SET facility_category = 'District Hospital',
    updated_at = now()
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND f.name ILIKE 'Rusape General Hospital';

UPDATE public.facilities f
SET facility_category = 'Rural Hospital',
    updated_at = now()
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND f.name ILIKE 'Murambinda Mission Hospital';

UPDATE public.facilities f
SET facility_category = 'District Hospital',
    updated_at = now()
WHERE f.deleted_at IS NULL
  AND f.is_active = true
  AND f.name ILIKE 'Karanda Mission Hospital';

-- 2) Seed missing canonical hospitals (pending verification)
INSERT INTO public.facilities (
  name,
  slug,
  facility_type,
  address_line1,
  city,
  province,
  latitude,
  longitude,
  formatted_address,
  geocode_quality,
  geocoded_at,
  facility_category,
  ownership_type,
  is_verified,
  verification_status,
  import_source,
  registry_key,
  settings
)
SELECT
  v.name,
  v.slug,
  'hospital'::public.facility_type,
  v.address_line1,
  v.city,
  v.province::public.zimbabwe_province,
  v.latitude,
  v.longitude,
  v.formatted_address,
  'manual',
  timezone('utc', now()),
  v.classification,
  v.ownership_type,
  false,
  'pending_review'::public.verification_status,
  'canonical_hospital_seed',
  v.registry_key,
  jsonb_build_object(
    'profile', jsonb_build_object(
      'emergency', jsonb_build_object('department', true, 'is24Hour', true)
    )
  )
FROM (
  VALUES
    (
      'Lupane Provincial Hospital',
      'lupane-provincial-hospital',
      'Lupane Provincial Hospital Site, Lupane',
      'Lupane Provincial Hospital Site, Lupane, Matabeleland North',
      'Lupane',
      'Matabeleland North',
      -18.8981::float8,
      27.8072::float8,
      'Provincial Hospital',
      'government',
      'canonical:hospital:lupane-provincial-hospital'
    ),
    (
      'Gwanda Provincial Hospital',
      'gwanda-provincial-hospital',
      '3 King Street, Gwanda',
      '3 King Street, Gwanda, Matabeleland South',
      'Gwanda',
      'Matabeleland South',
      -20.95786::float8,
      29.00006::float8,
      'Provincial Hospital',
      'government',
      'canonical:hospital:gwanda-provincial-hospital'
    ),
    (
      'Karoi District Hospital',
      'karoi-district-hospital',
      'Karoi Hospital, Karoi',
      'Karoi Hospital, Karoi, Mashonaland West',
      'Karoi',
      'Mashonaland West',
      -16.8153::float8,
      29.6878::float8,
      'District Hospital',
      'government',
      'canonical:hospital:karoi-district-hospital'
    ),
    (
      'Murewa District Hospital',
      'murewa-district-hospital',
      'Murewa',
      'Murewa District Hospital, Murewa, Mashonaland East',
      'Murewa',
      'Mashonaland East',
      -17.6435::float8,
      31.7839::float8,
      'District Hospital',
      'government',
      'canonical:hospital:murewa-district-hospital'
    ),
    (
      'Hwange Colliery Hospital',
      'hwange-colliery-hospital',
      'Hwange Colliery Hospital, Hwange',
      'Hwange Colliery Hospital, Hwange, Matabeleland North',
      'Hwange',
      'Matabeleland North',
      -18.3582::float8,
      26.5022::float8,
      'District Hospital',
      'government',
      'canonical:hospital:hwange-colliery-hospital'
    ),
    (
      'Nyanga District Hospital',
      'nyanga-district-hospital',
      'Nyanga Town',
      'Nyanga District Hospital, Nyanga Town, Manicaland',
      'Nyanga',
      'Manicaland',
      -18.2210::float8,
      32.7422::float8,
      'Rural Hospital',
      'government',
      'canonical:hospital:nyanga-district-hospital'
    ),
    (
      'Tsholotsho District Hospital',
      'tsholotsho-district-hospital',
      'Tsholotsho',
      'Tsholotsho District Hospital, Tsholotsho, Matabeleland North',
      'Tsholotsho',
      'Matabeleland North',
      -19.7728::float8,
      27.7553::float8,
      'Rural Hospital',
      'government',
      'canonical:hospital:tsholotsho-district-hospital'
    ),
    (
      'Binga District Hospital',
      'binga-district-hospital',
      'Binga',
      'Binga District Hospital, Binga, Matabeleland North',
      'Binga',
      'Matabeleland North',
      -17.6394::float8,
      27.3267::float8,
      'Rural Hospital',
      'government',
      'canonical:hospital:binga-district-hospital'
    )
) AS v(
  name,
  slug,
  address_line1,
  formatted_address,
  city,
  province,
  latitude,
  longitude,
  classification,
  ownership_type,
  registry_key
)
ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
DO UPDATE SET
  facility_category = EXCLUDED.facility_category,
  address_line1 = EXCLUDED.address_line1,
  city = EXCLUDED.city,
  province = EXCLUDED.province,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  formatted_address = EXCLUDED.formatted_address,
  geocode_quality = EXCLUDED.geocode_quality,
  geocoded_at = EXCLUDED.geocoded_at,
  verification_status = EXCLUDED.verification_status,
  is_verified = EXCLUDED.is_verified,
  settings = facilities.settings || EXCLUDED.settings,
  updated_at = timezone('utc', now());

COMMIT;
