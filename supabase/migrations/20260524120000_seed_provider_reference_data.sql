-- Seed reference data required by the healthcare provider import pipeline

begin;

insert into public.countries (code, name, phone_prefix, currency_code, is_active)
values ('ZW', 'Zimbabwe', '+263', 'USD', true)
on conflict (code) do nothing;

insert into public.provider_categories (id, name, icon_key, sort_order, is_active)
values
  ('general-practice', 'General Practice', 'stethoscope', 1, true),
  ('specialist', 'Specialist', 'user-md', 2, true)
on conflict (id) do nothing;

insert into public.specialties (name, slug, category, country_code, is_active)
values
  ('General Practice', 'general-practice', 'general-practice', 'ZW', true),
  ('Paediatrics', 'paediatrics', 'specialist', 'ZW', true),
  ('Obstetrics & Gynaecology', 'obgyn', 'specialist', 'ZW', true),
  ('Internal Medicine', 'internal-medicine', 'specialist', 'ZW', true),
  ('Psychiatry', 'psychiatry', 'specialist', 'ZW', true),
  ('Orthopaedics', 'orthopaedics', 'specialist', 'ZW', true),
  ('Dermatology', 'dermatology', 'specialist', 'ZW', true),
  ('Cardiology', 'cardiology', 'specialist', 'ZW', true),
  ('General Surgery', 'general-surgery', 'specialist', 'ZW', true),
  ('Dentistry', 'dentistry', 'specialist', 'ZW', true),
  ('Optometry', 'optometry', 'specialist', 'ZW', true),
  ('Radiology', 'radiology', 'specialist', 'ZW', true)
on conflict (slug) do nothing;

commit;
