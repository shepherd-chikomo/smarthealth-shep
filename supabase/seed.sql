-- SmartHealth seed data — Zimbabwe healthcare reference data
-- Runs after migrations on `supabase db reset` or `supabase start` (first boot)

begin;

-- Countries
insert into public.countries (code, name, phone_prefix, currency_code) values
  ('ZW', 'Zimbabwe', '+263', 'USD'),
  ('ZA', 'South Africa', '+27', 'ZAR'),
  ('ZM', 'Zambia', '+260', 'ZMW'),
  ('BW', 'Botswana', '+267', 'BWP'),
  ('MZ', 'Mozambique', '+258', 'MZN')
on conflict (code) do nothing;

-- Zimbabwe cities (major urban centres)
insert into public.cities (country_code, name, province, latitude, longitude)
select v.country_code, v.name, v.province, v.latitude, v.longitude
from (values
  ('ZW', 'Harare', 'Harare', -17.8252, 31.0335),
  ('ZW', 'Bulawayo', 'Bulawayo', -20.1556, 28.5847),
  ('ZW', 'Mutare', 'Manicaland', -18.9707, 32.6709),
  ('ZW', 'Gweru', 'Midlands', -19.4500, 29.8167),
  ('ZW', 'Masvingo', 'Masvingo', -20.0667, 30.8333),
  ('ZW', 'Kwekwe', 'Midlands', -18.9286, 29.8149),
  ('ZW', 'Kadoma', 'Mashonaland West', -18.3333, 29.9167),
  ('ZW', 'Chitungwiza', 'Harare', -18.0125, 31.0750),
  ('ZW', 'Marondera', 'Mashonaland East', -18.1890, 31.5512),
  ('ZW', 'Victoria Falls', 'Matabeleland North', -17.9318, 25.8307),
  ('ZW', 'Hwange', 'Matabeleland North', -18.3644, 26.5000),
  ('ZW', 'Chinhoyi', 'Mashonaland West', -17.3667, 30.2000),
  ('ZW', 'Rusape', 'Manicaland', -18.5278, 32.1281),
  ('ZW', 'Norton', 'Mashonaland West', -17.8833, 30.7000),
  ('ZW', 'Beitbridge', 'Matabeleland South', -22.2167, 30.0000),
  ('ZW', 'Bindura', 'Mashonaland Central', -17.3019, 31.3306),
  ('ZW', 'Zvishavane', 'Midlands', -20.3269, 30.0665),
  ('ZW', 'Epworth', 'Harare', -17.8900, 31.1475)
) as v(country_code, name, province, latitude, longitude)
where not exists (
  select 1 from public.cities c
  where c.country_code = v.country_code and c.name = v.name and c.province is not distinct from v.province
);

-- Platform app settings
insert into public.app_settings (tenant_id, scope, key, value, description, is_public) values
  (null, 'platform', 'default_country', '"ZW"'::jsonb, 'Default country code', true),
  (null, 'platform', 'default_currency', '"USD"'::jsonb, 'Default billing currency', true),
  (null, 'platform', 'default_timezone', '"Africa/Harare"'::jsonb, 'Default timezone', true),
  (null, 'platform', 'phone_prefix', '"+263"'::jsonb, 'Zimbabwe phone prefix', true),
  (null, 'platform', 'supported_languages', '["en","sn","nd","fr","pt","sw"]'::jsonb, 'Supported UI languages', true),
  (null, 'platform', 'booking_lead_time_hours', '2'::jsonb, 'Minimum hours before appointment', false),
  (null, 'platform', 'max_queue_priority', '5'::jsonb, 'Maximum walk-in queue priority level', false)
on conflict (tenant_id, scope, key) do nothing;

-- Provider categories (aligned with Flutter app)
insert into public.provider_categories (id, name, icon_key, sort_order) values
  ('general-practice', 'General Practice', 'stethoscope', 1),
  ('specialist', 'Specialist', 'medical_services', 2),
  ('dentist', 'Dentist', 'dentistry', 3),
  ('pharmacy', 'Pharmacy', 'local_pharmacy', 4),
  ('laboratory', 'Laboratory', 'biotech', 5),
  ('hospital', 'Hospital', 'local_hospital', 6),
  ('maternity', 'Maternity', 'pregnant_woman', 7),
  ('mental-health', 'Mental Health', 'psychology', 8),
  ('physiotherapy', 'Physiotherapy', 'physical_therapy', 9),
  ('optometry', 'Optometry', 'visibility', 10)
on conflict (id) do nothing;

-- Specialties
insert into public.specialties (name, slug, category) values
  ('General Practice', 'general-practice', 'primary'),
  ('Internal Medicine', 'internal-medicine', 'specialist'),
  ('Paediatrics', 'paediatrics', 'specialist'),
  ('Obstetrics & Gynaecology', 'obgyn', 'specialist'),
  ('General Surgery', 'general-surgery', 'specialist'),
  ('Orthopaedics', 'orthopaedics', 'specialist'),
  ('Cardiology', 'cardiology', 'specialist'),
  ('Dermatology', 'dermatology', 'specialist'),
  ('Psychiatry', 'psychiatry', 'specialist'),
  ('Dentistry', 'dentistry', 'dental'),
  ('Optometry', 'optometry', 'vision'),
  ('Radiology', 'radiology', 'diagnostics')
on conflict (name) do nothing;

-- Sample facilities (Zimbabwe)
insert into public.facilities (
  name, slug, facility_type, address_line1, city, province,
  phone, latitude, longitude, is_verified, is_active
) values
  (
    'Parirenyatwa Group of Hospitals',
    'parirenyatwa-hospital',
    'hospital',
    'Mazoe Street',
    'Harare',
    'Harare',
    '+263242703831',
    -17.8214,
    31.0456,
    true,
    true
  ),
  (
    'Mpilo Central Hospital',
    'mpilo-hospital',
    'hospital',
    'Luveve Road',
    'Bulawayo',
    'Bulawayo',
    '+263292888000',
    -20.1556,
    28.5847,
    true,
    true
  ),
  (
    'Avenues Clinic',
    'avenues-clinic',
    'clinic',
    'Corner Baines & Mazowe Street',
    'Harare',
    'Harare',
    '+263242704000',
    -17.8245,
    31.0498,
    true,
    true
  ),
  (
    'Mutare General Hospital',
    'mutare-general',
    'hospital',
    'Hospital Road',
    'Mutare',
    'Manicaland',
    '+2632064444',
    -18.9707,
    32.6709,
    true,
    true
  ),
  (
    'Gweru Provincial Hospital',
    'gweru-provincial',
    'hospital',
    'Ascot Road',
    'Gweru',
    'Midlands',
    '+26354222000',
    -19.4500,
    29.8167,
    true,
    true
  )
on conflict (slug) do nothing;

-- Emergency facilities directory
insert into public.emergency_facilities (
  name, facility_type, phone, address, city, province,
  latitude, longitude, is_24_hours
)
select v.name, v.facility_type, v.phone, v.address, v.city, v.province,
       v.latitude, v.longitude, v.is_24_hours
from (values
  ('Parirenyatwa Casualty', 'hospital'::public.facility_type, '+263242703831', 'Mazoe Street', 'Harare', 'Harare'::public.zimbabwe_province, -17.8214, 31.0456, true),
  ('Mpilo Casualty', 'hospital'::public.facility_type, '+263292888000', 'Luveve Road', 'Bulawayo', 'Bulawayo'::public.zimbabwe_province, -20.1556, 28.5847, true),
  ('Harare Central Hospital ER', 'hospital'::public.facility_type, '+263242707000', 'Southerton', 'Harare', 'Harare'::public.zimbabwe_province, -17.8420, 31.0200, true),
  ('Mutare General ER', 'hospital'::public.facility_type, '+2632064444', 'Hospital Road', 'Mutare', 'Manicaland'::public.zimbabwe_province, -18.9707, 32.6709, true),
  ('Gweru Provincial ER', 'hospital'::public.facility_type, '+26354222000', 'Ascot Road', 'Gweru', 'Midlands'::public.zimbabwe_province, -19.4500, 29.8167, true),
  ('Masvingo General Hospital', 'hospital'::public.facility_type, '+263392622000', 'Rujeko', 'Masvingo', 'Masvingo'::public.zimbabwe_province, -20.0667, 30.8333, true),
  ('Victoria Falls Hospital', 'hospital'::public.facility_type, '+2632132844221', 'Livingstone Way', 'Victoria Falls', 'Matabeleland North'::public.zimbabwe_province, -17.9318, 25.8307, true)
) as v(name, facility_type, phone, address, city, province, latitude, longitude, is_24_hours)
where not exists (
  select 1 from public.emergency_facilities ef
  where ef.name = v.name and ef.city = v.city
);

-- Sample providers linked to facilities
insert into public.providers (
  facility_id, category_id, name, specialty, mdpcz_number,
  is_verified, is_accepting_bookings, services, conditions, age_groups
)
select
  f.id,
  'general-practice',
  'Dr. Tendai Moyo',
  'General Practice',
  'GP-12345',
  true,
  true,
  array['Consultation', 'Health screening', 'Chronic disease management'],
  array['Hypertension', 'Diabetes', 'Malaria'],
  array['Adult', 'Senior']
from public.facilities f
where f.slug = 'avenues-clinic'
  and not exists (
    select 1 from public.providers p
    where p.facility_id = f.id and p.name = 'Dr. Tendai Moyo'
  );

insert into public.providers (
  facility_id, category_id, name, specialty, mdpcz_number,
  is_verified, is_accepting_bookings
)
select
  f.id,
  'specialist',
  'Dr. Farai Ncube',
  'Paediatrics',
  'PD-67890',
  true,
  true
from public.facilities f
where f.slug = 'parirenyatwa-hospital'
  and not exists (
    select 1 from public.providers p
    where p.facility_id = f.id and p.name = 'Dr. Farai Ncube'
  );

-- Facility operating hours (Mon-Fri 08:00-17:00 for clinics)
insert into public.facility_operating_hours (
  facility_id, tenant_id, day_of_week, opens_at, closes_at, is_closed
)
select
  f.id,
  f.id,
  d.day_of_week,
  time '08:00',
  time '17:00',
  false
from public.facilities f
cross join generate_series(1, 5) as d(day_of_week)
where f.slug in ('avenues-clinic', 'parirenyatwa-hospital')
  and not exists (
    select 1 from public.facility_operating_hours h
    where h.facility_id = f.id and h.day_of_week = d.day_of_week
  );

-- Emergency services (ambulance + ER)
insert into public.emergency_services (
  name, service_type, facility_type, phone, address, city, province,
  latitude, longitude, is_24_hours
)
select v.name, v.service_type, v.facility_type, v.phone, v.address, v.city, v.province,
       v.latitude, v.longitude, v.is_24_hours
from (values
  ('Emergency Services Zimbabwe (Ambulance)', 'ambulance'::public.emergency_service_type, null::public.facility_type, '+263242703999', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335, true),
  ('Zimbabwe Republic Police', 'police'::public.emergency_service_type, null, '+263242703623', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335, true),
  ('Fire & Ambulance Bulawayo', 'fire'::public.emergency_service_type, null, '+2632927171', 'Fife Street', 'Bulawayo', 'Bulawayo'::public.zimbabwe_province, -20.1556, 28.5847, true),
  ('Connect Mental Health Helpline', 'mental_health_crisis'::public.emergency_service_type, null, '+263242393999', 'Harare', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335, true)
) as v(name, service_type, facility_type, phone, address, city, province, latitude, longitude, is_24_hours)
where not exists (
  select 1 from public.emergency_services es where es.name = v.name
);

-- Link facilities to cities
update public.facilities f
set city_id = c.id
from public.cities c
where c.country_code = 'ZW'
  and c.name = f.city
  and f.city_id is null;

commit;
