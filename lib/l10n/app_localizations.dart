import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nd.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sn.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('nd'),
    Locale('pt'),
    Locale('sn'),
    Locale('sw'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'MyHealth'**
  String get appTitle;

  /// Persistent banner when device has no connectivity
  ///
  /// In en, this message translates to:
  /// **'You\'re offline · showing saved data'**
  String get offlineBannerMessage;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MyHealth'**
  String get homeWelcome;

  /// No description provided for @homePoweredBySmartHealth.
  ///
  /// In en, this message translates to:
  /// **'Powered by SmartHealth'**
  String get homePoweredBySmartHealth;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get navEmergency;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, hospitals, pharmacies'**
  String get homeSearchHint;

  /// No description provided for @homeChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get homeChangeLocation;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @homeNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Nearby providers'**
  String get homeNearbyProviders;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNearbyFacilities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Facilities'**
  String get homeNearbyFacilities;

  /// No description provided for @homeEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency assistance'**
  String get homeEmergencyTitle;

  /// No description provided for @homeEmergencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ambulance • Police • Fire • Rescue'**
  String get homeEmergencySubtitle;

  /// No description provided for @homeCategoryNearMe.
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get homeCategoryNearMe;

  /// No description provided for @homeCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get homeCategoryGeneral;

  /// No description provided for @homeCategoryGeneralPractice.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get homeCategoryGeneralPractice;

  /// No description provided for @homeCategoryPediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatric'**
  String get homeCategoryPediatrics;

  /// No description provided for @homeCategoryDental.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get homeCategoryDental;

  /// No description provided for @homeCategoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get homeCategoryPharmacy;

  /// No description provided for @homeCategoryLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get homeCategoryLaboratory;

  /// No description provided for @homeCategorySpecialists.
  ///
  /// In en, this message translates to:
  /// **'Specialists'**
  String get homeCategorySpecialists;

  /// No description provided for @homeCategoryCardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get homeCategoryCardiology;

  /// No description provided for @homeCategoryMore.
  ///
  /// In en, this message translates to:
  /// **'More >'**
  String get homeCategoryMore;

  /// No description provided for @homeMdpczVerified.
  ///
  /// In en, this message translates to:
  /// **'MDPCZ verified'**
  String get homeMdpczVerified;

  /// No description provided for @homeLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String homeLastUpdated(String time);

  /// No description provided for @homeDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String homeDistanceKm(double distance);

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeRetry;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load facilities'**
  String get homeErrorTitle;

  /// No description provided for @homeNoProviders.
  ///
  /// In en, this message translates to:
  /// **'No facilities match this category nearby.'**
  String get homeNoProviders;

  /// No description provided for @searchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, clinics, conditions…'**
  String get searchInputHint;

  /// No description provided for @searchFilterSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Filter by Specialty'**
  String get searchFilterSpecialty;

  /// No description provided for @searchFilterCondition.
  ///
  /// In en, this message translates to:
  /// **'Filter by Medical Condition'**
  String get searchFilterCondition;

  /// No description provided for @searchFilterAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Patient Age Group'**
  String get searchFilterAgeGroup;

  /// No description provided for @searchApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count} results)'**
  String searchApplyFilters(int count);

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Directory Results'**
  String get searchResultsTitle;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} providers found'**
  String searchResultsCount(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No providers match your search and filters.'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search for a different specialty.'**
  String get searchNoResultsHint;

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust filters'**
  String get searchClearFilters;

  /// No description provided for @searchEmptyAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'No providers available today'**
  String get searchEmptyAvailableToday;

  /// No description provided for @searchEmptyWalkIns.
  ///
  /// In en, this message translates to:
  /// **'No facilities currently accepting walk-ins'**
  String get searchEmptyWalkIns;

  /// No description provided for @searchEmptyQueueHigh.
  ///
  /// In en, this message translates to:
  /// **'Queue times currently high'**
  String get searchEmptyQueueHigh;

  /// No description provided for @searchFilterOperational.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get searchFilterOperational;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchRecentSearches;

  /// No description provided for @searchPopularSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Popular Specialties'**
  String get searchPopularSpecialties;

  /// No description provided for @searchNearbyFacilities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Facilities'**
  String get searchNearbyFacilities;

  /// No description provided for @searchEmergencyShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Shortcuts'**
  String get searchEmergencyShortcuts;

  /// No description provided for @searchEmergencyNearMe.
  ///
  /// In en, this message translates to:
  /// **'Emergency care near me'**
  String get searchEmergencyNearMe;

  /// No description provided for @searchOpenNowShortcut.
  ///
  /// In en, this message translates to:
  /// **'Open now nearby'**
  String get searchOpenNowShortcut;

  /// No description provided for @searchEmergencyHub.
  ///
  /// In en, this message translates to:
  /// **'Emergency hub'**
  String get searchEmergencyHub;

  /// No description provided for @searchMapView.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get searchMapView;

  /// No description provided for @searchOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Offline · searching cached providers'**
  String get searchOfflineHint;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load directory'**
  String get searchErrorTitle;

  /// No description provided for @profileCallNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get profileCallNow;

  /// No description provided for @profileGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get profileGetDirections;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileAboutEmpty.
  ///
  /// In en, this message translates to:
  /// **'No biography available for this provider.'**
  String get profileAboutEmpty;

  /// No description provided for @profileShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get profileShowMore;

  /// No description provided for @profileShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get profileShowLess;

  /// No description provided for @profileServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get profileServices;

  /// No description provided for @profileServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services listed.'**
  String get profileServicesEmpty;

  /// No description provided for @profileWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get profileWorkingHours;

  /// No description provided for @profileClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get profileClosed;

  /// No description provided for @profileBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get profileBookAppointment;

  /// No description provided for @profileBookPhase2.
  ///
  /// In en, this message translates to:
  /// **'Coming in Phase 2'**
  String get profileBookPhase2;

  /// No description provided for @profileMdpczVerified.
  ///
  /// In en, this message translates to:
  /// **'MDPCZ Verified'**
  String get profileMdpczVerified;

  /// No description provided for @profileOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing saved profile'**
  String get profileOfflineHint;

  /// No description provided for @profileNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider not found'**
  String get profileNotFoundTitle;

  /// No description provided for @profileNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a provider with ID \"{id}\".'**
  String profileNotFoundBody(String id);

  /// No description provided for @profileGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get profileGoBack;

  /// No description provided for @profileErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get profileErrorTitle;

  /// No description provided for @profileErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading this profile.'**
  String get profileErrorGeneric;

  /// No description provided for @emergencyWarningBanner.
  ///
  /// In en, this message translates to:
  /// **'For life-threatening emergencies, call 999/994 directly'**
  String get emergencyWarningBanner;

  /// No description provided for @emergencyNearestDistance.
  ///
  /// In en, this message translates to:
  /// **'Nearest · {distance} km'**
  String emergencyNearestDistance(double distance);

  /// No description provided for @emergencyNearbyFacilities.
  ///
  /// In en, this message translates to:
  /// **'Nearby 24hr Emergency Facilities'**
  String get emergencyNearbyFacilities;

  /// No description provided for @emergencyCall.
  ///
  /// In en, this message translates to:
  /// **'CALL'**
  String get emergencyCall;

  /// No description provided for @emergencyDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get emergencyDirections;

  /// No description provided for @emergencyCallNow.
  ///
  /// In en, this message translates to:
  /// **'CALL NOW'**
  String get emergencyCallNow;

  /// No description provided for @emergencyShowDirections.
  ///
  /// In en, this message translates to:
  /// **'Show Directions'**
  String get emergencyShowDirections;

  /// No description provided for @emergencyNearestProvider.
  ///
  /// In en, this message translates to:
  /// **'Nearest provider'**
  String get emergencyNearestProvider;

  /// No description provided for @emergencyOfflineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline · emergency numbers ready'**
  String get emergencyOfflineReady;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingFindDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find trusted doctors near you'**
  String get onboardingFindDoctorsTitle;

  /// No description provided for @onboardingFindDoctorsBody.
  ///
  /// In en, this message translates to:
  /// **'Discover verified providers across Zimbabwe with maps, filters, and offline access.'**
  String get onboardingFindDoctorsBody;

  /// No description provided for @onboardingBookAppointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Book appointments instantly'**
  String get onboardingBookAppointmentsTitle;

  /// No description provided for @onboardingBookAppointmentsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a time, confirm in seconds, and keep every visit organised in one place.'**
  String get onboardingBookAppointmentsBody;

  /// No description provided for @onboardingEmergencyHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency help, one tap away'**
  String get onboardingEmergencyHelpTitle;

  /// No description provided for @onboardingEmergencyHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Reach ambulance, police, fire, and rescue numbers even when you\'re offline.'**
  String get onboardingEmergencyHelpBody;

  /// No description provided for @appointmentsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load appointments'**
  String get appointmentsErrorTitle;

  /// No description provided for @appointmentsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get appointmentsUpcoming;

  /// No description provided for @appointmentsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get appointmentsPast;

  /// No description provided for @appointmentsEmptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments. Book a visit from any provider profile.'**
  String get appointmentsEmptyUpcoming;

  /// No description provided for @appointmentsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentsDetailTitle;

  /// No description provided for @appointmentsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Appointment not found'**
  String get appointmentsNotFound;

  /// No description provided for @appointmentsPatientActions.
  ///
  /// In en, this message translates to:
  /// **'Your actions'**
  String get appointmentsPatientActions;

  /// No description provided for @appointmentsFacilityActions.
  ///
  /// In en, this message translates to:
  /// **'Staff actions'**
  String get appointmentsFacilityActions;

  /// No description provided for @appointmentsCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get appointmentsCheckIn;

  /// No description provided for @appointmentsJoinQueue.
  ///
  /// In en, this message translates to:
  /// **'Join queue'**
  String get appointmentsJoinQueue;

  /// No description provided for @appointmentsViewQueue.
  ///
  /// In en, this message translates to:
  /// **'View queue status'**
  String get appointmentsViewQueue;

  /// No description provided for @appointmentsReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get appointmentsReschedule;

  /// No description provided for @appointmentsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get appointmentsCancel;

  /// No description provided for @appointmentsContactFacility.
  ///
  /// In en, this message translates to:
  /// **'Contact facility'**
  String get appointmentsContactFacility;

  /// No description provided for @appointmentsNoActions.
  ///
  /// In en, this message translates to:
  /// **'No actions available for this appointment.'**
  String get appointmentsNoActions;

  /// No description provided for @appointmentsConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get appointmentsConfirmBooking;

  /// No description provided for @appointmentsMarkArrived.
  ///
  /// In en, this message translates to:
  /// **'Mark arrived'**
  String get appointmentsMarkArrived;

  /// No description provided for @appointmentsMoveToQueue.
  ///
  /// In en, this message translates to:
  /// **'Move to queue'**
  String get appointmentsMoveToQueue;

  /// No description provided for @appointmentsCompleteConsultation.
  ///
  /// In en, this message translates to:
  /// **'Complete consultation'**
  String get appointmentsCompleteConsultation;

  /// No description provided for @appointmentsCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get appointmentsCancelBooking;

  /// No description provided for @appointmentsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get appointmentsCancelConfirm;

  /// No description provided for @appointmentsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep appointment'**
  String get appointmentsKeep;

  /// No description provided for @appointmentsCheckInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm you\'ve arrived at the facility'**
  String get appointmentsCheckInPrompt;

  /// No description provided for @appointmentsAssignQueue.
  ///
  /// In en, this message translates to:
  /// **'Assign to queue'**
  String get appointmentsAssignQueue;

  /// No description provided for @appointmentsAssignQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Join the provider queue after check-in'**
  String get appointmentsAssignQueueHint;

  /// No description provided for @appointmentsConfirmArrival.
  ///
  /// In en, this message translates to:
  /// **'Confirm arrival'**
  String get appointmentsConfirmArrival;

  /// No description provided for @appointmentsSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date to see available times'**
  String get appointmentsSelectDate;

  /// No description provided for @appointmentsConfirmReschedule.
  ///
  /// In en, this message translates to:
  /// **'Confirm new time'**
  String get appointmentsConfirmReschedule;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationsPreferences;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminders, queue updates, and alerts will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get notificationsErrorTitle;

  /// No description provided for @notificationsGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsGroupToday;

  /// No description provided for @notificationsGroupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsGroupYesterday;

  /// No description provided for @notificationsGroupEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsGroupEarlier;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'fr',
    'nd',
    'pt',
    'sn',
    'sw',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nd':
      return AppLocalizationsNd();
    case 'pt':
      return AppLocalizationsPt();
    case 'sn':
      return AppLocalizationsSn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
