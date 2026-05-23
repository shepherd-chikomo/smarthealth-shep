/// Typed asset paths for bundled SmartHealth visuals.
abstract final class AppAssets {
  // Provider portraits & facility heroes
  static const doctorTendai =
      'assets/images/providers/doctor_african.jpg';
  static const doctorRumbidzai =
      'assets/images/providers/doctor_2.jpg';
  static const doctorFarai =
      'assets/images/providers/doctor_1.jpg';
  static const doctorKudzai =
      'assets/images/providers/doctor_3.jpg';
  static const hospitalAvenues =
      'assets/images/providers/hospital_1.jpg';

  // Onboarding illustrations
  static const onboardingFindDoctors =
      'assets/images/onboarding/onboarding_1.jpg';
  static const onboardingBookAppointments =
      'assets/images/onboarding/onboarding_2.jpg';
  static const onboardingEmergencyHelp =
      'assets/images/onboarding/onboarding_3.jpg';

  // App icon & splash
  static const appIcon = 'assets/icon/app_icon.png';
  static const appIconForeground = 'assets/icon/app_icon_foreground.png';
  static const splashLogo = 'assets/icon/splash_logo.png';

  // Placeholders
  static const avatarPlaceholder =
      'assets/images/placeholders/avatar_placeholder.png';
  static const providerPlaceholder =
      'assets/images/placeholders/provider_placeholder.jpg';

  // Category icons
  static const categoryGp = 'assets/icons/categories/gp.svg';
  static const categoryDentist = 'assets/icons/categories/dentist.svg';
  static const categoryPharmacy = 'assets/icons/categories/pharmacy.svg';
  static const categoryLab = 'assets/icons/categories/lab.svg';
  static const categoryPediatric = 'assets/icons/categories/pediatric.svg';
  static const categorySpecialist =
      'assets/icons/categories/specialist.svg';
  static const categoryEmergency =
      'assets/icons/categories/emergency.svg';

  // Emergency service icons
  static const emergencyAmbulance =
      'assets/icons/emergency/ambulance.svg';
  static const emergencyPolice = 'assets/icons/emergency/police.svg';
  static const emergencyFire = 'assets/icons/emergency/fire.svg';
  static const emergencyRescue = 'assets/icons/emergency/rescue.svg';

  // UI icons
  static const verifiedBadge = 'assets/icons/ui/verified_badge.svg';
  static const whatsapp = 'assets/icons/ui/whatsapp.svg';
  static const offlineCloud = 'assets/icons/ui/offline_cloud.svg';
  static const emptyState = 'assets/icons/ui/empty_state.svg';

  /// Portrait for a seeded provider id in mock data.
  static String? providerPortraitFor(String providerId) => switch (providerId) {
        'p1' => doctorTendai,
        'p2' => doctorRumbidzai,
        'p3' => doctorFarai,
        'p4' => doctorKudzai,
        _ => null,
      };

  /// Hero image for facility profile screens.
  static String? providerHeroFor(String providerId) => switch (providerId) {
        'p2' => hospitalAvenues,
        _ => null,
      };

  /// Emergency SVG for a service id.
  static String emergencyIconFor(String serviceId) => switch (serviceId) {
        'ambulance' => emergencyAmbulance,
        'police' => emergencyPolice,
        'fire_rescue' => emergencyFire,
        'rescue_team' => emergencyRescue,
        _ => emergencyAmbulance,
      };
}
