-- SmartHealth: audit triggers for extended schema tables

begin;

create trigger audit_consultations
  after insert or update or delete on public.consultations
  for each row execute function audit.log_row_change();

create trigger audit_invoices
  after insert or update or delete on public.invoices
  for each row execute function audit.log_row_change();

create trigger audit_payments
  after insert or update or delete on public.payments
  for each row execute function audit.log_row_change();

create trigger audit_walk_in_sessions
  after insert or update or delete on public.walk_in_sessions
  for each row execute function audit.log_row_change();

create trigger audit_facility_claims
  after insert or update or delete on public.facility_claims
  for each row execute function audit.log_row_change();

create trigger audit_provider_claims
  after insert or update or delete on public.provider_claims
  for each row execute function audit.log_row_change();

-- Realtime for queue and walk-ins
alter publication supabase_realtime add table public.walk_in_sessions;
alter publication supabase_realtime add table public.queue_sessions;
alter publication supabase_realtime add table public.notifications;

alter table public.walk_in_sessions replica identity full;
alter table public.queue_sessions replica identity full;
alter table public.notifications replica identity full;

commit;
