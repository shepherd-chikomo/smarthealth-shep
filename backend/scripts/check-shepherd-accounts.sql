SELECT p.id, p.first_name, p.last_name, p.email, p.primary_role::text
FROM public.profiles p
WHERE lower(p.email) LIKE '%shepherd%'
   OR lower(p.email) LIKE '%totalit%'
   OR lower(p.email) LIKE '%tambarara%';

SELECT pr.id, pr.name, pr.email, pr.is_claimed, pr.owner_id, pr.profile_id
FROM public.providers pr
WHERE lower(pr.email) LIKE '%totalit%'
   OR lower(pr.email) LIKE '%tambarara%'
   OR pr.name ILIKE '%wazara%'
   OR pr.name ILIKE '%shepherd%';

SELECT fm.role::text, f.name AS facility, p.email, p.first_name, p.last_name
FROM public.facility_memberships fm
JOIN public.facilities f ON f.id = fm.facility_id
JOIN public.profiles p ON p.id = fm.user_id
WHERE f.name ILIKE '%Wilfred%'
   OR lower(p.email) LIKE '%shepherd%'
   OR lower(p.email) LIKE '%totalit%';
