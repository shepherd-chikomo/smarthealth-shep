import 'package:smarthealth_shep/shared/models/provider_model.dart';

/// Derives two-letter initials from a provider name.
String providerInitials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (word.isEmpty) return '?';
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.toUpperCase();
  }
  final first = parts.first[0];
  final second = parts[1][0];
  return '$first$second'.toUpperCase();
}

extension ProviderLaunchX on ProviderModel {
  String? get mapsQuery {
    if (latitude != null && longitude != null) {
      return '$latitude,$longitude';
    }
    return address;
  }
}
