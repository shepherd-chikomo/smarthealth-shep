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
  /// **'SmartHealth'**
  String get appTitle;

  /// Persistent banner when device has no connectivity
  ///
  /// In en, this message translates to:
  /// **'You\'re offline · showing saved data'**
  String get offlineBannerMessage;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SmartHealth'**
  String get homeWelcome;

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
  /// **'Search doctors, clinics, hospitals…'**
  String get homeSearchHint;

  /// No description provided for @homeChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get homeChangeLocation;

  /// No description provided for @homeNearbyFacilities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Facilities'**
  String get homeNearbyFacilities;

  /// No description provided for @homeEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Hub'**
  String get homeEmergencyTitle;

  /// No description provided for @homeEmergencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ambulance, police & urgent care numbers'**
  String get homeEmergencySubtitle;

  /// No description provided for @homeCategoryNearMe.
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get homeCategoryNearMe;

  /// No description provided for @homeCategoryGeneralPractice.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get homeCategoryGeneralPractice;

  /// No description provided for @homeCategoryPediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get homeCategoryPediatrics;

  /// No description provided for @homeCategoryDental.
  ///
  /// In en, this message translates to:
  /// **'Dental'**
  String get homeCategoryDental;

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
