-- SmartHealth: comprehensive RLS policies (role-based, tenant-isolated)
-- Replaces all prior public/audit RLS policies with strict role separation.

begin;

-- Drop every existing policy on public + audit schemas
do $$
declare
  pol record;
begin
  for pol in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname in ('public', 'audit')
  loop
    execute format(
      'drop policy if exists %I on %I.%I',
      pol.policyname, pol.schemaname, pol.tablename
    );
  end loop;
end $$;

-- Force RLS on sensitive tables (owners cannot bypass)
alter table public.profiles force row level security;
alter table public.appointments force row level security;
alter table public.family_members force row level security;
alter table public.consultations force row level security;
alter table public.facility_memberships force row level security;
alter table public.invoices force row level security;
alter table public.payments force row level security;
alter table audit.logs force row level security;
alter table audit.security_events force row level security;

-- ===========================================================================
-- PROFILES
-- ===========================================================================

create policy rls_profiles_patient_select on public.profiles for select to authenticated
  using (
    public.is_super_admin()
    or id = auth.uid()
    or public.staff_can_view_patient_profile(id)
  );

create policy rls_profiles_self_update on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy rls_profiles_super_admin on public.profiles for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- FACILITIES
-- ===========================================================================

create policy rls_facilities_public_select on public.facilities for select
  to anon, authenticated
  using (
    is_active = true
    and deleted_at is null
    and moderation_status = 'approved'
  );

create policy rls_facilities_admin_update on public.facilities for update to authenticated
  using (public.is_facility_admin(id))
  with check (public.is_facility_admin(id));

create policy rls_facilities_super_admin on public.facilities for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- FACILITY MEMBERSHIPS (staff management)
-- ===========================================================================

create policy rls_memberships_self_select on public.facility_memberships for select to authenticated
  using (
    user_id = auth.uid()
    or public.is_facility_admin(facility_id)
    or public.is_super_admin()
  );

create policy rls_memberships_admin_manage on public.facility_memberships for all to authenticated
  using (public.is_facility_admin(facility_id))
  with check (public.is_facility_admin(facility_id));

create policy rls_memberships_super_admin on public.facility_memberships for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- PROVIDERS (facility admin manages; public reads directory)
-- ===========================================================================

create policy rls_providers_public_select on public.providers for select
  to anon, authenticated
  using (is_active = true and deleted_at is null and moderation_status = 'approved');

create policy rls_providers_admin_manage on public.providers for all to authenticated
  using (public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_providers_super_admin on public.providers for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- PROVIDER WORKING HOURS
-- ===========================================================================

create policy rls_provider_hours_public_select on public.provider_working_hours for select
  to anon, authenticated
  using (exists (
    select 1 from public.providers p
    where p.id = provider_working_hours.provider_id
      and p.is_active = true and p.deleted_at is null
  ));

create policy rls_provider_hours_admin_manage on public.provider_working_hours for all to authenticated
  using (exists (
    select 1 from public.providers p
    where p.id = provider_working_hours.provider_id
      and public.is_facility_admin(p.tenant_id)
  ))
  with check (exists (
    select 1 from public.providers p
    where p.id = provider_working_hours.provider_id
      and public.is_facility_admin(p.tenant_id)
  ));

create policy rls_provider_hours_super_admin on public.provider_working_hours for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- FAMILY MEMBERS (patients manage own only)
-- ===========================================================================

create policy rls_family_patient_all on public.family_members for all to authenticated
  using (account_holder_id = auth.uid())
  with check (account_holder_id = auth.uid());

create policy rls_family_staff_select on public.family_members for select to authenticated
  using (public.staff_can_view_patient_profile(account_holder_id));

create policy rls_family_super_admin on public.family_members for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- APPOINTMENTS
-- ===========================================================================

create policy rls_appointments_patient_select on public.appointments for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_appointments_patient_insert on public.appointments for insert to authenticated
  with check (patient_id = auth.uid());

create policy rls_appointments_patient_update on public.appointments for update to authenticated
  using (
    patient_id = auth.uid()
    and deleted_at is null
    and status in ('pending', 'confirmed')
  )
  with check (patient_id = auth.uid());

create policy rls_appointments_doctor_select on public.appointments for select to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  );

create policy rls_appointments_doctor_update on public.appointments for update to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  )
  with check (
    public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  );

create policy rls_appointments_receptionist on public.appointments for all to authenticated
  using (
    deleted_at is null
    and (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  )
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_appointments_super_admin on public.appointments for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- APPOINTMENT EXTENSIONS
-- ===========================================================================

create policy rls_appt_history_patient_select on public.appointment_status_history for select to authenticated
  using (exists (
    select 1 from public.appointments a
    where a.id = appointment_status_history.appointment_id
      and a.patient_id = auth.uid()
  ));

create policy rls_appt_history_staff_select on public.appointment_status_history for select to authenticated
  using (public.can_access_tenant(tenant_id));

create policy rls_appt_history_super_admin on public.appointment_status_history for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_appt_notes_patient_select on public.appointment_notes for select to authenticated
  using (
    is_confidential = false and deleted_at is null
    and exists (
      select 1 from public.appointments a
      where a.id = appointment_notes.appointment_id and a.patient_id = auth.uid()
    )
  );

create policy rls_appt_notes_staff on public.appointment_notes for all to authenticated
  using (
    deleted_at is null and (
      public.is_receptionist(tenant_id)
      or public.is_facility_admin(tenant_id)
      or (
        public.is_doctor(tenant_id)
        and exists (
          select 1 from public.appointments a
          where a.id = appointment_notes.appointment_id
            and public.is_assigned_to_provider(a.provider_id)
        )
      )
    )
  )
  with check (
    public.is_receptionist(tenant_id)
    or public.is_facility_admin(tenant_id)
    or (
      public.is_doctor(tenant_id)
      and exists (
        select 1 from public.appointments a
        where a.id = appointment_notes.appointment_id
          and public.is_assigned_to_provider(a.provider_id)
      )
    )
  );

create policy rls_appt_notes_super_admin on public.appointment_notes for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_appt_payments_patient_select on public.appointment_payments for select to authenticated
  using (patient_id = auth.uid());

create policy rls_appt_payments_staff on public.appointment_payments for all to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_appt_payments_super_admin on public.appointment_payments for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- WALK-INS & QUEUE
-- ===========================================================================

create policy rls_walk_in_patient_select on public.walk_in_sessions for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_walk_in_staff on public.walk_in_sessions for all to authenticated
  using (deleted_at is null and public.is_facility_staff(tenant_id))
  with check (public.is_facility_staff(tenant_id));

create policy rls_walk_in_super_admin on public.walk_in_sessions for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_queue_staff on public.queue_sessions for all to authenticated
  using (public.is_facility_staff(facility_id))
  with check (public.is_facility_staff(facility_id));

create policy rls_queue_super_admin on public.queue_sessions for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- CONSULTATIONS (doctors: assigned only; admins: tenant-wide)
-- ===========================================================================

create policy rls_consultations_patient_select on public.consultations for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_consultations_doctor on public.consultations for all to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  )
  with check (
    public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  );

create policy rls_consultations_admin on public.consultations for all to authenticated
  using (deleted_at is null and public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_consultations_super_admin on public.consultations for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- DIAGNOSES, VITALS, LAB (follow consultation / assignment rules)
-- ===========================================================================

create policy rls_diagnoses_patient_select on public.diagnoses for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_diagnoses_doctor on public.diagnoses for all to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  )
  with check (
    public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  );

create policy rls_diagnoses_admin on public.diagnoses for all to authenticated
  using (deleted_at is null and public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_diagnoses_super_admin on public.diagnoses for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_vitals_patient_select on public.vitals for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_vitals_doctor on public.vitals for all to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and (
      consultation_id is null
      or exists (
        select 1 from public.consultations c
        where c.id = vitals.consultation_id
          and public.is_assigned_to_provider(c.provider_id)
      )
    )
  )
  with check (
    public.is_doctor(tenant_id)
    and (
      consultation_id is null
      or exists (
        select 1 from public.consultations c
        where c.id = vitals.consultation_id
          and public.is_assigned_to_provider(c.provider_id)
      )
    )
  );

create policy rls_vitals_staff on public.vitals for all to authenticated
  using (deleted_at is null and (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id)))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_vitals_super_admin on public.vitals for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_lab_patient_select on public.lab_results for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_lab_doctor on public.lab_results for all to authenticated
  using (deleted_at is null and public.is_doctor(tenant_id))
  with check (public.is_doctor(tenant_id));

create policy rls_lab_staff on public.lab_results for all to authenticated
  using (deleted_at is null and (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id)))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_lab_super_admin on public.lab_results for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- ALLERGIES & CHRONIC CONDITIONS (patients own; staff read at tenant)
-- ===========================================================================

create policy rls_allergies_patient on public.allergies for all to authenticated
  using (patient_id = auth.uid()) with check (patient_id = auth.uid());

create policy rls_allergies_staff_select on public.allergies for select to authenticated
  using (tenant_id is not null and public.is_facility_staff(tenant_id));

create policy rls_allergies_super_admin on public.allergies for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_chronic_patient on public.chronic_conditions for all to authenticated
  using (patient_id = auth.uid()) with check (patient_id = auth.uid());

create policy rls_chronic_staff_select on public.chronic_conditions for select to authenticated
  using (tenant_id is not null and public.is_facility_staff(tenant_id));

create policy rls_chronic_super_admin on public.chronic_conditions for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- MEDICAL DOCUMENTS & PRESCRIPTIONS
-- ===========================================================================

create policy rls_med_docs_patient_select on public.medical_documents for select to authenticated
  using (patient_id = auth.uid());

create policy rls_med_docs_doctor on public.medical_documents for all to authenticated
  using (
    public.is_doctor(facility_id)
    and (provider_id is null or public.is_assigned_to_provider(provider_id))
  )
  with check (
    public.is_doctor(facility_id)
    and (provider_id is null or public.is_assigned_to_provider(provider_id))
  );

create policy rls_med_docs_staff on public.medical_documents for all to authenticated
  using (public.is_receptionist(facility_id) or public.is_facility_admin(facility_id))
  with check (public.is_receptionist(facility_id) or public.is_facility_admin(facility_id));

create policy rls_med_docs_super_admin on public.medical_documents for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_prescriptions_patient_select on public.prescriptions for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_prescriptions_doctor on public.prescriptions for all to authenticated
  using (
    deleted_at is null
    and public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  )
  with check (
    public.is_doctor(tenant_id)
    and public.is_assigned_to_provider(provider_id)
  );

create policy rls_prescriptions_admin on public.prescriptions for all to authenticated
  using (deleted_at is null and public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_prescriptions_super_admin on public.prescriptions for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- BILLING (receptionist + admin; patients read own)
-- ===========================================================================

create policy rls_invoices_patient_select on public.invoices for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_invoices_staff on public.invoices for all to authenticated
  using (deleted_at is null and (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id)))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_invoices_super_admin on public.invoices for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_invoice_items_staff on public.invoice_items for all to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_invoice_items_patient_select on public.invoice_items for select to authenticated
  using (exists (
    select 1 from public.invoices i
    where i.id = invoice_items.invoice_id
      and i.patient_id = auth.uid()
      and i.deleted_at is null
  ));

create policy rls_invoice_items_super_admin on public.invoice_items for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_payments_patient_select on public.payments for select to authenticated
  using (patient_id = auth.uid() and deleted_at is null);

create policy rls_payments_staff on public.payments for all to authenticated
  using (deleted_at is null and (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id)))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_payments_super_admin on public.payments for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_pay_tx_staff_select on public.payment_transactions for select to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_pay_tx_super_admin on public.payment_transactions for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_refunds_admin on public.refunds for all to authenticated
  using (public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_refunds_super_admin on public.refunds for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- INVENTORY (facility admin + receptionist)
-- ===========================================================================

create policy rls_inventory_staff on public.suppliers for all to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_inventory_super_admin on public.suppliers for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_products_staff on public.products for all to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_products_super_admin on public.products for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_stock_staff on public.stock_movements for all to authenticated
  using (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id))
  with check (public.is_receptionist(tenant_id) or public.is_facility_admin(tenant_id));

create policy rls_stock_super_admin on public.stock_movements for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_po_admin on public.purchase_orders for all to authenticated
  using (public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_po_super_admin on public.purchase_orders for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_po_items_admin on public.purchase_order_items for all to authenticated
  using (public.is_facility_admin(tenant_id))
  with check (public.is_facility_admin(tenant_id));

create policy rls_po_items_super_admin on public.purchase_order_items for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- NOTIFICATIONS (user-scoped)
-- ===========================================================================

create policy rls_notifications_self on public.notifications for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy rls_notifications_super_admin on public.notifications for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_push_tokens_self on public.push_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy rls_notif_prefs_self on public.notification_preferences for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy rls_sms_logs_self on public.sms_logs for select to authenticated
  using (user_id = auth.uid());

create policy rls_sms_logs_admin on public.sms_logs for select to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id));

create policy rls_sms_logs_super_admin on public.sms_logs for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_email_logs_self on public.email_logs for select to authenticated
  using (user_id = auth.uid());

create policy rls_email_logs_admin on public.email_logs for select to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id));

create policy rls_email_logs_super_admin on public.email_logs for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- ANALYTICS (facility admin reads tenant; super admin all)
-- ===========================================================================

create policy rls_activity_self_insert on public.activity_logs for insert to authenticated
  with check (user_id = auth.uid());

create policy rls_activity_admin_select on public.activity_logs for select to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id));

create policy rls_activity_super_admin on public.activity_logs for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_usage_admin_select on public.usage_metrics for select to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id));

create policy rls_usage_super_admin on public.usage_metrics for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_revenue_admin_select on public.revenue_reports for select to authenticated
  using (public.is_facility_admin(tenant_id));

create policy rls_revenue_super_admin on public.revenue_reports for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- ===========================================================================
-- REFERENCE DATA & SYSTEM
-- ===========================================================================

create policy rls_countries_public on public.countries for select to anon, authenticated using (is_active = true);
create policy rls_countries_super_admin on public.countries for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_cities_public on public.cities for select to anon, authenticated using (is_active = true);
create policy rls_cities_super_admin on public.cities for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_specialties_public on public.specialties for select to anon, authenticated
  using (is_active = true and deleted_at is null);
create policy rls_specialties_super_admin on public.specialties for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_categories_public on public.provider_categories for select to anon, authenticated using (is_active = true);
create policy rls_categories_super_admin on public.provider_categories for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_emergency_public on public.emergency_services for select to anon, authenticated
  using (is_active = true and deleted_at is null and moderation_status = 'approved');
create policy rls_emergency_super_admin on public.emergency_services for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_emergency_facilities_public on public.emergency_facilities for select to anon, authenticated using (is_active = true);
create policy rls_emergency_facilities_super_admin on public.emergency_facilities for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

create policy rls_facility_hours_public on public.facility_operating_hours for select to anon, authenticated
  using (exists (select 1 from public.facilities f where f.id = facility_id and f.is_active = true and f.deleted_at is null));
create policy rls_facility_hours_admin on public.facility_operating_hours for all to authenticated
  using (public.is_facility_admin(facility_id))
  with check (public.is_facility_admin(facility_id));

create policy rls_app_settings_public on public.app_settings for select to anon, authenticated using (is_public = true);
create policy rls_app_settings_admin on public.app_settings for all to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id))
  with check (tenant_id is not null and public.is_facility_admin(tenant_id));
create policy rls_app_settings_super_admin on public.app_settings for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

-- Claims
create policy rls_facility_claims_claimant on public.facility_claims for all to authenticated
  using (claimant_id = auth.uid() or public.is_super_admin())
  with check (claimant_id = auth.uid() or public.is_super_admin());

create policy rls_provider_claims_claimant on public.provider_claims for all to authenticated
  using (claimant_id = auth.uid() or public.is_super_admin())
  with check (claimant_id = auth.uid() or public.is_super_admin());

-- ===========================================================================
-- AUDIT SCHEMA
-- ===========================================================================

create policy rls_audit_logs_super_admin on audit.logs for select to authenticated
  using (public.is_super_admin());

create policy rls_audit_logs_facility_admin on audit.logs for select to authenticated
  using (facility_id is not null and public.is_facility_admin(facility_id));

create policy rls_security_events_super_admin on audit.security_events for select to authenticated
  using (public.is_super_admin());

create policy rls_security_events_facility_admin on audit.security_events for select to authenticated
  using (tenant_id is not null and public.is_facility_admin(tenant_id));

create policy rls_security_events_insert on audit.security_events for insert to authenticated
  with check (user_id = auth.uid() or public.is_super_admin());

commit;
