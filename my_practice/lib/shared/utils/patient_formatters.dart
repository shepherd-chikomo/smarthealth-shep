import 'package:my_practice/data/local/app_database.dart';

abstract final class PatientFormatters {
  static String fullName(Patient p) => '${p.firstName} ${p.lastName}'.trim();

  static String initials(Patient p) {
    final f = p.firstName.isNotEmpty ? p.firstName[0] : '';
    final l = p.lastName.isNotEmpty ? p.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  static String initialsFromName(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }

  static int? age(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  static String ageSex(Patient p) {
    final a = age(p.dateOfBirth);
    final g = p.gender?.isNotEmpty == true
        ? p.gender![0].toUpperCase()
        : '?';
    return a != null ? '${a}$g' : g;
  }

  static String insurerLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'Self-pay';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String formatRelativeArrival(DateTime arrived) {
    final diff = DateTime.now().difference(arrived);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return formatTime(arrived);
  }
}

class QueueEntryWithPatient {
  const QueueEntryWithPatient({required this.entry, this.patient});

  final QueueEntry entry;
  final Patient? patient;
}
