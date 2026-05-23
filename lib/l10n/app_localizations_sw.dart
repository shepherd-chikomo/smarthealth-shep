// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'SmartHealth';

  @override
  String get offlineBannerMessage =>
      'Huna mtandao · tunaonyesha data iliyohifadhiwa';

  @override
  String get homeWelcome => 'Karibu SmartHealth';

  @override
  String get splashLoading => 'Inapakia…';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navSearch => 'Tafuta';

  @override
  String get navEmergency => 'Dharura';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get homeSearchHint => 'Search doctors, clinics, hospitals…';

  @override
  String get homeChangeLocation => 'Change location';

  @override
  String get homeNearbyFacilities => 'Nearby Facilities';

  @override
  String get homeEmergencyTitle => 'Emergency Hub';

  @override
  String get homeEmergencySubtitle => 'Ambulance, police & urgent care numbers';

  @override
  String get homeCategoryNearMe => 'Near Me';

  @override
  String get homeCategoryGeneralPractice => 'General Practice';

  @override
  String get homeCategoryPediatrics => 'Pediatrics';

  @override
  String get homeCategoryDental => 'Dental';

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
}
