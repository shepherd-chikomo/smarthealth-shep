-- Promote Shepherd/Wazara test account to facility_admin at St Wilfred's for portal testing.
UPDATE public.facility_memberships fm
SET role = 'facility_admin'::public.app_role
FROM public.facilities f, public.profiles p
WHERE fm.facility_id = f.id
  AND fm.user_id = p.id
  AND f.name ILIKE '%St Wilfred%Medical%'
  AND lower(p.email) = 'shepherd@tambarara.co.zw';

UPDATE public.profiles
SET primary_role = 'facility_admin'::public.app_role
WHERE lower(email) = 'shepherd@tambarara.co.zw';

SELECT fm.role::text, f.name, p.email, p.first_name, p.last_name, p.primary_role::text
FROM public.facility_memberships fm
JOIN public.facilities f ON f.id = fm.facility_id
JOIN public.profiles p ON p.id = fm.user_id
WHERE lower(p.email) = 'shepherd@tambarara.co.zw';
