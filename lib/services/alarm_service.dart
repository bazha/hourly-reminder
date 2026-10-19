import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AlarmService {
  static const _channel = MethodChannel('com.bazhanau.hourly_reminder/alarm');

  Future<void> scheduleHourlyAlarm() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('scheduleHourlyAlarm');
  }

  Future<void> cancelAlarm() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('cancelAlarm');
  }

  /// Returns the DateTime of the next notification, or null when disabled.
  /// Pure calculation - does not schedule anything.
  static DateTime? nextNotificationTime({
    required DateTime now,
    required bool isEnabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required Set<int> workDays,
    int intervalMinutes = 60,
  }) {
    if (!isEnabled) return null;

    final nowMin = now.hour * 60 + now.minute;
    final startMin = startHour * 60 + startMinute;
    final endMin = endHour * 60 + endMinute;

    // First notification of the day fires at workStart + interval.
    final firstMin = startMin + intervalMinutes;

    if (workDays.contains(now.weekday)) {
      if (nowMin < startMin) {
        if (firstMin <= endMin) {
          return DateTime(now.year, now.month, now.day)
              .add(Duration(minutes: firstMin));
        }
        // Interval exceeds work window - no notification fits today.
      } else if (nowMin < firstMin && firstMin <= endMin) {
        return DateTime(now.year, now.month, now.day)
            .add(Duration(minutes: firstMin));
      } else if (nowMin <= endMin) {
        final nextMin = nowMin + intervalMinutes;
        if (nextMin <= endMin) {
          return DateTime(now.year, now.month, now.day)
              .add(Duration(minutes: nextMin));
        }
      }
    }

    // Walk forward day by day until we find a valid work day where
    // the first notification fits within the work window.
    var candidate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    for (var i = 0; i < 8; i++) {
      if (workDays.contains(candidate.weekday)) {
        if (firstMin <= endMin) {
          return DateTime(candidate.year, candidate.month, candidate.day)
              .add(Duration(minutes: firstMin));
        }
      }
      candidate = candidate.add(const Duration(days: 1));
    }

    // No valid notification time found (interval exceeds work window).
    return null;
  }
}
