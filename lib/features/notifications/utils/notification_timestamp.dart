import 'package:intl/intl.dart';

/// Formats notification timestamps for the inbox.
abstract final class NotificationTimestamp {
  static String format(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && now.day == local.day) {
      return DateFormat.jm().format(local);
    }
    if (diff.inHours < 48 && now.day - local.day <= 1) {
      return 'Yesterday · ${DateFormat.jm().format(local)}';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM · HH:mm').format(local);
  }
}
