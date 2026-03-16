/// Utility helpers for converting between double time values and display strings.
///
/// Work hours are stored as integer hours + minutes (e.g. 9:30, 18:45).
/// Clock widget callbacks pass doubles (9.5 = 9:30).
class TimeUtils {
  TimeUtils._();

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
}
