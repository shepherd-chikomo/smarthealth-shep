# Promote local UAT test user to staff and link a facility (run after first OTP login creates the profile).

$ErrorActionPreference = "Stop"



$phone = "+263771234567"

$email = "dev-admin@smarthealth.co.zw"

Write-Host "Promoting $email / $phone for facility portal + admin access..."



$psql = @"

INSERT INTO public.facilities (name, slug, facility_type, address_line1, city, province, phone, is_verified, is_active)

VALUES ('Avenues Clinic', 'avenues-clinic', 'clinic', 'Corner Baines & Mazowe Street', 'Harare', 'Harare', '+263242704000', true, true)

ON CONFLICT (slug) DO NOTHING;



UPDATE public.profiles

SET primary_role = 'super_admin',

    email = COALESCE(email, '$email'),

    first_name = COALESCE(first_name, 'Dev'),

    last_name = COALESCE(last_name, 'Admin')

WHERE phone = '$phone';



UPDATE auth.users

SET email = '$email',

    email_confirmed_at = COALESCE(email_confirmed_at, now())

WHERE id = (SELECT id FROM public.profiles WHERE phone = '$phone' LIMIT 1);



INSERT INTO public.facility_memberships (facility_id, user_id, role, is_primary)

SELECT f.id, p.id, 'facility_admin', true

FROM public.profiles p

CROSS JOIN public.facilities f

WHERE p.phone = '$phone'

  AND f.slug = 'avenues-clinic'

ON CONFLICT (facility_id, user_id) DO UPDATE SET role = 'facility_admin';



SELECT p.id, p.email, p.phone, p.primary_role, p.first_name, p.last_name, f.name AS facility

FROM public.profiles p

LEFT JOIN public.facility_memberships fm ON fm.user_id = p.id

LEFT JOIN public.facilities f ON f.id = fm.facility_id

WHERE p.phone = '$phone';

"@



if (docker ps --format "{{.Names}}" 2>$null | Select-String -Quiet "^smarthealth-db$") {

  docker exec smarthealth-db psql -U postgres -d postgres -c $psql

} else {

  Write-Host "Docker DB not running - trying Supabase CLI (port 54322)..."

  $env:PGPASSWORD = "postgres"

  psql -h 127.0.0.1 -p 54322 -U postgres -d postgres -c $psql

}



Write-Host "Clearing OTP lockout for dev (if any)..."

$lockoutSql = @"

ALTER TABLE private.login_attempts DISABLE TRIGGER prevent_mutation;

DELETE FROM private.login_attempts WHERE identifier IN ('$phone', 'email:$email', 'sms:$phone');

ALTER TABLE private.login_attempts ENABLE TRIGGER prevent_mutation;

"@

if (docker ps --format "{{.Names}}" 2>$null | Select-String -Quiet "^smarthealth-db$") {

  docker exec smarthealth-db psql -U postgres -d postgres -c $lockoutSql | Out-Null

}



Write-Host ""

Write-Host "Sign in again so your JWT picks up the new role."

Write-Host ""

Write-Host "Facility portal: http://localhost:3001/login"

Write-Host "  Email: $email (OTP via Inbucket/Gmail SMTP)"

Write-Host "  Phone fallback: 0771234567  OTP: 123456"

Write-Host ""

Write-Host "Admin dashboard: http://localhost:5173/admin/login"

Write-Host "  Same email / phone fallback"

