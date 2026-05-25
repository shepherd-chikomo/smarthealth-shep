-- Idempotent seed: Zimbabwe emergency services directory

BEGIN;

INSERT INTO public.emergency_services (
  name, service_type, phone, address, city, province, latitude, longitude, is_24_hours, is_active
)
SELECT v.name, v.service_type, v.phone, v.address, v.city, v.province, v.latitude, v.longitude, true, true
FROM (VALUES
  ('National Ambulance', 'ambulance'::public.emergency_service_type, '994', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('National Police', 'police'::public.emergency_service_type, '995', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Fire & Rescue', 'fire'::public.emergency_service_type, '993', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Emergency Rescue', 'disaster_response'::public.emergency_service_type, '112', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Emergency Services Zimbabwe (Ambulance)', 'ambulance'::public.emergency_service_type, '+263242703999', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Zimbabwe Republic Police', 'police'::public.emergency_service_type, '+263242703623', 'National', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Fire & Ambulance Bulawayo', 'fire'::public.emergency_service_type, '+2632927171', 'Fife Street', 'Bulawayo', 'Bulawayo'::public.zimbabwe_province, -20.1556, 28.5847),
  ('Connect Mental Health Helpline', 'mental_health_crisis'::public.emergency_service_type, '+263242393999', 'Harare', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Parirenyatwa Hospital ER', 'hospital_er'::public.emergency_service_type, '+263242703831', 'Mazoe Street', 'Harare', 'Harare'::public.zimbabwe_province, -17.8252, 31.0335),
  ('Avenues Clinic Emergency', 'hospital_er'::public.emergency_service_type, '+263242870111', 'Avondale', 'Harare', 'Harare'::public.zimbabwe_province, -17.8194, 31.0522),
  ('Wilkins Hospital', 'hospital_er'::public.emergency_service_type, '+263242706077', 'Harare South', 'Harare', 'Harare'::public.zimbabwe_province, -17.8420, 31.0180),
  ('Borrowdale Trauma Centre', 'hospital_er'::public.emergency_service_type, '+263242862000', 'Borrowdale', 'Harare', 'Harare'::public.zimbabwe_province, -17.8100, 31.0900)
) AS v(name, service_type, phone, address, city, province, latitude, longitude)
WHERE NOT EXISTS (
  SELECT 1 FROM public.emergency_services es
  WHERE es.name = v.name AND es.deleted_at IS NULL
);

COMMIT;
