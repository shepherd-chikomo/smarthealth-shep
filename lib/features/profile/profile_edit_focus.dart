/// Maps profile completion checklist ids to edit form scroll targets.
abstract final class ProfileEditFocus {
  static const bloodGroup = 'blood_group';
  static const allergies = 'allergies';
  static const conditions = 'conditions';
  static const emergencyContact = 'emergency_contact';
  static const medicalAid = 'medical_aid';
  static const medications = 'medications';
  static const primaryProvider = 'primary_provider';
  static const name = 'name';
  static const dob = 'dob';
  static const gender = 'gender';

  static bool isEditable(String itemId) => switch (itemId) {
        bloodGroup ||
        allergies ||
        conditions ||
        emergencyContact ||
        medicalAid ||
        medications ||
        primaryProvider ||
        name ||
        dob ||
        gender =>
          true,
        _ => false,
      };
}
