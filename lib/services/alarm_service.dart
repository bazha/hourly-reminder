import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/time_utils.dart';
import 'ios_reminder_scheduler.dart';
import 'storage_service.dart';

class AlarmService {
  static const _channel = MethodChannel('com.bazhanau.hourly_reminder/alarm');

  /// Serializes iOS queue rebuilds, so a refill and a reset never interleave.
  static Future<void> _iosQueue = Future.value();

  final IosReminderScheduler _iosScheduler;

  AlarmService({IosReminderScheduler? iosScheduler})
      : _iosScheduler = iosScheduler ?? IosReminderScheduler();

  /// Reschedules reminders starting from now.
  ///
  /// [firstDelay] is the adaptive interval after "I already moved". Used on
  /// iOS only: on Android AlreadyMovedReceiver applies it natively.
  Future<void> scheduleHourlyAlarm({Duration? firstDelay}) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('scheduleHourlyAlarm');
    } else if (Platform.isIOS) {
      await _serializeIos(
          () => _scheduleIos(DateTime.now(), firstDelay: firstDelay));
    }
  }

  Future<void> cancelAlarm() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('cancelAlarm');
    } else if (Platform.isIOS) {
      await _serializeIos(() async {
        await _iosScheduler.cancel();
        await _iosScheduler.cancelSnooze();
      });
    }
  }

  /// iOS: extends the reminder queue without shifting the series, starting
  /// from the earliest pending reminder. Android: no-op, the native alarm
  /// chain reschedules itself.
  ///
  /// Never throws: callers run it fire-and-forget on start and resume.
  Future<void> refillReminders() async {
    if (!Platform.isIOS) return;
    try {
      await _serializeIos(() async {
        final now = DateTime.now();
        final pending = (await _iosScheduler.pendingTimes())
            .where((time) => time.isAfter(now))
            .toList()
          ..sort();
        await _scheduleIos(now, anchor: pending.isEmpty ? null : pending.first);
      });
    } catch (e, stack) {
      debugPrint('Failed to refill reminders: $e\n$stack');
    }
  }

  Future<void> _serializeIos(Future<void> Function() operation) {
    final result = _iosQueue.then((_) => operation());
    _iosQueue = result.catchError((_) {});
    return result;
  }

  Future<void> _scheduleIos(
    DateTime now, {
    Duration? firstDelay,
    DateTime? anchor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // A notification action may have written prefs from the background engine.
    await prefs.reload();
    final storage = StorageService(prefs);
    final userPrefs = storage.loadPreferences();
    if (!userPrefs.isEnabled) {
      await _iosScheduler.cancel();
      await _iosScheduler.cancelSnooze();
      return;
    }
    // A snooze has no check when it fires on iOS, so drop it on a day off.
    if (storage.isDayOff) await _iosScheduler.cancelSnooze();

    await _iosScheduler.schedule(upcomingNotificationTimes(
      now: now,
      startHour: userPrefs.startHour,
      startMinute: userPrefs.startMinute,
      endHour: userPrefs.endHour,
      endMinute: userPrefs.endMinute,
      workDays: userPrefs.workDaySet,
      intervalMinutes: userPrefs.reminderIntervalMinutes,
      dayOffDate: storage.dayOffDate,
      firstDelay: firstDelay,
      anchor: anchor,
    ));
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
          return _atMinute(now, firstMin);
        }
        // Interval exceeds work window - no notification fits today.
      } else if (nowMin < firstMin && firstMin <= endMin) {
        return _atMinute(now, firstMin);
      } else if (nowMin <= endMin) {
        final nextMin = nowMin + intervalMinutes;
        if (nextMin <= endMin) {
          return _atMinute(now, nextMin);
        }
      }
    }

    // Walk forward day by day until we find a valid work day where
    // the first notification fits within the work window.
    for (var i = 1; i <= 8; i++) {
      final candidate = DateTime(now.year, now.month, now.day + i);
      if (workDays.contains(candidate.weekday) && firstMin <= endMin) {
        return _atMinute(candidate, firstMin);
      }
    }

    // No valid notification time found (interval exceeds work window).
    return null;
  }

  /// Returns up to [limit] upcoming notification times, skipping [dayOffDate]
  /// (`YYYY-MM-DD`). Pure calculation - does not schedule anything.
  ///
  /// When [firstDelay] lands inside the work window of a work day, that time
  /// becomes the first one and the series continues from it (mirrors
  /// AlreadyMovedReceiver on Android). Otherwise the regular series is used.
  ///
  /// [anchor] is the earliest pending reminder during a refill. It keeps the
  /// series phase if it is still valid and no earlier day became available.
  static List<DateTime> upcomingNotificationTimes({
    required DateTime now,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required Set<int> workDays,
    int intervalMinutes = 60,
    String? dayOffDate,
    Duration? firstDelay,
    DateTime? anchor,
    int limit = IosReminderScheduler.maxReminders,
  }) {
    DateTime? next(DateTime from) => nextNotificationTime(
          now: from,
          isEnabled: true,
          startHour: startHour,
          startMinute: startMinute,
          endHour: endHour,
          endMinute: endMinute,
          workDays: workDays,
          intervalMinutes: intervalMinutes,
        );
    bool isDayOff(DateTime time) => TimeUtils.formatDate(time) == dayOffDate;

    bool isAllowed(DateTime candidate) {
      final minuteOfDay = candidate.hour * 60 + candidate.minute;
      return minuteOfDay >= startHour * 60 + startMinute &&
          minuteOfDay <= endHour * 60 + endMinute &&
          workDays.contains(candidate.weekday) &&
          !isDayOff(candidate);
    }

    DateTime? time;
    if (firstDelay != null && isAllowed(now.add(firstDelay))) {
      time = now.add(firstDelay);
    }
    if (time == null &&
        anchor != null &&
        anchor.isAfter(now) &&
        isAllowed(anchor)) {
      // Keep the anchor only if no earlier day became available, e.g. a
      // work day switched on between now and the anchor.
      var regular = next(now);
      while (regular != null && isDayOff(regular)) {
        regular = next(regular);
      }
      if (regular != null && !_isLaterDay(anchor, regular)) time = anchor;
    }
    time ??= next(now);

    final times = <DateTime>[];
    while (time != null && times.length < limit) {
      if (!isDayOff(time)) times.add(time);
      time = next(time);
    }
    return times;
  }

  /// Wall-clock time [minuteOfDay] minutes after midnight on [day]'s date.
  /// The DateTime constructor keeps it right on DST switch days, where
  /// midnight + Duration lands an hour off.
  static DateTime _atMinute(DateTime day, int minuteOfDay) =>
      DateTime(day.year, day.month, day.day, 0, minuteOfDay);

  static bool _isLaterDay(DateTime a, DateTime b) =>
      DateTime(a.year, a.month, a.day)
          .isAfter(DateTime(b.year, b.month, b.day));
}
