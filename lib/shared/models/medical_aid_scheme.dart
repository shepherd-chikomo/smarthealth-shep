class MedicalAidScheme {
  const MedicalAidScheme({
    required this.schemeKey,
    required this.name,
  });

  final String schemeKey;
  final String name;

  factory MedicalAidScheme.fromJson(Map<String, dynamic> json) {
    return MedicalAidScheme(
      schemeKey: json['schemeKey'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// Bundled schemes when the catalog API is unavailable.
const defaultMedicalAidSchemes = [
  MedicalAidScheme(schemeKey: 'cimas', name: 'Cimas'),
  MedicalAidScheme(schemeKey: 'psmas', name: 'PSMAS'),
  MedicalAidScheme(schemeKey: 'first_mutual', name: 'First Mutual'),
  MedicalAidScheme(schemeKey: 'cellmed', name: 'CellMed'),
  MedicalAidScheme(schemeKey: 'alliance_health', name: 'Alliance Health'),
];
