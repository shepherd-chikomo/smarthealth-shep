import 'package:smarthealth_shep/shared/models/category_model.dart';
import 'package:smarthealth_shep/shared/models/emergency_service_model.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Seed data for offline-first development and demos.
abstract final class MockData {
  static const categories = <CategoryModel>[
    CategoryModel(id: 'hospital', name: 'Hospitals', iconName: 'local_hospital'),
    CategoryModel(id: 'clinic', name: 'Clinics', iconName: 'medical_services'),
    CategoryModel(id: 'pharmacy', name: 'Pharmacies', iconName: 'vaccines'),
    CategoryModel(
      id: 'ambulance',
      name: 'Ambulance',
      iconName: 'emergency',
    ),
  ];

  static const providers = <ProviderModel>[
    ProviderModel(
      id: 'p1',
      name: 'Parirenyatwa Hospital',
      categoryId: 'hospital',
      address: 'Harare',
      phone: '+263242703831',
      latitude: -17.8252,
      longitude: 31.0335,
      isVerified: true,
    ),
    ProviderModel(
      id: 'p2',
      name: 'Avenues Clinic',
      categoryId: 'clinic',
      address: 'Harare',
      phone: '+263242870111',
      latitude: -17.8194,
      longitude: 31.0522,
      isVerified: true,
    ),
  ];

  static const emergencyServices = <EmergencyServiceModel>[
    EmergencyServiceModel(
      id: 'e1',
      name: 'National Ambulance',
      phone: '994',
      is24Hours: true,
    ),
    EmergencyServiceModel(
      id: 'e2',
      name: 'Police Emergency',
      phone: '999',
      is24Hours: true,
    ),
  ];

  static const familyMembers = <FamilyMemberModel>[
    FamilyMemberModel(
      id: 'f1',
      name: 'Family member',
      relationship: 'Dependent',
    ),
  ];
}
