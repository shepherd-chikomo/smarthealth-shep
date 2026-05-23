// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'SmartHealth';

  @override
  String get offlineBannerMessage => 'Está offline · a mostrar dados guardados';

  @override
  String get homeWelcome => 'Bem-vindo ao SmartHealth';

  @override
  String get splashLoading => 'A carregar…';

  @override
  String get navHome => 'Início';

  @override
  String get navSearch => 'Pesquisar';

  @override
  String get navEmergency => 'Emergência';

  @override
  String get navProfile => 'Perfil';
}
