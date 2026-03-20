/// Utility helpers for converting between double time values and display strings.
///
/// Work hours are stored as integer hours + minutes (e.g. 9:30, 18:45).
/// Clock widget callbacks pass doubles (9.5 = 9:30).
class TimeUtils {
  TimeUtils._();

  static const russianDayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  /// Formats a double time value as `H:MM`.
  ///
  /// Examples: `9.0 → '9:00'`, `9.5 → '9:30'`, `18.75 → '18:45'`
  static String formatTime(double time) {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();
    return formatHourMinute(hour, minute);
  }

  /// Formats hour and minute as `H:MM`.
  static String formatHourMinute(int hour, [int minute = 0]) =>
      '$hour:${minute.toString().padLeft(2, '0')}';

  /// Formats the next reminder time as a Russian string relative to [now].
  ///
  /// Returns a contextual message:
  /// - `null` next → 'Напоминания выключены'
  /// - same day  → 'Следующее в 15:00'
  /// - tomorrow  → 'Следующее завтра в 9:00'
  /// - later     → 'Следующее в Пн в 9:00'
  static String formatNextReminder(DateTime? next, DateTime now) {
    if (next == null) return 'Напоминания выключены';

    final nowDate = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(next.year, next.month, next.day);
    final dayDiff = nextDate.difference(nowDate).inDays;
    final time = formatHourMinute(next.hour, next.minute);

    if (dayDiff == 0) return 'Следующее в $time';
    if (dayDiff == 1) return 'Следующее завтра в $time';

    final dayName = russianDayNames[next.weekday - 1];
    return 'Следующее в $dayName в $time';
  }

  /// Formats a [Duration] as a compact Russian string.
  ///
  /// Examples: `Duration(seconds: 30) → '30с'`,
  /// `Duration(minutes: 45) → '45м'`, `Duration(hours: 2, minutes: 15) → '2ч 15м'`
  static String formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}с';
    if (d.inHours < 1) return '${d.inMinutes}м';
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return minutes > 0 ? '$hoursч $minutesм' : '$hoursч';
  }
}
