/// Facility-level operational states shown on provider and search cards.
enum FacilityOperationalStatus {
  openNow,
  closed,
  closingSoon,
  emergencyAvailable,
  walkInsAccepted,
  queueAvailable,
  availableToday,
}

/// Appointment lifecycle states.
enum AppointmentOperationalStatus {
  pending,
  confirmed,
  checkedIn,
  inQueue,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

/// Listing ownership / verification states shown on profiles and admin views.
enum ClaimOperationalStatus {
  unclaimed,
  claimPending,
  verifiedFacility,
  verifiedPractitioner,
}
