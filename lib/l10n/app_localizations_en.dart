// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartHealth';

  @override
  String get offlineBannerMessage => 'You\'re offline · showing saved data';

  @override
  String get homeWelcome => 'Welcome to SmartHealth';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navEmergency => 'Emergency';

  @override
  String get navProfile => 'Profile';
}
