import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'dart:io' show Platform;

class AlarmService {
  static const int alarmId = 0;

  // Callback for the alarm — MUST be a top-level or static function.
  @pragma('vm:entry-point')
  static Future<void> alarmCallback() async {
    if (!Platform.isAndroid) return;

    // When the alarm fires in a background isolate (app not running), Flutter
    // bindings and services need to be initialised here before use.
    WidgetsFlutterBinding.ensureInitialized();
    if (!StorageService.isInitialized) {
      await StorageService.initialize();
    }

    final now = DateTime.now();

    if (!shouldSendReminder(
      now:             now,
      isEnabled:       StorageService.isEnabled,
      startHour:       StorageService.startHour,
      startMinute:     StorageService.startMinute,
      endHour:         StorageService.endHour,
      endMinute:       StorageService.endMinute,
      workOnSaturday:  StorageService.workOnSaturday,
      workOnSunday:    StorageService.workOnSunday,
    )) return;

    // Deduplication: Android may batch stale alarms after the device wakes
    // from Doze/lock, firing several callbacks in rapid succession.  Only
    // send one notification per calendar hour.
    final lastNotified = StorageService.lastNotifiedAt;
    if (lastNotified != null &&
        lastNotified.year  == now.year  &&
        lastNotified.month == now.month &&
        lastNotified.day   == now.day   &&
        lastNotified.hour  == now.hour) return;

    await StorageService.recordNotificationSent(now);
    await NotificationService.initialize();
    await NotificationService.showHourlyNotification();
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

  static Future<void> scheduleHourlyAlarm() async {
    if (!Platform.isAndroid) {
      print('AlarmManager is Android-only');
      return;
    }

    await AndroidAlarmManager.cancel(alarmId);

    final success = await AndroidAlarmManager.periodic(
      const Duration(hours: 1),
      alarmId,
      alarmCallback,
      startAt: _getNextHourStart(),
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    print(success ? '✓ Alarm scheduled' : '✗ Alarm scheduling failed');
  }

  static Future<void> cancelAlarm() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.cancel(alarmId);
    print('Alarm cancelled');
  }

  static DateTime _getNextHourStart() {
    final now = DateTime.now();
    // Use Duration arithmetic to avoid a RangeError at 23:xx (hour+1 == 24).
    return DateTime(now.year, now.month, now.day, now.hour, 0, 0)
        .add(const Duration(hours: 1));
  }
}
