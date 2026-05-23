// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SmartHealth';

  @override
  String get offlineBannerMessage =>
      'Vous êtes hors ligne · données enregistrées affichées';

  @override
  String get homeWelcome => 'Bienvenue sur SmartHealth';

  @override
  String get splashLoading => 'Chargement…';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navEmergency => 'Urgence';

  @override
  String get navProfile => 'Profil';
}
