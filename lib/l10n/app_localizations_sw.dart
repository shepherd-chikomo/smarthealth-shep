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
  String get navProfile => 'Wasifu';
}
