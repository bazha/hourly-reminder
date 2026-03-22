import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/services/alarm_service.dart';

const _defaultWorkDays = {1, 2, 3, 4, 5};

bool shouldSend({
  required DateTime now,
  bool isEnabled = true,
  int startHour = 9,
  int startMinute = 0,
  int endHour = 18,
  int endMinute = 0,
  Set<int> workDays = _defaultWorkDays,
}) =>
    AlarmService.shouldSendReminder(
      now: now,
      isEnabled: isEnabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      workDays: workDays,
    );

// Monday 2026-02-16
final DateTime mon06am = DateTime(2026, 2, 16, 6, 0);
final DateTime mon09am = DateTime(2026, 2, 16, 9, 0);
final DateTime mon10am = DateTime(2026, 2, 16, 10, 0);
final DateTime mon18pm = DateTime(2026, 2, 16, 18, 0);
final DateTime mon19pm = DateTime(2026, 2, 16, 19, 0);
// Saturday 2026-02-21, Sunday 2026-02-22
final DateTime sat10am = DateTime(2026, 2, 21, 10, 0);
final DateTime sun10am = DateTime(2026, 2, 22, 10, 0);

void main() {
  group('shouldSendReminder', () {
    test('returns false when disabled', () {
      expect(shouldSend(now: mon10am, isEnabled: false), isFalse);
    });

    test('returns true inside work window, false outside', () {
      expect(shouldSend(now: mon06am), isFalse);
      expect(shouldSend(now: mon09am), isTrue);
      expect(shouldSend(now: mon10am), isTrue);
      expect(shouldSend(now: mon18pm), isTrue);
      expect(shouldSend(now: mon19pm), isFalse);
    });

    test('respects custom work hours', () {
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 12, 0), startHour: 12, endHour: 13),
          isTrue);
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 14, 0), startHour: 12, endHour: 13),
          isFalse);
    });

    test('weekend day configuration', () {
      // Both off by default (Mon-Fri only)
      expect(shouldSend(now: sat10am), isFalse);
      expect(shouldSend(now: sun10am), isFalse);
      // Enable individually
      expect(shouldSend(now: sat10am, workDays: {1, 2, 3, 4, 5, 6}), isTrue);
      expect(shouldSend(now: sun10am, workDays: {1, 2, 3, 4, 5, 7}), isTrue);
      // One on doesn't affect the other
      expect(shouldSend(now: sun10am, workDays: {1, 2, 3, 4, 5, 6}), isFalse);
      expect(shouldSend(now: sat10am, workDays: {1, 2, 3, 4, 5, 7}), isFalse);
      // Weekdays always fire
      expect(shouldSend(now: mon10am), isTrue);
    });

    test('individual weekdays can be disabled', () {
      // Disable Monday (weekday 1)
      expect(shouldSend(now: mon10am, workDays: {2, 3, 4, 5}), isFalse);
      // All days enabled
      expect(shouldSend(now: mon10am, workDays: {1, 2, 3, 4, 5, 6, 7}), isTrue);
    });

    test('minute-precision boundaries', () {
      // Exactly at start minute
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 9, 30),
              startHour: 9,
              startMinute: 30,
              endHour: 18),
          isTrue);
      // 1 minute before start
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 9, 29),
              startHour: 9,
              startMinute: 30,
              endHour: 18),
          isFalse);
      // Exactly at end minute
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 17, 45),
              startHour: 9,
              endHour: 17,
              endMinute: 45),
          isTrue);
      // 1 minute after end
      expect(
          shouldSend(
              now: DateTime(2026, 2, 16, 17, 46),
              startHour: 9,
              endHour: 17,
              endMinute: 45),
          isFalse);
    });

    test('does not throw at 23:30', () {
      expect(
        () => shouldSend(
            now: DateTime(2026, 2, 16, 23, 30), startHour: 9, endHour: 23),
        returnsNormally,
      );
    });
  });

  // --- nextNotificationTime ---

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

    test('uses custom interval for next notification', () {
      final now = DateTime(2026, 2, 16, 10, 0, 1);
      // 30 min interval: 10:00 + 30 = 10:30
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
        DateTime(2026, 2, 16, 10, 30),
      );
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
  });
}
