-- SmartHealth: Realtime publication for live updates

begin;

-- Add tables to supabase_realtime publication
alter publication supabase_realtime add table public.appointments;
alter publication supabase_realtime add table public.providers;
alter publication supabase_realtime add table public.facilities;
alter publication supabase_realtime add table public.prescriptions;

-- Replica identity for filtered realtime subscriptions
alter table public.appointments replica identity full;
alter table public.prescriptions replica identity full;

-- Realtime authorization uses RLS — clients only receive rows they can SELECT

commit;
