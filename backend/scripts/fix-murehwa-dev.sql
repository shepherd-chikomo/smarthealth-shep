-- Murewa → Murehwa spelling and province corrections
UPDATE public.facilities
SET
  name = regexp_replace(name, 'Murewa', 'Murehwa', 'gi'),
  city = regexp_replace(city, 'Murewa', 'Murehwa', 'gi'),
  address_line1 = regexp_replace(address_line1, 'Murewa', 'Murehwa', 'gi'),
  updated_at = timezone('utc', now())
WHERE deleted_at IS NULL
  AND (
    city ILIKE '%Murewa%'
    OR address_line1 ILIKE '%Murewa%'
    OR name ILIKE '%Murewa%'
  );

UPDATE public.facilities
SET province = 'Mashonaland East'::public.zimbabwe_province,
    updated_at = timezone('utc', now())
WHERE deleted_at IS NULL
  AND (
    city ILIKE '%Murehwa%'
    OR address_line1 ILIKE '%Murehwa%'
    OR name ILIKE '%Murehwa%'
  )
  AND province = 'Harare'::public.zimbabwe_province;

UPDATE public.facilities
SET province = 'Manicaland'::public.zimbabwe_province,
    city = CASE WHEN city ILIKE '%Nyanga%' OR city = 'Harare' THEN 'Nyanga' ELSE city END,
    updated_at = timezone('utc', now())
WHERE deleted_at IS NULL
  AND name ILIKE '%Claremont Estate Clinic%';

-- Clear coords so geocode pass picks up corrected addresses
UPDATE public.facilities
SET latitude = NULL,
    longitude = NULL,
    updated_at = timezone('utc', now())
WHERE deleted_at IS NULL
  AND (
    city ILIKE '%Murehwa%'
    OR name ILIKE '%Claremont Estate Clinic%'
  )
  AND (latitude IS NULL OR longitude IS NULL OR geocode_quality IS DISTINCT FROM 'manual');
