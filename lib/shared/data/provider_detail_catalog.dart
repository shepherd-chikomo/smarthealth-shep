import 'package:smarthealth_shep/shared/data/mock_working_hours.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/working_hours_entry.dart';

/// Profile enrichment data merged onto cached/API provider records.
abstract final class ProviderDetailCatalog {
  static ProviderModel enrich(ProviderModel base) {
    final detail = _details[base.id];
    return base.copyWith(
      mdpczNumber: detail?.mdpczNumber ?? base.mdpczNumber,
      about: detail?.about ?? _defaultAbout(base),
      services: detail?.services ?? _defaultServices(base),
      weeklyHours: detail?.weeklyHours ?? MockWorkingHours.standardWeek,
      heroImageUrl: base.heroImageUrl ?? base.imageUrl,
      isVerified: detail?.isVerified ?? base.isVerified,
    );
  }

  static String _defaultAbout(ProviderModel p) =>
      '${p.name} provides ${p.specialty ?? 'healthcare'} services at '
      '${p.facilityName ?? 'their clinic'} in Zimbabwe.';

  static List<String> _defaultServices(ProviderModel p) => [
        'General consultations',
        if (p.specialty != null) '${p.specialty} care',
        'Referrals to specialists',
        'Patient follow-up',
      ];
}

class _ProviderDetailExtra {
  const _ProviderDetailExtra({
    this.mdpczNumber,
    this.about,
    this.services,
    this.weeklyHours,
    this.isVerified,
  });

  final String? mdpczNumber;
  final String? about;
  final List<String>? services;
  final List<WorkingHoursEntry>? weeklyHours;
  final bool? isVerified;
}

const _details = <String, _ProviderDetailExtra>{
  'p1': _ProviderDetailExtra(
    mdpczNumber: 'MDPCZ-GP-20184',
    about:
        'Dr. Tafadzwa Moyo is a senior general practitioner with over 12 years '
        'of experience serving patients at Parirenyatwa Hospital. She focuses '
        'on chronic disease management, preventive care, and community health '
        'outreach across Harare.',
    services: [
      'General consultations',
      'Chronic disease management',
      'Health screenings',
      'Immunisations',
      'Minor procedures',
    ],
    isVerified: true,
  ),
  'p2': _ProviderDetailExtra(
    mdpczNumber: 'MDPCZ-PD-10452',
    about:
        'Dr. Rudo Chikwanha specialises in paediatric care for infants through '
        'adolescents. She is known for compassionate child-friendly consultations '
        'and works closely with families at Avenues Clinic.',
    services: [
      'Well-child visits',
      'Vaccinations',
      'Growth monitoring',
      'Asthma management',
      'Adolescent health',
    ],
    isVerified: true,
  ),
  'p3': _ProviderDetailExtra(
    mdpczNumber: 'MDPCZ-DN-08731',
    about:
        'Dr. Blessing Ndlovu offers comprehensive dental services including '
        'preventive care, restorative treatments, and oral health education.',
    services: [
      'Dental check-ups',
      'Fillings & extractions',
      'Teeth cleaning',
      'Emergency dental care',
    ],
    weeklyHours: [
      WorkingHoursEntry(day: 'Monday', hours: '9:00 AM – 6:00 PM'),
      WorkingHoursEntry(day: 'Tuesday', hours: '9:00 AM – 6:00 PM'),
      WorkingHoursEntry(day: 'Wednesday', hours: '9:00 AM – 6:00 PM'),
      WorkingHoursEntry(day: 'Thursday', hours: '9:00 AM – 6:00 PM'),
      WorkingHoursEntry(day: 'Friday', hours: '9:00 AM – 6:00 PM'),
      WorkingHoursEntry(day: 'Saturday', hours: '9:00 AM – 2:00 PM'),
      WorkingHoursEntry(day: 'Sunday', isClosed: true),
    ],
  ),
  'p4': _ProviderDetailExtra(
    mdpczNumber: 'MDPCZ-CV-05621',
    about:
        'Dr. Nyasha Mutasa is a cardiologist providing diagnostic testing, '
        'hypertension management, and heart disease prevention at HeartCare Zimbabwe.',
    services: [
      'ECG & cardiac screening',
      'Hypertension clinic',
      'Heart disease management',
      'Lifestyle counselling',
    ],
    isVerified: true,
  ),
  'p5': _ProviderDetailExtra(
    mdpczNumber: 'MDPCZ-OB-03118',
    about:
        'Dr. Chipo Dube leads obstetric services at Parirenyatwa Maternity Wing, '
        'supporting antenatal, delivery, and postnatal care.',
    services: [
      'Antenatal care',
      'Ultrasound referrals',
      'Delivery services',
      'Postnatal follow-up',
    ],
    weeklyHours: [
      WorkingHoursEntry(day: 'Monday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Tuesday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Wednesday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Thursday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Friday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Saturday', hours: 'Open 24 hours'),
      WorkingHoursEntry(day: 'Sunday', hours: 'Open 24 hours'),
    ],
    isVerified: true,
  ),
};
