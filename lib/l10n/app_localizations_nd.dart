// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for North Ndebele (`nd`).
class AppLocalizationsNd extends AppLocalizations {
  AppLocalizationsNd([String locale = 'nd']) : super(locale);

  @override
  String get appTitle => 'SmartHealth';

  @override
  String get offlineBannerMessage =>
      'Awukho ku-inthanethi · sibonisa idatha egciniwe';

  @override
  String get homeWelcome => 'Wamukelekile ku-SmartHealth';

  @override
  String get splashLoading => 'Iyalayisha…';

  @override
  String get navHome => 'Ekhaya';

  @override
  String get navSearch => 'Sesha';

  @override
  String get navEmergency => 'Isimo esiphuthumayo';

  @override
  String get navProfile => 'Iphrofayili';
}
