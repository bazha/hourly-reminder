import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AlarmService {
  static const _channel = MethodChannel('com.bazhanau.hourly_reminder/alarm');

  static Future<void> scheduleHourlyAlarm() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('scheduleHourlyAlarm');
  }

  static Future<void> cancelAlarm() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('cancelAlarm');
  }

  /// Pure function: given a moment in time and user settings, returns true if
  /// a notification should be sent.  No side-effects — easy to unit-test.
  static bool shouldSendReminder({
    required DateTime now,
    required bool isEnabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    if (!isEnabled) return false;
    final day = now.weekday; // 1 = Mon … 7 = Sun
    if (day == 6 && !workOnSaturday) return false;
    if (day == 7 && !workOnSunday)   return false;
    final nowMin   = now.hour * 60 + now.minute;
    final startMin = startHour * 60 + startMinute;
    final endMin   = endHour   * 60 + endMinute;
    return nowMin >= startMin && nowMin <= endMin;
  }

  /// Returns the DateTime of the next notification, or null when disabled.
  /// Pure calculation — does not schedule anything.
  static DateTime? nextNotificationTime({
    required DateTime now,
    required bool isEnabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    if (!isEnabled) return null;

    final nowMin   = now.hour * 60 + now.minute;
    final startMin = startHour * 60 + startMinute;
    final endMin   = endHour   * 60 + endMinute;

    bool _isDayValid(int weekday) =>
        (weekday != 6 && weekday != 7) ||
        (weekday == 6 && workOnSaturday) ||
        (weekday == 7 && workOnSunday);

    if (_isDayValid(now.weekday)) {
      if (nowMin < startMin) {
        // Before today's window — first notification at window open.
        return DateTime(now.year, now.month, now.day, startHour, startMinute);
      } else if (nowMin <= endMin) {
        // Inside today's window.
        if (now.minute == 0 && now.second == 0) {
          // Exactly at the top of an hour — notification fires now.
          return DateTime(now.year, now.month, now.day, now.hour, 0);
        } else {
          // Advance to the next full hour if it is still within the window.
          final nextHour = now.hour + 1;
          if (nextHour * 60 <= endMin) {
            return DateTime(now.year, now.month, now.day, nextHour, 0);
          }
        }
      }
      // Past window for today — fall through to next valid day.
    }

    // Walk forward day by day until we find a valid work day.
    var candidate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    while (true) {
      if (_isDayValid(candidate.weekday)) {
        return DateTime(
            candidate.year, candidate.month, candidate.day, startHour, startMinute);
      }
      candidate = candidate.add(const Duration(days: 1));
    }
  }
}
