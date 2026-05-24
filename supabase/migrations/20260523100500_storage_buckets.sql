-- SmartHealth: Storage buckets and object policies

begin;

-- ---------------------------------------------------------------------------
-- Buckets
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'provider-images',
    'provider-images',
    true,
    10485760, -- 10 MB
    array['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'medical-documents',
    'medical-documents',
    false,
    52428800, -- 50 MB
    array['application/pdf', 'image/jpeg', 'image/png', 'application/dicom']
  ),
  (
    'prescriptions',
    'prescriptions',
    false,
    20971520, -- 20 MB
    array['application/pdf', 'image/jpeg', 'image/png']
  ),
  (
    'facility-assets',
    'facility-assets',
    true,
    10485760,
    array['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']
  ),
  (
    'avatars',
    'avatars',
    true,
    5242880, -- 5 MB
    array['image/jpeg', 'image/png', 'image/webp']
  )
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ---------------------------------------------------------------------------
-- Storage path conventions:
--   provider-images/{facility_id}/{provider_id}/{filename}
--   medical-documents/{facility_id}/{patient_id}/{document_id}/{filename}
--   prescriptions/{facility_id}/{patient_id}/{prescription_id}/{filename}
--   facility-assets/{facility_id}/{asset_type}/{filename}
--   avatars/{user_id}/{filename}
-- ---------------------------------------------------------------------------

-- Provider images: public read, facility staff write
create policy "Public read provider images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'provider-images');

create policy "Facility staff upload provider images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'provider-images'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  );

create policy "Facility staff update provider images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'provider-images'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  );

create policy "Facility staff delete provider images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'provider-images'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  );

-- Medical documents: patient + facility staff
create policy "Patients read own medical documents"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'medical-documents'
    and (storage.foldername(name))[2]::uuid = auth.uid()
  );

create policy "Facility staff read facility medical documents"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'medical-documents'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  );

create policy "Facility staff upload medical documents"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'medical-documents'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  );

create policy "Facility staff manage medical documents"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'medical-documents'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  );

create policy "Facility staff delete medical documents"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'medical-documents'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  );

-- Prescriptions
create policy "Patients read own prescriptions"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'prescriptions'
    and (storage.foldername(name))[2]::uuid = auth.uid()
  );

create policy "Doctors manage prescription files"
  on storage.objects for all
  to authenticated
  using (
    bucket_id = 'prescriptions'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  )
  with check (
    bucket_id = 'prescriptions'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin', 'doctor']::public.app_role[]
    )
  );

-- Facility assets: public read, facility admin write
create policy "Public read facility assets"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'facility-assets');

create policy "Facility admins manage facility assets"
  on storage.objects for all
  to authenticated
  using (
    bucket_id = 'facility-assets'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin']::public.app_role[]
    )
  )
  with check (
    bucket_id = 'facility-assets'
    and public.has_facility_role(
      (storage.foldername(name))[1]::uuid,
      array['facility_admin']::public.app_role[]
    )
  );

-- Avatars: user owns their folder
create policy "Public read avatars"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');

create policy "Users upload own avatar"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1]::uuid = auth.uid()
  );

create policy "Users update own avatar"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1]::uuid = auth.uid()
  );

create policy "Users delete own avatar"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1]::uuid = auth.uid()
  );

commit;
