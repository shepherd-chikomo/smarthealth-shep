# SmartHealth RLS & Security

Role-based Row Level Security for multi-tenant healthcare data isolation.

## Roles

| Role | Access scope |
|------|--------------|
| **patient** | Own profile, appointments, family members, medical records |
| **doctor** | Assigned appointments only; consultations they own via `provider_id` |
| **receptionist** | Full tenant appointments, billing, queue (no clinical write on others' consultations) |
| **facility_admin** | Staff, providers, analytics, inventory, tenant settings |
| **super_admin** | Full platform access |

## Security helper functions

| Function | Purpose |
|----------|---------|
| `get_user_role()` | Primary role from JWT or profile |
| `get_facility_role(facility_id)` | Membership role at tenant |
| `is_patient()` | Pure patient (no staff membership) |
| `is_doctor(facility_id)` | Doctor membership at tenant |
| `is_facility_admin(facility_id)` | Admin at tenant |
| `current_user_provider_ids()` | Provider records linked to user |
| `is_assigned_to_provider(provider_id)` | Doctor assignment check |
| `can_access_tenant(tenant_id)` | Tenant staff or super admin |
| `staff_can_view_patient_profile(patient_id)` | Staff access to patient profile |
| `owns_consultation(consultation_id)` | Doctor owns consultation |
| `log_security_event(...)` | Write to `audit.security_events` + `activity_logs` |

## Audit

- **Row changes:** `audit.logs` (existing triggers)
- **Security events:** `audit.security_events` via `log_security_event()`
- Tenant ID captured from `tenant_id` or `facility_id` columns

## Run security tests

```powershell
./scripts/supabase/test-rls.ps1
```

Tests simulate JWT claims via `request.jwt.claims` and verify:

- Patients cannot see other patients' data
- Doctors only see assigned appointments / consultations
- Facility admins manage staff and providers at their tenant
- Tenant isolation between Clinic A and Clinic B
- Super admins have full access

## Policy naming

All policies use prefix `rls_<resource>_<actor>_<action>` for traceability.

Migrations:

- `20260523120000_rls_security_functions.sql`
- `20260523120100_rls_policies_comprehensive.sql`
