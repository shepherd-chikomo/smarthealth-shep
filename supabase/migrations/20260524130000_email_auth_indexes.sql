-- Email lookup for OTP auth (case-insensitive unique emails on profiles)

begin;

create unique index if not exists profiles_email_lower_unique_idx
  on public.profiles (lower(email))
  where email is not null;

commit;
