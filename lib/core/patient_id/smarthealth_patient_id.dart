import 'dart:math';

/// Immutable SmartHealth Patient Identifier — `SHP-ZW-XXXXXXXXXX`.
abstract final class SmartHealthPatientId {
  static const prefix = 'SHP-ZW-';
  static final _pattern = RegExp(r'^SHP-ZW-\d{10}$');

  static String generate() {
    final random = Random.secure();
    final digits = List.generate(10, (_) => random.nextInt(10)).join();
    return '$prefix$digits';
  }

  static bool isValid(String? value) {
    if (value == null || value.isEmpty) return false;
    return _pattern.hasMatch(value.trim().toUpperCase());
  }

  static String format(String? raw) {
    if (raw == null || raw.isEmpty) return '${prefix}0000000000';
    final trimmed = raw.trim().toUpperCase();
    if (_pattern.hasMatch(trimmed)) return trimmed;
    if (trimmed.startsWith(prefix)) return trimmed;
    return trimmed;
  }
}
