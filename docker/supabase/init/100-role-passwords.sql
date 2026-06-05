-- Sync internal Supabase role passwords with POSTGRES_PASSWORD (official self-host pattern).
-- Must run via psql during first DB init (superuser context).
\set pgpass `echo "$POSTGRES_PASSWORD"`

ALTER USER authenticator WITH PASSWORD :'pgpass';
ALTER USER supabase_auth_admin WITH PASSWORD :'pgpass';
ALTER USER supabase_storage_admin WITH PASSWORD :'pgpass';
