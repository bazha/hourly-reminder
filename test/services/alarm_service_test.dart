import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/services/alarm_service.dart';

const _defaultWorkDays = {1, 2, 3, 4, 5};

// Monday 2026-02-16
final DateTime mon06am = DateTime(2026, 2, 16, 6, 0);
final DateTime mon10am = DateTime(2026, 2, 16, 10, 0);
final DateTime mon19pm = DateTime(2026, 2, 16, 19, 0);

void main() {
  DateTime? nextNotif({
    required DateTime now,
    bool isEnabled = true,
    int startHour = 9,
    int startMinute = 0,
    int endHour = 18,
    int endMinute = 0,
    Set<int> workDays = _defaultWorkDays,
  }) =>
      AlarmService.nextNotificationTime(
        now: now,
        isEnabled: isEnabled,
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
        workDays: workDays,
      );

  group('nextNotificationTime', () {
    test('returns null when disabled', () {
      expect(nextNotif(now: mon10am, isEnabled: false), isNull);
    });

    test('returns now + interval when inside work window past settling', () {
      final now = DateTime(2026, 2, 16, 10, 30, 15);
      // Default 60 min interval: 10:30 + 60 = 11:30
      expect(nextNotif(now: now), DateTime(2026, 2, 16, 11, 30));
    });

    test('returns start + interval when before work window', () {
      // Default 60 min interval: 9:00 + 60 = 10:00
      expect(nextNotif(now: mon06am), DateTime(2026, 2, 16, 10, 0));
    });

    test('returns start + interval when at exact start time (settling)', () {
      expect(nextNotif(now: DateTime(2026, 2, 16, 9, 0, 0)),
          DateTime(2026, 2, 16, 10, 0));
    });

    test('returns next day start + interval when past end of window', () {
      expect(nextNotif(now: mon19pm), DateTime(2026, 2, 17, 10, 0));
    });

    test('skips weekend days correctly', () {
      final fri19 = DateTime(2026, 2, 20, 19, 0);
      expect(fri19.weekday, 5);
      // Both off -> Monday
      expect(nextNotif(now: fri19), DateTime(2026, 2, 23, 10, 0));
      // Saturday on
      expect(nextNotif(now: fri19, workDays: {1, 2, 3, 4, 5, 6}),
          DateTime(2026, 2, 21, 10, 0));
      // Only Sunday on
      expect(nextNotif(now: fri19, workDays: {1, 2, 3, 4, 5, 7}),
          DateTime(2026, 2, 22, 10, 0));
    });

    test('stays on current day when past settling on valid weekend day', () {
      final sat1030 = DateTime(2026, 2, 21, 10, 30);
      // 10:30 + 60 = 11:30
      expect(nextNotif(now: sat1030, workDays: {1, 2, 3, 4, 5, 6}),
          DateTime(2026, 2, 21, 11, 30));
    });

    test('respects custom start minute with interval delay', () {
      // startMinute=30, default interval 60: first notif at 9:30+60 = 10:30
      expect(
        nextNotif(now: DateTime(2026, 2, 16, 9, 0), startMinute: 30),
        DateTime(2026, 2, 16, 10, 30),
      );
    });

    test('wraps to next day when interval exceeds end of window', () {
      // 17:30 + 60 = 18:30 > endMin(18:00), next day: 9:00 + 60 = 10:00
      expect(nextNotif(now: DateTime(2026, 2, 16, 17, 30)),
          DateTime(2026, 2, 17, 10, 0));
    });

    test('custom interval fits more notifications before end of window', () {
      final now = DateTime(2026, 2, 16, 17, 30, 0);
      // 30 min interval: 17:30 + 30 = 18:00 <= endMin, fits
      expect(
        AlarmService.nextNotificationTime(
          now: now,
          isEnabled: true,
          startHour: 9,
          startMinute: 0,
          endHour: 18,
          endMinute: 0,
          workDays: {1, 2, 3, 4, 5},
          intervalMinutes: 30,
        ),
        DateTime(2026, 2, 16, 18, 0),
      );
    });

    test('120 min interval wraps to next day from mid-afternoon', () {
      final now = DateTime(2026, 2, 16, 17, 0, 1);
      // 120 min: 17:00 + 120 = 19:00 > 18:00, wraps
      expect(
        AlarmService.nextNotificationTime(
          now: now,
          isEnabled: true,
          startHour: 9,
          startMinute: 0,
          endHour: 18,
          endMinute: 0,
          workDays: {1, 2, 3, 4, 5},
          intervalMinutes: 120,
        ),
        DateTime(2026, 2, 17, 11, 0),
      );
    });

    test('returns null when no work days are configured', () {
      expect(nextNotif(now: mon10am, workDays: {}), isNull);
    });

    // These only fail in a time zone with DST (run with TZ=Europe/Berlin).
    test('keeps wall-clock time on DST switch days', () {
      const everyDay = {1, 2, 3, 4, 5, 6, 7};
      for (final day in [DateTime(2026, 3, 29), DateTime(2026, 10, 25)]) {
        expect(
          nextNotif(now: day.copyWith(hour: 7), workDays: everyDay),
          day.copyWith(hour: 10),
        );
        expect(
          nextNotif(
              now: day.copyWith(hour: 10, minute: 30), workDays: everyDay),
          day.copyWith(hour: 11, minute: 30),
        );
      }
    });
  });

  List<DateTime> upcoming({
    required DateTime now,
    int intervalMinutes = 60,
    Set<int> workDays = _defaultWorkDays,
    String? dayOffDate,
    Duration? firstDelay,
    DateTime? anchor,
    int limit = 60,
  }) =>
      AlarmService.upcomingNotificationTimes(
        now: now,
        startHour: 9,
        startMinute: 0,
        endHour: 18,
        endMinute: 0,
        workDays: workDays,
        intervalMinutes: intervalMinutes,
        dayOffDate: dayOffDate,
        firstDelay: firstDelay,
        anchor: anchor,
        limit: limit,
      );

  group('upcomingNotificationTimes', () {
    test('fills the work day from start + interval to end of window', () {
      expect(upcoming(now: mon06am, limit: 9), [
        for (var hour = 10; hour <= 18; hour++) DateTime(2026, 2, 16, hour),
      ]);
    });

    test('skips non-work days', () {
      final fri17 = DateTime(2026, 2, 20, 17, 0);
      expect(upcoming(now: fri17, limit: 2),
          [DateTime(2026, 2, 20, 18, 0), DateTime(2026, 2, 23, 10, 0)]);
    });

    test('skips the day-off date', () {
      expect(upcoming(now: mon06am, dayOffDate: '2026-02-16', limit: 1),
          [DateTime(2026, 2, 17, 10, 0)]);
    });

    test('never returns more than limit', () {
      expect(upcoming(now: mon06am, intervalMinutes: 15), hasLength(60));
    });

    test('returns one time past the iOS queue for the paused notice', () {
      expect(upcoming(now: mon06am, intervalMinutes: 15, limit: 61),
          hasLength(61));
    });

    test('first delay inside work window becomes the first time', () {
      final now = DateTime(2026, 2, 16, 10, 5);
      expect(
        upcoming(now: now, firstDelay: const Duration(minutes: 30), limit: 3),
        [
          DateTime(2026, 2, 16, 10, 35),
          DateTime(2026, 2, 16, 11, 35),
          DateTime(2026, 2, 16, 12, 35),
        ],
      );
    });

    test('first delay past end of window falls back to regular series', () {
      final now = DateTime(2026, 2, 16, 17, 50);
      expect(
        upcoming(now: now, firstDelay: const Duration(minutes: 30), limit: 1),
        [DateTime(2026, 2, 17, 10, 0)],
      );
    });

    test('anchor keeps the series unchanged on refill', () {
      final original = upcoming(now: DateTime(2026, 2, 16, 10, 30, 15));
      final resumedAt = DateTime(2026, 2, 16, 11, 0);
      expect(upcoming(now: resumedAt, anchor: original.first), original);
    });

    test('anchor is dropped when an earlier work day becomes available', () {
      final fri19 = DateTime(2026, 2, 20, 19, 0);
      final mondayAnchor = DateTime(2026, 2, 23, 10, 0);
      expect(
        upcoming(
          now: fri19,
          workDays: {1, 2, 3, 4, 5, 6},
          anchor: mondayAnchor,
          limit: 1,
        ),
        [DateTime(2026, 2, 21, 10, 0)],
      );
    });

    test('anchor on a day that is no longer a work day is dropped', () {
      final tuesdayAnchor = DateTime(2026, 2, 17, 10, 0);
      expect(
        upcoming(
          now: mon19pm,
          workDays: {1, 3, 4, 5},
          anchor: tuesdayAnchor,
          limit: 1,
        ),
        [DateTime(2026, 2, 18, 10, 0)],
      );
    });

    test('keeps wall-clock times through a DST switch', () {
      // Fri 2026-03-27 .. Mon 2026-03-30, spring forward on Sunday.
      expect(
        upcoming(
          now: DateTime(2026, 3, 27, 6),
          workDays: {1, 2, 3, 4, 5, 6, 7},
          limit: 36,
        ),
        [
          for (var day = 27; day <= 30; day++)
            for (var hour = 10; hour <= 18; hour++)
              DateTime(2026, 3, day, hour),
        ],
      );
    });
  });
}
