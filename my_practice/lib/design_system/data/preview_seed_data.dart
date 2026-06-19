import 'package:flutter/material.dart';

/// Realistic Zimbabwe healthcare demo data for design previews.
abstract final class PreviewSeedData {
  static const facilityName = 'Borrowdale Medical Centre';
  static const facilityLicense = 'MOHCC-FAC-00421';
  static const practitionerName = 'Dr. Tendai Mukamuri';
  static const practitionerTitle = 'General Practitioner';
  static const practitionerInitials = 'TM';
  static const todayLabel = 'Wednesday, 12 June 2026';

  static const kpis = [
    ('Today\'s Appointments', '24', '+3 vs yest', 'calendar_today', 0),
    ('Waiting Patients', '6', '2 priority', 'groups', 1),
    ('Completed Encounters', '11', '46% of day', 'check_circle', 2),
    ('Outstanding Claims', '\$3,840', '12 claims', 'request_quote', 3),
    ('Revenue Today', '\$1,920', '+18%', 'payments', 4),
    ('Pending Follow-Ups', '8', '3 overdue', 'assignment', 5),
  ];

  static const queueWaiting = [
    ('ND', 'Nyasha Dube', 'SH-101587', '7F', 'Fever & cough', '09:04', 'Cimas'),
    ('RC', 'Rumbidzai Chiweshe', 'SH-100214', '34F', 'Hypertension review', '09:12', 'PSMAS'),
  ];

  static const queueInConsult = [
    ('TG', 'Tatenda Gumbo', 'SH-102341', '23F', 'Antenatal review', '09:15', 'Cellmed'),
  ];

  static const upcomingAppointments = [
    ('08:50', 'CN', 'Chipo Ndlovu', 'Lab follow-up', 'checked in'),
    ('09:15', 'TG', 'Tatenda Gumbo', 'Antenatal', 'in consult'),
    ('09:45', 'ND', 'Nyasha Dube', 'Paediatric — fever', 'scheduled'),
    ('10:10', 'TM', 'Tafadzwa Moyo', 'Diabetes review', 'scheduled'),
  ];

  static const claimsActivity = [
    ('Cimas', 'paid', 'CLM-2026-0411', '+ \$85.00', true),
    ('PSMAS', 'approved', 'CLM-2026-0398', '\$120.00', null),
    ('FMH', 'under review', 'CLM-2026-0387', '\$320.00', null),
    ('Zimnat', 'rejected', 'CLM-2026-0372', '- \$180.00', false),
  ];

  static const patients = [
    ('RC', 'Rumbidzai Chiweshe', 'SH-100214', '34 · F', 'Cimas', '+263 77 234 5678', '2026-06-02'),
    ('TM', 'Tafadzwa Moyo', 'SH-100891', '52 · M', 'PSMAS', '+263 71 456 7890', '2026-06-08'),
    ('TG', 'Tatenda Gumbo', 'SH-102341', '23 · F', 'Cellmed', '+263 78 901 2345', '2026-06-11'),
    ('ND', 'Nyasha Dube', 'SH-101587', '7 · F', 'Cimas', '+263 77 112 3344', '2026-06-10'),
  ];

  static const insurers = [
    ('Cimas', '\$12,400', '\$10,200', '\$2,200', '14', '92%'),
    ('PSMAS', '\$8,750', '\$6,100', '\$2,650', '21', '78%'),
    ('First Mutual Health', '\$5,200', '\$4,800', '\$400', '11', '95%'),
    ('BonVie', '\$3,100', '\$2,400', '\$700', '18', '81%'),
    ('Alliance Health', '\$2,800', '\$2,100', '\$700', '16', '84%'),
    ('Cellmed', '\$4,600', '\$3,900', '\$700', '12', '88%'),
    ('Zimnat', '\$1,900', '\$1,200', '\$700', '25', '71%'),
  ];

  static const financeKpis = [
    ('Revenue MTD', '\$48,200', '+12%', true),
    ('Expenses MTD', '\$18,400', '-3%', false),
    ('Net Profit', '\$29,800', '+18%', true),
    ('Accounts Receivable', '\$6,240', '18 invoices', null),
  ];

  static const earningsKpis = [
    ('Gross Billings', '\$18,400', '+8%'),
    ('Collected', '\$14,200', '77%'),
    ('Outstanding', '\$4,200', '6 claims'),
    ('Revenue Share', '\$8,520', '60%'),
  ];

  static const staff = [
    ('Dr. Tendai Mukamuri', 'Doctor', 't.mukamuri@smarthealth.co.zw', 'Active'),
    ('Dr. Anesu Chigumba', 'Doctor', 'a.chigumba@smarthealth.co.zw', 'Active'),
    ('Sr. Patience Nyoni', 'Nurse', 'p.nyoni@smarthealth.co.zw', 'Active'),
    ('Tariro Mlambo', 'Receptionist', 't.mlambo@smarthealth.co.zw', 'Active'),
    ('Wellington Banda', 'Administrator', 'w.banda@smarthealth.co.zw', 'Inactive'),
  ];

  static const reportCategories = [
    ('Clinical Reports', 'Encounters, diagnoses, prescribing'),
    ('Financial Reports', 'Revenue, AR, collections'),
    ('Claims Reports', 'Submissions, approvals, rejections'),
    ('Operational Reports', 'Queue, utilisation, staff'),
    ('Disease Trends', 'ICD-11 surveillance'),
  ];

  static const navItems = [
    ('Dashboard', Icons.dashboard_outlined),
    ('Appointments', Icons.calendar_month_outlined),
    ('Patient Queue', Icons.groups_outlined),
    ('Patients', Icons.people_outline),
    ('Clinical Encounters', Icons.medical_services_outlined),
    ('Calendar', Icons.event_outlined),
    ('Prescriptions', Icons.medication_outlined),
    ('Facility Management', Icons.business_outlined),
    ('Claims & Medical Aid', Icons.shield_outlined),
    ('Finance', Icons.account_balance_wallet_outlined),
    ('Reports', Icons.bar_chart_outlined),
    ('Tasks', Icons.task_alt_outlined),
    ('Messages', Icons.chat_bubble_outline),
    ('Settings', Icons.settings_outlined),
  ];

  static const futureModules = [
    ('SmartHealth Connect', 'Referrals & specialist network'),
    ('SmartHealth Switch', 'FHIR interoperability'),
    ('SmartHealth Insights', 'Population health analytics'),
  ];
}
