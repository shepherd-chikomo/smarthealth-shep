-- Reset all facility classifications, then apply only the canonical 33-hospital list.

BEGIN;

UPDATE public.facilities
SET facility_category = NULL,
    updated_at = now()
WHERE facility_category IS NOT NULL;

DO $$
DECLARE
  rec RECORD;
  affected integer;
BEGIN
  FOR rec IN
    SELECT *
    FROM (
      VALUES
        ('Parirenyatwa Group of Hospitals', 'Parirenyatwa Group Of Hospitals', NULL::text, 'Central Hospital'),
        ('Sally Mugabe Central Hospital', 'Sally Mugabe Central Hospital', NULL, 'Central Hospital'),
        ('United Bulawayo Hospitals', 'United Bulawayo Hospital', NULL, 'Central Hospital'),
        ('Mpilo Central Hospital', 'Mpilo Central Hospital', '%Private%', 'Central Hospital'),
        ('Chitungwiza Central Hospital', 'Chitungwiza Central Hospital', NULL, 'Central Hospital'),
        ('Gweru Provincial Hospital', 'Gweru Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Mutare Provincial Hospital', 'Mutare Provincial Hospital', '%Laboratory%', 'Provincial Hospital'),
        ('Marondera Provincial Hospital', 'Marondera Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Bindura Provincial Hospital', 'Bindura Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Masvingo Provincial Hospital', 'Masvingo Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Lupane Provincial Hospital', 'Lupane Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Gwanda Provincial Hospital', 'Gwanda Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Chinhoyi Provincial Hospital', 'Chinhoyi Provincial Hospital', NULL, 'Provincial Hospital'),
        ('Karoi District Hospital', 'Karoi District Hospital', '%Laboratory%', 'District Hospital'),
        ('Karanda District Hospital', 'Karanda District Hospital', NULL, 'District Hospital'),
        ('Murewa District Hospital', 'Murewa District Hospital', NULL, 'District Hospital'),
        ('Rusape District Hospital', 'Rusape District Hospital', NULL, 'District Hospital'),
        ('Chegutu District Hospital', 'Chegutu District Hospital', NULL, 'District Hospital'),
        ('Kadoma General Hospital', 'Kadoma General Hospital', NULL, 'District Hospital'),
        ('Hwange Colliery Hospital', 'Hwange Colliery Hospital', NULL, 'District Hospital'),
        ('Beitbridge District Hospital', 'Beitbridge District Hospital', NULL, 'District Hospital'),
        ('Karanda Mission Hospital', 'Karanda Mission Hospital', NULL, 'Mission Hospital'),
        ('Howard Mission Hospital', 'Howard Mission Hospital', NULL, 'Mission Hospital'),
        ('Mt Darwin Mission Hospital', 'Mt Darwin Mission Hospital', NULL, 'Mission Hospital'),
        ('St Albert''s Mission Hospital', 'St Alberts Mission Hospital', NULL, 'Mission Hospital'),
        ('Silveira Mission Hospital', 'Silveira Mission Hospital', NULL, 'Mission Hospital'),
        ('Morgenster Mission Hospital', 'Morgenster Mission Hospital', NULL, 'Mission Hospital'),
        ('St Luke''s Mission Hospital', 'St Luke%Mission Hospital', NULL, 'Mission Hospital'),
        ('Mater Dei Hospital', 'Mater Dei Hospital', 'GM Diagnostics%', 'Mission Hospital'),
        ('Murambinda Hospital', 'Murambinda Hospital', '%Mission%', 'Rural Hospital'),
        ('Nyanga District Hospital', 'Nyanga District Hospital', NULL, 'Rural Hospital'),
        ('Tsholotsho District Hospital', 'Tsholotsho District Hospital', NULL, 'Rural Hospital'),
        ('Binga District Hospital', 'Binga District Hospital', NULL, 'Rural Hospital')
    ) AS t(display_name, name_match, exclude_match, classification)
  LOOP
    UPDATE public.facilities f
    SET facility_category = rec.classification,
        updated_at = now()
    WHERE f.deleted_at IS NULL
      AND f.is_active = true
      AND f.name ILIKE rec.name_match
      AND (
        rec.exclude_match IS NULL
        OR f.name NOT ILIKE rec.exclude_match
      );

    GET DIAGNOSTICS affected = ROW_COUNT;

    IF affected = 0 THEN
      RAISE NOTICE 'canonical_hospital_no_match: %', rec.display_name;
    END IF;
  END LOOP;
END $$;

COMMIT;
