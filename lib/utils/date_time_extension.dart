import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Example: 02:03 pm 28 July 2026
  String get historyDateTime {
    final time = DateFormat('hh:mm a').format(this).toLowerCase();
    final date = DateFormat('dd MMMM yyyy').format(this);
    return '$time $date';
  }
}

extension StringDateExtension on String {
  String get historyDateTime {
    DateTime parsed;

    try {
      parsed = DateTime.parse(this);
    } catch (_) {
      try {
        parsed = DateFormat('dd-MM-yy').parse(this);
      } catch (_) {
        parsed = DateFormat('dd-MM-yyyy').parse(this);
      }
    }

    return parsed.historyDateTime;
  }
}