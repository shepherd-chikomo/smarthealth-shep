-- SmartHealth: supplemental seed for import pipeline reference data
-- Run after main seed.sql or included in db reset

begin;

-- Additional specialty aliases for MDPCZ/HPA registry variants
insert into public.specialty_aliases (alias, alias_normalized, specialty_id, source)
select v.alias, lower(trim(v.alias)), s.id, 'seed-import'
from (values
  ('General Practice', 'general-practice'),
  ('Family Physician', 'general-practice'),
  ('Medical Officer', 'general-practice'),
  ('MO', 'general-practice'),
  ('Paediatrics and Child Health', 'paediatrics'),
  ('Pediatrician', 'paediatrics'),
  ('Obstetrician', 'obgyn'),
  ('Gynaecologist', 'obgyn'),
  ('Gynecologist', 'obgyn'),
  ('Physician Specialist', 'internal-medicine'),
  ('Physician', 'internal-medicine'),
  ('Surgeon', 'general-surgery'),
  ('Plastic Surgery', 'general-surgery'),
  ('Neurology', 'internal-medicine'),
  ('Neurologist', 'internal-medicine'),
  ('Urology', 'general-surgery'),
  ('Urologist', 'general-surgery'),
  ('Anaesthesia', 'general-surgery'),
  ('Anesthesiology', 'general-surgery'),
  ('Pathology', 'radiology'),
  ('Pathologist', 'radiology'),
  ('Ophthalmology', 'optometry'),
  ('Ophthalmologist', 'optometry')
) as v(alias, slug)
join public.specialties s on s.slug = v.slug
on conflict (alias_normalized) do nothing;

commit;
