/// Filter option definition for search chips.
class SearchFilterOption {
  const SearchFilterOption({required this.id, required this.label});

  final String id;
  final String label;
}

enum SearchFilterGroup { specialty, condition, ageGroup }

/// Static filter catalog for the search screen.
abstract final class SearchFilterOptions {
  static const specialties = [
    SearchFilterOption(id: 'general_practice', label: 'General Practice'),
    SearchFilterOption(id: 'pediatrics', label: 'Pediatrics'),
    SearchFilterOption(id: 'internal_medicine', label: 'Internal Medicine'),
    SearchFilterOption(id: 'obstetrics', label: 'Obstetrics'),
    SearchFilterOption(id: 'dentistry', label: 'Dentistry'),
    SearchFilterOption(id: 'orthopedics', label: 'Orthopedics'),
    SearchFilterOption(id: 'cardiology', label: 'Cardiology'),
    SearchFilterOption(id: 'dermatology', label: 'Dermatology'),
    SearchFilterOption(id: 'psychiatry', label: 'Psychiatry'),
  ];

  static const conditions = [
    SearchFilterOption(id: 'diabetes', label: 'Diabetes'),
    SearchFilterOption(id: 'hypertension', label: 'Hypertension'),
    SearchFilterOption(id: 'malaria', label: 'Malaria'),
    SearchFilterOption(id: 'hiv_aids', label: 'HIV/AIDS'),
    SearchFilterOption(id: 'pregnancy', label: 'Pregnancy'),
    SearchFilterOption(id: 'asthma', label: 'Asthma'),
    SearchFilterOption(id: 'mental_health', label: 'Mental Health'),
  ];

  static const ageGroups = [
    SearchFilterOption(id: 'infant', label: 'Infant (0-1)'),
    SearchFilterOption(id: 'child', label: 'Child (1-12)'),
    SearchFilterOption(id: 'teen', label: 'Teen (13-17)'),
    SearchFilterOption(id: 'adult', label: 'Adult (18-64)'),
    SearchFilterOption(id: 'senior', label: 'Senior (65+)'),
  ];
}
