import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('d MMM yyyy', 'tr');
  static final _dateTimeFormat = DateFormat('d MMM yyyy HH:mm', 'tr');
  static final _timeFormat = DateFormat('HH:mm', 'tr');

  static String formatDate(DateTime dt) => _dateFormat.format(dt.toLocal());

  static String formatDateTime(DateTime dt) =>
      _dateTimeFormat.format(dt.toLocal());

  static String formatTime(DateTime dt) => _timeFormat.format(dt.toLocal());

  /// Returns a Turkish relative time string like "3 gün önce" or "2 saat önce"
  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());

    if (diff.inDays > 30) return formatDate(dt);
    if (diff.inDays >= 1) return '${diff.inDays} gün önce';
    if (diff.inHours >= 1) return '${diff.inHours} saat önce';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} dakika önce';
    return 'az önce';
  }

  /// Returns "X gün Y saat kaldı" or "X gün önce geçti" countdown string
  static String countdownText(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.toLocal().difference(now);

    if (diff.isNegative) {
      final overdue = now.difference(dueDate.toLocal());
      if (overdue.inDays >= 1) return '${overdue.inDays} gün önce geçti';
      if (overdue.inHours >= 1) return '${overdue.inHours} saat önce geçti';
      return 'Süresi doldu';
    }

    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);

    if (days > 0 && hours > 0) return '$days gün $hours saat kaldı';
    if (days > 0) return '$days gün kaldı';
    if (hours > 0) return '$hours saat kaldı';
    final mins = diff.inMinutes;
    if (mins > 0) return '$mins dakika kaldı';
    return 'Son dakika!';
  }

  /// 0.0 – 1.0 progress from createdAt → dueDate
  static double deadlineProgress(DateTime createdAt, DateTime dueDate) {
    final total = dueDate.difference(createdAt).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
