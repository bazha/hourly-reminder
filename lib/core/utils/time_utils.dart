import '../../l10n/app_localizations.dart';

/// Utility helpers for converting between double time values and display strings.
///
/// Work hours are stored as integer hours + minutes (e.g. 9:30, 18:45).
/// Clock widget callbacks pass doubles (9.5 = 9:30).
class TimeUtils {
  TimeUtils._();

  /// Formats a double time value as `H:MM`.
  ///
  /// Examples: `9.0 -> '9:00'`, `9.5 -> '9:30'`, `18.75 -> '18:45'`
  static String formatTime(double time) {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();
    return formatHourMinute(hour, minute);
  }

  /// Formats hour and minute as `H:MM`.
  static String formatHourMinute(int hour, [int minute = 0]) =>
      '$hour:${minute.toString().padLeft(2, '0')}';

  /// Returns localized short day name for the given weekday (1=Mon, 7=Sun).
  static String dayName(AppLocalizations l10n, int weekday) {
    final names = [
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
      l10n.daySun,
    ];
    return names[weekday - 1];
  }

  /// Formats the next reminder time as a localized string relative to [now].
  static String formatNextReminder(
    DateTime? next,
    DateTime now,
    AppLocalizations l10n,
  ) {
    if (next == null) return l10n.remindersDisabled;

    final nowDate = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(next.year, next.month, next.day);
    final dayDiff = nextDate.difference(nowDate).inDays;
    final time = formatHourMinute(next.hour, next.minute);

    if (dayDiff == 0) return l10n.nextReminderToday(time);
    if (dayDiff == 1) return l10n.nextReminderTomorrow(time);

    final day = dayName(l10n, next.weekday);
    return l10n.nextReminderOnDay(day, time);
  }

  /// Returns a date as `YYYY-MM-DD` string.
  static String formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Formats a [Duration] as a compact localized string.
  static String formatDuration(Duration d, AppLocalizations l10n) {
    if (d.inMinutes < 1) return l10n.durationSeconds(d.inSeconds);
    if (d.inHours < 1) return l10n.durationMinutes(d.inMinutes);
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return minutes > 0
        ? l10n.durationHoursMinutes(hours, minutes)
        : l10n.durationHours(hours);
  }

}
