const _fieldLabels = <String, String>{
  'allergies': 'Allergies',
  'conditions': 'Medical conditions',
  'medications': 'Current medications',
  'bloodGroup': 'Blood group',
  'emergencyContact': 'Emergency contact',
  'medicalAid': 'Medical aid',
};

String disclosureFieldLabel(String key) =>
    _fieldLabels[key] ?? key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();

List<String> formatSharedFieldLabels(List<String> sharedFields) {
  return sharedFields.map(disclosureFieldLabel).toList();
}
