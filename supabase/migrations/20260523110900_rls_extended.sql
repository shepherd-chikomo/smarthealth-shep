-- SmartHealth: RLS policies for extended schema

begin;

-- Enable RLS on all new tables
alter table public.countries enable row level security;
alter table public.cities enable row level security;
alter table public.facility_operating_hours enable row level security;
alter table public.facility_claims enable row level security;
alter table public.provider_claims enable row level security;
alter table public.queue_sessions enable row level security;
alter table public.app_settings enable row level security;
alter table public.walk_in_sessions enable row level security;
alter table public.appointment_status_history enable row level security;
alter table public.appointment_notes enable row level security;
alter table public.appointment_payments enable row level security;
alter table public.consultations enable row level security;
alter table public.diagnoses enable row level security;
alter table public.lab_results enable row level security;
alter table public.vitals enable row level security;
alter table public.allergies enable row level security;
alter table public.chronic_conditions enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.payments enable row level security;
alter table public.payment_transactions enable row level security;
alter table public.refunds enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.stock_movements enable row level security;
alter table public.purchase_orders enable row level security;
alter table public.purchase_order_items enable row level security;
alter table public.notifications enable row level security;
alter table public.push_tokens enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.sms_logs enable row level security;
alter table public.email_logs enable row level security;
alter table public.emergency_services enable row level security;
alter table public.activity_logs enable row level security;
alter table public.usage_metrics enable row level security;
alter table public.revenue_reports enable row level security;

-- Helper: tenant staff check macro pattern
-- Public reference data
create policy "Anyone can read countries"
  on public.countries for select to anon, authenticated using (is_active = true);

create policy "Anyone can read cities"
  on public.cities for select to anon, authenticated using (is_active = true);

create policy "Super admins manage countries"
  on public.countries for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy "Super admins manage cities"
  on public.cities for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- Emergency services (public directory)
create policy "Anyone can view active emergency services"
  on public.emergency_services for select to anon, authenticated
  using (is_active = true and deleted_at is null and moderation_status = 'approved');

create policy "Super admins manage emergency services"
  on public.emergency_services for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- Facility operating hours
create policy "Public can view facility hours"
  on public.facility_operating_hours for select to anon, authenticated
  using (exists (
    select 1 from public.facilities f
    where f.id = facility_operating_hours.facility_id
      and f.is_active = true and f.deleted_at is null
  ));

create policy "Facility admins manage operating hours"
  on public.facility_operating_hours for all to authenticated
  using (public.has_facility_role(facility_id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(facility_id, array['facility_admin']::public.app_role[]));

-- Claims
create policy "Claimants manage own facility claims"
  on public.facility_claims for all to authenticated
  using (claimant_id = auth.uid() or public.is_super_admin())
  with check (claimant_id = auth.uid() or public.is_super_admin());

create policy "Super admins review facility claims"
  on public.facility_claims for select to authenticated
  using (public.is_super_admin());

create policy "Claimants manage own provider claims"
  on public.provider_claims for all to authenticated
  using (claimant_id = auth.uid() or public.is_super_admin())
  with check (claimant_id = auth.uid() or public.is_super_admin());

-- Queue & walk-ins
create policy "Facility staff manage queue sessions"
  on public.queue_sessions for all to authenticated
  using (public.has_facility_role(facility_id, array['facility_admin', 'receptionist', 'doctor']::public.app_role[]))
  with check (public.has_facility_role(facility_id, array['facility_admin', 'receptionist', 'doctor']::public.app_role[]));

create policy "Patients view own walk-in sessions"
  on public.walk_in_sessions for select to authenticated
  using (patient_id = auth.uid());

create policy "Facility staff manage walk-in sessions"
  on public.walk_in_sessions for all to authenticated
  using (public.has_facility_role(facility_id, array['facility_admin', 'receptionist', 'doctor']::public.app_role[]))
  with check (public.has_facility_role(facility_id, array['facility_admin', 'receptionist', 'doctor']::public.app_role[]));

-- Appointment extensions
create policy "Patients view own appointment history"
  on public.appointment_status_history for select to authenticated
  using (exists (
    select 1 from public.appointments a
    where a.id = appointment_status_history.appointment_id and a.patient_id = auth.uid()
  ));

create policy "Facility staff view appointment history"
  on public.appointment_status_history for select to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]));

create policy "Facility staff manage appointment notes"
  on public.appointment_notes for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]));

create policy "Patients view non-confidential appointment notes"
  on public.appointment_notes for select to authenticated
  using (
    is_confidential = false
    and exists (
      select 1 from public.appointments a
      where a.id = appointment_notes.appointment_id and a.patient_id = auth.uid()
    )
  );

create policy "Patients view own appointment payments"
  on public.appointment_payments for select to authenticated
  using (patient_id = auth.uid());

create policy "Facility staff manage appointment payments"
  on public.appointment_payments for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

-- Medical records
create policy "Patients view own consultations"
  on public.consultations for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy "Facility staff manage consultations"
  on public.consultations for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'doctor']::public.app_role[]));

create policy "Patients view own diagnoses"
  on public.diagnoses for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy "Doctors manage diagnoses"
  on public.diagnoses for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'doctor']::public.app_role[]));

create policy "Patients view own lab results"
  on public.lab_results for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy "Facility staff manage lab results"
  on public.lab_results for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]));

create policy "Patients view own vitals"
  on public.vitals for select to authenticated using (patient_id = auth.uid() and deleted_at is null);

create policy "Facility staff manage vitals"
  on public.vitals for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[]));

create policy "Patients manage own allergies"
  on public.allergies for all to authenticated
  using (patient_id = auth.uid()) with check (patient_id = auth.uid());

create policy "Staff view patient allergies at facility"
  on public.allergies for select to authenticated
  using (tenant_id is not null and public.is_facility_member(tenant_id));

create policy "Patients manage own chronic conditions"
  on public.chronic_conditions for all to authenticated
  using (patient_id = auth.uid()) with check (patient_id = auth.uid());

create policy "Staff view patient chronic conditions at facility"
  on public.chronic_conditions for select to authenticated
  using (tenant_id is not null and public.is_facility_member(tenant_id));

-- Billing
create policy "Patients view own invoices"
  on public.invoices for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy "Facility staff manage invoices"
  on public.invoices for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff manage invoice items"
  on public.invoice_items for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Patients view own payments"
  on public.payments for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy "Facility staff manage payments"
  on public.payments for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff view payment transactions"
  on public.payment_transactions for select to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff manage refunds"
  on public.refunds for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

-- Inventory
create policy "Facility staff manage suppliers"
  on public.suppliers for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff manage products"
  on public.products for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff manage stock movements"
  on public.stock_movements for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin', 'receptionist']::public.app_role[]));

create policy "Facility staff manage purchase orders"
  on public.purchase_orders for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

create policy "Facility staff manage purchase order items"
  on public.purchase_order_items for all to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

-- Notifications
create policy "Users manage own notifications"
  on public.notifications for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "Users manage own push tokens"
  on public.push_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "Users manage own notification preferences"
  on public.notification_preferences for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "Users view own sms logs"
  on public.sms_logs for select to authenticated
  using (user_id = auth.uid());

create policy "Facility admins view tenant sms logs"
  on public.sms_logs for select to authenticated
  using (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

create policy "Users view own email logs"
  on public.email_logs for select to authenticated
  using (user_id = auth.uid());

create policy "Facility admins view tenant email logs"
  on public.email_logs for select to authenticated
  using (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

-- App settings
create policy "Public read public app settings"
  on public.app_settings for select to anon, authenticated
  using (is_public = true);

create policy "Super admins manage platform settings"
  on public.app_settings for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy "Facility admins manage tenant settings"
  on public.app_settings for all to authenticated
  using (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]))
  with check (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

-- Analytics
create policy "Super admins read activity logs"
  on public.activity_logs for select to authenticated
  using (public.is_super_admin());

create policy "Facility admins read tenant activity logs"
  on public.activity_logs for select to authenticated
  using (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

create policy "Users insert own activity logs"
  on public.activity_logs for insert to authenticated
  with check (user_id = auth.uid());

create policy "Facility admins read usage metrics"
  on public.usage_metrics for select to authenticated
  using (tenant_id is not null and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

create policy "Super admins manage usage metrics"
  on public.usage_metrics for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy "Facility admins read revenue reports"
  on public.revenue_reports for select to authenticated
  using (public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[]));

create policy "Super admins manage revenue reports"
  on public.revenue_reports for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- Tighten existing policies for soft deletes
drop policy if exists "Public can view active facilities" on public.facilities;
create policy "Public can view active facilities"
  on public.facilities for select to anon, authenticated
  using (is_active = true and deleted_at is null and moderation_status = 'approved');

drop policy if exists "Public can view active providers" on public.providers;
create policy "Public can view active providers"
  on public.providers for select to anon, authenticated
  using (is_active = true and deleted_at is null and moderation_status = 'approved');

commit;
