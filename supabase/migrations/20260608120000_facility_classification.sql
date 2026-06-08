-- Facility classification enum values, ambulance subtypes, seed canonical hospitals, dedupe emergency_services

BEGIN;

-- Remove duplicate Harare Central Police from emergency_services (hardcoded in national-emergency.service.ts)
DELETE FROM public.emergency_services
WHERE name = 'Harare Central Police'
  AND service_type = 'police'::public.emergency_service_type;

-- Canonical hospital classifications (match by name patterns)
DO $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT * FROM (VALUES
      ('%Parirenyatwa%', 'Harare', 'Central Hospital', 'government'),
      ('%Sally Mugabe%', 'Harare', 'Central Hospital', 'government'),
      ('%United Bulawayo%', 'Bulawayo', 'Central Hospital', 'government'),
      ('%Mpilo Central%', 'Bulawayo', 'Central Hospital', 'government'),
      ('%Chitungwiza Central%', 'Chitungwiza', 'Central Hospital', 'government'),
      ('%Gweru Provincial%', 'Gweru', 'Provincial Hospital', 'government'),
      ('%Mutare Provincial%', 'Mutare', 'Provincial Hospital', 'government'),
      ('%Marondera Provincial%', 'Marondera', 'Provincial Hospital', 'government'),
      ('%Bindura Provincial%', 'Bindura', 'Provincial Hospital', 'government'),
      ('%Masvingo Provincial%', 'Masvingo', 'Provincial Hospital', 'government'),
      ('%Lupane Provincial%', 'Lupane', 'Provincial Hospital', 'government'),
      ('%Gwanda Provincial%', 'Gwanda', 'Provincial Hospital', 'government'),
      ('%Chinhoyi Provincial%', 'Chinhoyi', 'Provincial Hospital', 'government'),
      ('%Karoi District%', 'Karoi', 'District Hospital', 'government'),
      ('%Karanda District%', 'Mount Darwin', 'District Hospital', 'government'),
      ('%Murewa District%', 'Murewa', 'District Hospital', 'government'),
      ('%Rusape District%', 'Rusape', 'District Hospital', 'government'),
      ('%Chegutu District%', 'Chegutu', 'District Hospital', 'government'),
      ('%Kadoma General%', 'Kadoma', 'District Hospital', 'government'),
      ('%Hwange Colliery%', 'Hwange', 'District Hospital', 'government'),
      ('%Beitbridge District%', 'Beitbridge', 'District Hospital', 'government'),
      ('%Karanda Mission%', 'Mount Darwin', 'Mission Hospital', 'mission'),
      ('%Howard Mission%', 'Mazowe', 'Mission Hospital', 'mission'),
      ('%Mt Darwin Mission%', 'Mount Darwin', 'Mission Hospital', 'mission'),
      ('%St Albert%Mission%', 'Centenary', 'Mission Hospital', 'mission'),
      ('%Silveira Mission%', 'Bikita', 'Mission Hospital', 'mission'),
      ('%Morgenster Mission%', 'Masvingo', 'Mission Hospital', 'mission'),
      ('%St Luke%Mission%', 'Lupane', 'Mission Hospital', 'mission'),
      ('%Mater Dei Hospital%', 'Bulawayo', 'Mission Hospital', 'mission'),
      ('%Murambinda Hospital%', 'Murambinda', 'Rural Hospital', 'government'),
      ('%Nyanga District%', 'Nyanga', 'Rural Hospital', 'government'),
      ('%Tsholotsho District%', 'Tsholotsho', 'Rural Hospital', 'government'),
      ('%Binga District%', 'Binga', 'Rural Hospital', 'government')
    ) AS t(name_pattern, city, classification, ownership)
  LOOP
    UPDATE public.facilities f
    SET
      facility_category = rec.classification,
      ownership_type = COALESCE(f.ownership_type, rec.ownership),
      settings = jsonb_set(
        COALESCE(f.settings, '{}'::jsonb),
        '{profile,emergency}',
        COALESCE(f.settings->'profile'->'emergency', '{}'::jsonb)
          || jsonb_build_object('department', true),
        true
      ),
      updated_at = now()
    WHERE f.deleted_at IS NULL
      AND f.name ILIKE rec.name_pattern
      AND (rec.city IS NULL OR f.city ILIKE '%' || rec.city || '%');
  END LOOP;
END $$;

COMMIT;
