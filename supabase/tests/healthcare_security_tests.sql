-- Healthcare security schema tests
-- Run after migrations: psql $DATABASE_URL -f supabase/tests/healthcare_security_tests.sql

begin;

-- Consent tracking
select plan(6);

select has_table('public', 'patient_consents', 'patient_consents table exists');
select has_column('public', 'patient_consents', 'consent_type', 'consent_type column exists');
select has_column('public', 'patient_consents', 'withdrawn_at', 'withdrawn_at column exists');

-- Medical access logs
select has_table('audit', 'medical_access_logs', 'medical_access_logs table exists');
select has_column('audit', 'medical_access_logs', 'actor_id', 'actor_id column exists');
select has_column('audit', 'medical_access_logs', 'patient_id', 'patient_id column exists');

select finish();
rollback;
