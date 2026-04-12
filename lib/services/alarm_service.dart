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

    bool isDayValid(int weekday) => workDays.contains(weekday);

    // First notification of the day fires at workStart + interval.
    final firstMin = startMin + intervalMinutes;

    if (isDayValid(now.weekday)) {
      if (nowMin < startMin) {
        if (firstMin <= endMin) {
          return DateTime(now.year, now.month, now.day)
              .add(Duration(minutes: firstMin));
        }
        return DateTime(now.year, now.month, now.day, startHour, startMinute);
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

    // Walk forward day by day until we find a valid work day.
    var candidate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    while (true) {
      if (isDayValid(candidate.weekday)) {
        final candidateFirstMin = startMin + intervalMinutes;
        if (candidateFirstMin <= endMin) {
          return DateTime(candidate.year, candidate.month, candidate.day)
              .add(Duration(minutes: candidateFirstMin));
        }
        return DateTime(candidate.year, candidate.month, candidate.day,
            startHour, startMinute);
      }
      candidate = candidate.add(const Duration(days: 1));
    }
  }
}
