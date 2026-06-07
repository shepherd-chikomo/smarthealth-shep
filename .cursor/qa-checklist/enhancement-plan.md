# QA Enhancement Plan — dev.smarthealth.co.zw

**Source:** [qa-checklist.canvas.tsx](file:///C:/Users/sheph/.cursor/projects/c-Users-sheph-Projects-smarthealth-shep/canvases/qa-checklist.canvas.tsx) review merged into `.cursor/qa-checklist/items.json` (revision 2, 2026-06-07)

**Scope:** 9 agreed enhancements only. Pending checklist items and passed items are out of scope unless they block an enhancement.

---

## Summary

| Phase | Theme | Items | Primary surfaces |
|-------|-------|-------|------------------|
| 1 | Mobile profile polish | 3 | Flutter profile/completion |
| 2 | Mobile appointments | 1 | Flutter home + appointments |
| 3 | Health vault backup | 1 | Flutter settings + local storage |
| 4 | Admin catalog data | 3 | Admin web + API + migrations |
| 5 | Facility portal | 2 | facility-portal + backend invitations |
| 6 | Emergency hub data | 1 | API + emergency directory seed |

**Recommended order:** Phase 1 → 2 → 4 (seed + catalogs) → 5 → 6 → 3 (largest new feature).

---

## Phase 1 — Mobile profile polish

### 1.1 Profile completion ring label overlap
**Checklist:** `mobile-profile-completion-screen`

- Fix percentage ring layout on `/profile/completion` so the numeric label no longer overlaps the arc or title.
- Likely touchpoint: completion widget used on home header and completion screen — align both.

**Acceptance:** Ring readable at all completion percentages; no text collision on small screens.

### 1.2 “None” as a valid profile answer
**Checklist:** `mobile-profile-completion-screen`

- Add explicit **None** option (or equivalent empty-state chip) for:
  - Allergies
  - Medical conditions
  - Medical aid
  - Primary provider
- Treat **None** as satisfying completion criteria (distinct from “not answered”).
- Persist a sentinel value locally and in API payload so completion % updates correctly.

**Acceptance:** User can mark any of the four sections as None; completion checklist clears those items.

### 1.3 Conditions picker — custom entry keyboard
**Checklist:** `mobile-conditions-catalog-picker`

- Fix **Other** flow in `condition_selection_sheet.dart`: TextField must receive focus and show keyboard on iOS/Android.
- Verify submit calls `submitCustomConditionProposals` and updates profile chips immediately.
- Depends on admin pending queue (existing backend) — no new API required for the keyboard fix.

**Acceptance:** Tap Other → keyboard appears → type label → submit → chip visible; entry appears in admin Conditions → Pending.

### 1.4 Emergency profile — family member crash + picker placement
**Checklist:** `mobile-emergency-profile-view-edit`

- Reproduce and fix exception when adding a family member from emergency profile edit flow.
- Move **profile / family member switcher** to the main Profile page (not buried in edit-only screens).
- Aligns with pending `mobile-family-member-picker` — implement unified picker here rather than a one-off control.

**Acceptance:** Add family member succeeds; switcher visible on main Profile; edit flows use the same picker.

---

## Phase 2 — Appointments reminder placement

### 2.1 Upcoming reminder on Home, not Bookings
**Checklist:** `mobile-bookings-sync`

- Surface “Reminder scheduled” / next-upcoming appointment banner on **Home** (`appointments_repository.getNextUpcoming()` or equivalent).
- Remove or de-emphasize duplicate banner on Bookings list if it currently only appears there.
- Confirm sync still works on appointments list (pull-to-refresh unchanged).

**Acceptance:** With a future booking, Home shows the reminder banner; Bookings page is not the only place it appears.

---

## Phase 3 — Health vault backup (PIN + local export)

**Checklist:** `mobile-health-vault-privacy` (overlaps pending `mobile-backup-restore`)

### 3.1 Export backup to device
- Add **Export backup** in Health Vault / Settings.
- Write encrypted JSON (or existing backup format) to app-accessible storage (Documents/Downloads via `path_provider` + platform share/save sheet).

### 3.2 PIN-protected backup
- Prompt for PIN on export; encrypt backup payload (AES + PIN-derived key, or platform keystore wrapper).
- Require PIN on import/restore.

### 3.3 Reinstall discovery
- On first launch after install, scan known local directories for SmartHealth backup files.
- If found, offer import flow gated on correct PIN.

**Acceptance:** Export → file on device → uninstall/reinstall → app detects backup → PIN unlock → profile restored.

**Note:** This is the largest mobile enhancement; schedule after smaller fixes unless backup is urgent.

---

## Phase 4 — Admin catalog expansion

### 4.1 Seed chronic conditions (common list)
**Checklist:** `admin-conditions-tab`

- Add migration or admin seed script inserting the QA-provided chronic condition list into `profile_conditions` with `is_common = true`, grouped sort order (cardiac, respiratory, endocrine, etc.).
- Existing CRUD in `ConditionsPanel.tsx` and `profile-conditions.service.ts` — no new approval workflow needed for seed data.

**Acceptance:** Mobile “common” picker shows full chronic list; admin Conditions tab lists same entries.

### 4.2 Services catalog (admin + facility submissions)
**Checklist:** `facility-public-profile-config`

**Backend (mirror conditions pattern):**
- Tables: `facility_services` (catalog), `service_submissions` (pending facility proposals).
- Admin routes: CRUD + approve/reject submissions.
- Catalog route: `GET /v1/catalog/facility-services` for portal + mobile.

**Admin UI:**
- New **Services** tab beside Conditions in Content section.

**Facility portal:**
- Public profile service picker reads from catalog API (fixes missing Gynaecology).
- “Suggest a service” → pending submission → admin approval → globally available.

**Acceptance:** Gynaecology (and other catalog entries) selectable; facility-proposed services flow through admin approval.

### 4.3 Medical aid catalog (admin + facility submissions)
**Checklist:** `facility-public-profile-config`

**Backend:**
- Tables: `medical_aid_schemes` (if not already centralized), `medical_aid_submissions`.
- Admin **Medical Aid** tab beside Services.
- Facility portal: suggest new scheme → admin approval.

**Acceptance:** Facility public profile and mobile medical-aid search draw from the same admin-managed catalog; new schemes require approval.

**Dependencies:** Pending `api-medical-aid-search` and `api-facility-public-profile` QA should be run after catalog endpoints ship.

---

## Phase 5 — Facility portal staff & navigation

### 5.1 Staff invite on add
**Checklist:** `facility-staff-calendar-fixes`

- `addStaffMember` in `facility.service.ts` currently creates membership but does **not** send email (unlike `inviteFacilityAdminByEmail` / `invitePractitionerByRegNumber`).
- After membership insert, send invite email via `sendEmail` with portal login / set-password link (or in-app notification if user exists).
- Wire facility-portal **Add staff** UI to surface invite-sent confirmation.

**Acceptance:** Adding staff triggers email (or in-app notification for existing users); QA can verify delivery on dev.

### 5.2 Navigation restructure
**Checklist:** `facility-staff-calendar-fixes`

- Move **Staff** under **Facility profile** section (not top-level nav).
- Add **Doctors** as sub-tab under Staff (practitioners vs reception/admin roles).
- Update routes in `facility-portal/src/app` and sidebar config; preserve calendar/appointments paths.

**Acceptance:** Nav matches: Profile → Staff → Doctors; no dead links.

---

## Phase 6 — Emergency hub service providers

**Checklist:** `mobile-emergency-hub`

### 6.1 Location-based services visible
- Verify mobile sends `lat`/`lon` to `GET /emergency/hub` (`emergency_hub_repository.dart`).
- Confirm dev database has `emergency_directory` / grid service rows near QA test coordinates (Harare area).
- If data gap: seed emergency directory entries for ambulance, police, fire, poison control service types used by `GRID_SERVICE_TYPES` in `emergency-hub.service.ts`.
- If API returns services but UI empty: fix `_kindFromType` mapping in mobile repository.

**Acceptance:** Emergency hub shows service provider cards for QA location on dev; tap actions work.

**Dependencies:** Complete pending `api-emergency-hub` checklist after seed + mobile fix.

---

## Out of scope (pending QA — not agreed enhancements)

These remain **pending** in `items.json` and should not be scheduled as part of this plan unless they block a phase above:

| ID | Feature |
|----|---------|
| `mobile-family-member-picker` | Covered partially by Phase 1.4 |
| `mobile-backup-restore` | Covered by Phase 3 |
| `api-profile-conditions-catalog` | API QA pass after Phase 4.1 |
| `api-emergency-hub` | API QA pass after Phase 6 |
| `api-medical-aid-search` | API QA pass after Phase 4.3 |
| `api-facility-public-profile` | API QA pass after Phase 4.2–4.3 |
| `api-facility-types-parse` | Separate bugfix track |

---

## Suggested delivery slices (PR-sized)

1. **PR-A — Profile UX fixes:** 1.1, 1.2, 1.3, 1.4 (mobile only)
2. **PR-B — Home appointment banner:** 2.1
3. **PR-C — Conditions seed migration:** 4.1
4. **PR-D — Services catalog:** 4.2 (migration + API + admin tab + portal picker)
5. **PR-E — Medical aid catalog:** 4.3
6. **PR-F — Staff invite + nav:** 5.1, 5.2
7. **PR-G — Emergency hub data + mobile mapping:** 6.1
8. **PR-H — PIN backup export/restore:** 3.1–3.3

Re-run the [QA checklist canvas](file:///C:/Users/sheph/.cursor/projects/c-Users-sheph-Projects-smarthealth-shep/canvases/qa-checklist.canvas.tsx) after each PR to move enhancements to **passed**.
