// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for North Ndebele (`nd`).
class AppLocalizationsNd extends AppLocalizations {
  AppLocalizationsNd([String locale = 'nd']) : super(locale);

  @override
  String get appTitle => 'MyHealth';

  @override
  String get offlineBannerMessage =>
      'Awukho ku-inthanethi · sibonisa idatha egciniwe';

  @override
  String get homeWelcome => 'Wamukelekile ku-MyHealth';

  @override
  String get homePoweredBySmartHealth => 'Ixhaswe ngu-SmartHealth';

  @override
  String get splashLoading => 'Iyalayisha…';

  @override
  String get navHome => 'Ekhaya';

  @override
  String get navSearch => 'Sesha';

  @override
  String get navEmergency => 'Isimo esiphuthumayo';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Iphrofayili';

  @override
  String get homeSearchHint => 'Search doctors, hospitals, pharmacies';

  @override
  String get homeChangeLocation => 'Change location';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get homeProfileComplete => 'Profile Complete';

  @override
  String get homeProfileCompleteHint => 'Complete your health profile';

  @override
  String get homeMedicalProfile => 'Medical Profile';

  @override
  String get homeBloodType => 'Blood Type';

  @override
  String get homeAge => 'Age';

  @override
  String get homeGender => 'Gender';

  @override
  String get homeNoKnownAllergies => 'No Known Allergies';

  @override
  String homeAllergyAlert(String allergen) {
    return '$allergen Allergy';
  }

  @override
  String get homeViewMedicalProfile => 'Tap to view full profile →';

  @override
  String get profileCompletionTitle => 'Profile Completion';

  @override
  String get profileCompletionSubtitle =>
      'Complete your medical profile to help providers deliver safer care.';

  @override
  String get profileCompletionCta => 'Complete profile';

  @override
  String get profileCompletionViewProfile => 'View medical profile';

  @override
  String get homeNearbyProviders => 'Nearby providers';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNearbyFacilities => 'Nearby Facilities';

  @override
  String get homeEmergencyTitle => 'Emergency assistance';

  @override
  String get homeEmergencySubtitle => 'Ambulance • Police • Fire • Rescue';

  @override
  String get homeCategoryNearMe => 'Near Me';

  @override
  String get homeCategoryGeneral => 'General';

  @override
  String get homeCategoryGeneralPractice => 'General Practice';

  @override
  String get homeCategoryPediatrics => 'Pediatric';

  @override
  String get homeCategoryDental => 'Dentist';

  @override
  String get homeCategoryPharmacy => 'Pharmacy';

  @override
  String get homeCategoryLaboratory => 'Laboratory';

  @override
  String get homeCategorySpecialists => 'Specialists';

  @override
  String get homeCategoryCardiology => 'Cardiology';

  @override
  String get homeCategoryMore => 'More >';

  @override
  String get homeMdpczVerified => 'MDPCZ verified';

  @override
  String homeLastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String homeDistanceKm(double distance) {
    final intl.NumberFormat distanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String distanceString = distanceNumberFormat.format(distance);

    return '$distanceString km';
  }

  @override
  String get homeRetry => 'Try again';

  @override
  String get homeErrorTitle => 'Could not load facilities';

  @override
  String get homeNoProviders => 'No facilities match this category nearby.';

  @override
  String homeShowAllInCity(String city) {
    return 'Show all in $city';
  }

  @override
  String homeCityFallbackHint(String city) {
    return 'Showing facilities in $city (exact location unavailable)';
  }

  @override
  String get facilityOpenInMaps => 'Open in maps';

  @override
  String get facilityMapsOpenFailed => 'Could not open maps on this device';

  @override
  String get searchInputHint => 'Search doctors, clinics, conditions…';

  @override
  String get searchFilterSpecialty => 'Filter by Specialty';

  @override
  String get searchFilterCondition => 'Filter by Medical Condition';

  @override
  String get searchFilterAgeGroup => 'Patient Age Group';

  @override
  String searchApplyFilters(int count) {
    return 'Apply Filters ($count results)';
  }

  @override
  String get searchResultsTitle => 'Directory Results';

  @override
  String searchResultsCount(int count) {
    return '$count providers found';
  }

  @override
  String get searchNoResults => 'No providers match your search and filters.';

  @override
  String get searchNoResultsHint =>
      'Try adjusting your filters or search for a different specialty.';

  @override
  String get searchClearFilters => 'Adjust filters';

  @override
  String get searchEmptyAvailableToday => 'No providers available today';

  @override
  String get searchEmptyWalkIns => 'No facilities currently accepting walk-ins';

  @override
  String get searchEmptyQueueHigh => 'Queue times currently high';

  @override
  String get searchFilterOperational => 'Availability';

  @override
  String get searchRecentSearches => 'Recent Searches';

  @override
  String get searchPopularSpecialties => 'Popular Specialties';

  @override
  String get searchNearbyFacilities => 'Nearby Facilities';

  @override
  String get searchEmergencyShortcuts => 'Emergency Shortcuts';

  @override
  String get searchEmergencyNearMe => 'Emergency care near me';

  @override
  String get searchOpenNowShortcut => 'Open now nearby';

  @override
  String get searchEmergencyHub => 'Emergency hub';

  @override
  String get searchMapView => 'Map view';

  @override
  String get searchOfflineHint => 'Offline · searching cached providers';

  @override
  String get searchErrorTitle => 'Could not load directory';

  @override
  String get profileCallNow => 'Call Now';

  @override
  String get profileGetDirections => 'Get Directions';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutEmpty => 'No biography available for this provider.';

  @override
  String get profileShowMore => 'Show more';

  @override
  String get profileShowLess => 'Show less';

  @override
  String get profileServices => 'Services';

  @override
  String get profileServicesEmpty => 'No services listed.';

  @override
  String get profileWorkingHours => 'Working Hours';

  @override
  String get profileClosed => 'Closed';

  @override
  String get profileBookAppointment => 'Book Appointment';

  @override
  String get profileBookPhase2 => 'Coming in Phase 2';

  @override
  String get profileMdpczVerified => 'MDPCZ Verified';

  @override
  String get profileOfflineHint => 'Offline · showing saved profile';

  @override
  String get profileNotFoundTitle => 'Provider not found';

  @override
  String profileNotFoundBody(String id) {
    return 'We couldn\'t find a provider with ID \"$id\".';
  }

  @override
  String get profileGoBack => 'Go back';

  @override
  String get profileErrorTitle => 'Could not load profile';

  @override
  String get profileErrorGeneric =>
      'Something went wrong while loading this profile.';

  @override
  String get emergencyWarningBanner =>
      'For life-threatening emergencies, call 999/994 directly';

  @override
  String emergencyNearestDistance(double distance) {
    final intl.NumberFormat distanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String distanceString = distanceNumberFormat.format(distance);

    return 'Nearest · $distanceString km';
  }

  @override
  String get emergencyNearbyFacilities => 'Nearby 24hr Emergency Facilities';

  @override
  String get emergencyCall => 'CALL';

  @override
  String get emergencyDirections => 'Directions';

  @override
  String get emergencyCallNow => 'CALL NOW';

  @override
  String get emergencyShowDirections => 'Show Directions';

  @override
  String get emergencyNearestProvider => 'Nearest provider';

  @override
  String get emergencyOfflineReady => 'Offline · emergency numbers ready';

  @override
  String get emergencyNearestServicesTitle => 'Nearest Emergency Services';

  @override
  String get emergencyHospitalsFacilitiesTitle =>
      'Hospitals & Emergency Facilities';

  @override
  String get emergencyFilterAll => 'All';

  @override
  String get emergencyFilterAmbulances => 'Ambulances';

  @override
  String emergencySelectedLocation(String city) {
    return 'Selected location · $city';
  }

  @override
  String get emergencyCurrentLocation => 'Current location';

  @override
  String get emergencyUseCurrentLocation => 'Use current location';

  @override
  String get emergencyExpandedSearchHint =>
      'No facilities within 50 km — showing nearest 10.';

  @override
  String get emergencyNoServicesNearby =>
      'No emergency service providers found nearby.';

  @override
  String get emergencyNoFacilitiesNearby =>
      'No hospitals or emergency departments found within 50 km.';

  @override
  String get emergencyLocationPrompt =>
      'Turn on location to see nearest emergency services and hospitals.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingFindDoctorsTitle => 'Find trusted doctors near you';

  @override
  String get onboardingFindDoctorsBody =>
      'Discover verified providers across Zimbabwe with maps, filters, and offline access.';

  @override
  String get onboardingBookAppointmentsTitle => 'Book appointments instantly';

  @override
  String get onboardingBookAppointmentsBody =>
      'Choose a time, confirm in seconds, and keep every visit organised in one place.';

  @override
  String get onboardingEmergencyHelpTitle => 'Emergency help, one tap away';

  @override
  String get onboardingEmergencyHelpBody =>
      'Reach ambulance, police, fire, and rescue numbers even when you\'re offline.';

  @override
  String get appointmentsErrorTitle => 'Could not load appointments';

  @override
  String get appointmentsUpcoming => 'Upcoming';

  @override
  String get appointmentsPast => 'Past';

  @override
  String get appointmentsEmptyUpcoming =>
      'No upcoming appointments. Book a visit from any provider profile.';

  @override
  String get appointmentsDetailTitle => 'Appointment';

  @override
  String get appointmentsNotFound => 'Appointment not found';

  @override
  String get appointmentsPatientActions => 'Your actions';

  @override
  String get appointmentsFacilityActions => 'Staff actions';

  @override
  String get appointmentsCheckIn => 'Check in';

  @override
  String get appointmentsJoinQueue => 'Join queue';

  @override
  String get appointmentsViewQueue => 'View queue status';

  @override
  String get appointmentsReschedule => 'Reschedule';

  @override
  String get appointmentsCancel => 'Cancel appointment';

  @override
  String get appointmentsContactFacility => 'Contact facility';

  @override
  String get appointmentsNoActions =>
      'No actions available for this appointment.';

  @override
  String get appointmentsConfirmBooking => 'Confirm booking';

  @override
  String get appointmentsMarkArrived => 'Mark arrived';

  @override
  String get appointmentsMoveToQueue => 'Move to queue';

  @override
  String get appointmentsCompleteConsultation => 'Complete consultation';

  @override
  String get appointmentsCancelBooking => 'Cancel booking';

  @override
  String get appointmentsCancelConfirm =>
      'Are you sure you want to cancel this appointment?';

  @override
  String get appointmentsKeep => 'Keep appointment';

  @override
  String get appointmentsCheckInPrompt =>
      'Confirm you\'ve arrived at the facility';

  @override
  String get appointmentsAssignQueue => 'Assign to queue';

  @override
  String get appointmentsAssignQueueHint =>
      'Join the provider queue after check-in';

  @override
  String get appointmentsConfirmArrival => 'Confirm arrival';

  @override
  String get appointmentsSelectDate => 'Select a date to see available times';

  @override
  String get appointmentsConfirmReschedule => 'Confirm new time';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsPreferences => 'Notification preferences';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'Appointment reminders, queue updates, and alerts will appear here.';

  @override
  String get notificationsErrorTitle => 'Could not load notifications';

  @override
  String get notificationsGroupToday => 'Today';

  @override
  String get notificationsGroupYesterday => 'Yesterday';

  @override
  String get notificationsGroupEarlier => 'Earlier';
}
