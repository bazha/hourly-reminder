import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/services/alarm_service.dart';

// Helper that calls shouldSendReminder with the common defaults and lets each
// test override only the relevant parameter.
// Default: weekdays only (both weekend days off).
bool shouldSend({
  required DateTime now,
  bool isEnabled = true,
  int startHour = 9,
  int startMinute = 0,
  int endHour = 18,
  int endMinute = 0,
  bool workOnSaturday = false,
  bool workOnSunday = false,
}) =>
    AlarmService.shouldSendReminder(
      now: now,
      isEnabled: isEnabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      workOnSaturday: workOnSaturday,
      workOnSunday: workOnSunday,
    );

// Fixed reference dates for deterministic tests.
// Monday 2026-02-16 at various hours.
final DateTime mon10am = DateTime(2026, 2, 16, 10, 0);  // weekday == 1
final DateTime mon09am = DateTime(2026, 2, 16, 9, 0);
final DateTime mon06am = DateTime(2026, 2, 16, 6, 0);
final DateTime mon18pm = DateTime(2026, 2, 16, 18, 0);
final DateTime mon19pm = DateTime(2026, 2, 16, 19, 0);

// Saturday 2026-02-21
final DateTime sat10am = DateTime(2026, 2, 21, 10, 0);  // weekday == 6
// Sunday 2026-02-22
final DateTime sun10am = DateTime(2026, 2, 22, 10, 0);  // weekday == 7

void main() {
  group('AlarmService.shouldSendReminder — core hourly reminder logic', () {
    group('when reminders are disabled', () {
      test('returns false regardless of hour', () {
        expect(shouldSend(now: mon10am, isEnabled: false), isFalse);
      });

      test('returns false even inside work hours', () {
        expect(
          shouldSend(now: mon10am, isEnabled: false, startHour: 9, endHour: 18),
          isFalse,
        );
      });
    });

    group('when reminders are enabled', () {
      test('returns true at the start of the work window', () {
        expect(shouldSend(now: mon09am, startHour: 9, endHour: 18), isTrue);
      });

      test('returns true in the middle of the work window', () {
        expect(shouldSend(now: mon10am, startHour: 9, endHour: 18), isTrue);
      });

      test('returns true at the end of the work window', () {
        expect(shouldSend(now: mon18pm, startHour: 9, endHour: 18), isTrue);
      });

      test('returns false one hour before work window starts', () {
        expect(shouldSend(now: mon06am, startHour: 9, endHour: 18), isFalse);
      });

      test('returns false one hour after work window ends', () {
        expect(shouldSend(now: mon19pm, startHour: 9, endHour: 18), isFalse);
      });

      test('returns false at hour < startHour', () {
        final earlyMorning = DateTime(2026, 2, 16, 7, 0);
        expect(shouldSend(now: earlyMorning, startHour: 9, endHour: 18), isFalse);
      });

      test('returns false at hour > endHour', () {
        final lateEvening = DateTime(2026, 2, 16, 22, 0);
        expect(shouldSend(now: lateEvening, startHour: 9, endHour: 18), isFalse);
      });
    });

    group('custom work hours', () {
      test('respects a narrow window (12–13)', () {
        final noon = DateTime(2026, 2, 16, 12, 0);
        final onepm = DateTime(2026, 2, 16, 13, 0);
        final twpm  = DateTime(2026, 2, 16, 14, 0);

        expect(shouldSend(now: noon,  startHour: 12, endHour: 13), isTrue);
        expect(shouldSend(now: onepm, startHour: 12, endHour: 13), isTrue);
        expect(shouldSend(now: twpm,  startHour: 12, endHour: 13), isFalse);
      });

      test('works with early-morning hours (6–8)', () {
        final h6 = DateTime(2026, 2, 16, 6, 0);
        final h9 = DateTime(2026, 2, 16, 9, 0);

        expect(shouldSend(now: h6, startHour: 6, endHour: 8), isTrue);
        expect(shouldSend(now: h9, startHour: 6, endHour: 8), isFalse);
      });
    });

    group('weekend day configuration', () {
      // Both days off (default)
      test('skips Saturday when workOnSaturday is false', () {
        expect(shouldSend(now: sat10am, workOnSaturday: false), isFalse);
      });

      test('skips Sunday when workOnSunday is false', () {
        expect(shouldSend(now: sun10am, workOnSunday: false), isFalse);
      });

      // Saturday on, Sunday off
      test('fires on Saturday when workOnSaturday is true', () {
        expect(shouldSend(now: sat10am, workOnSaturday: true), isTrue);
      });

      test('still skips Sunday when only workOnSaturday is true', () {
        expect(
          shouldSend(now: sun10am, workOnSaturday: true, workOnSunday: false),
          isFalse,
        );
      });

      // Saturday off, Sunday on
      test('fires on Sunday when workOnSunday is true', () {
        expect(shouldSend(now: sun10am, workOnSunday: true), isTrue);
      });

      test('still skips Saturday when only workOnSunday is true', () {
        expect(
          shouldSend(now: sat10am, workOnSaturday: false, workOnSunday: true),
          isFalse,
        );
      });

      // Both days on
      test('fires on Saturday when both weekend days enabled', () {
        expect(
          shouldSend(now: sat10am, workOnSaturday: true, workOnSunday: true),
          isTrue,
        );
      });

      test('fires on Sunday when both weekend days enabled', () {
        expect(
          shouldSend(now: sun10am, workOnSaturday: true, workOnSunday: true),
          isTrue,
        );
      });

      // Weekdays always fire regardless of weekend settings
      test('always fires on weekdays', () {
        expect(shouldSend(now: mon10am), isTrue);
      });
    });

    group('boundary conditions', () {
      test('exactly at startHour fires', () {
        final atStart = DateTime(2026, 2, 16, 9, 30); // still hour == 9
        expect(shouldSend(now: atStart, startHour: 9, endHour: 18), isTrue);
      });

      test('exactly at endHour fires', () {
        final atEnd = DateTime(2026, 2, 16, 18, 0); // exactly at 18:00
        expect(shouldSend(now: atEnd, startHour: 9, endHour: 18), isTrue);
      });

      test('single-hour window fires only for that hour', () {
        final inside  = DateTime(2026, 2, 16, 12, 0);
        final outside = DateTime(2026, 2, 16, 13, 0);

        expect(shouldSend(now: inside,  startHour: 12, endHour: 12), isTrue);
        expect(shouldSend(now: outside, startHour: 12, endHour: 12), isFalse);
      });

      test('Friday is not a weekend', () {
        final friday = DateTime(2026, 2, 20, 10, 0); // weekday == 5
        expect(shouldSend(now: friday), isTrue);
      });
    });

    group('minute-precision boundaries', () {
      test('fires at exactly startHour:startMinute', () {
        final at930 = DateTime(2026, 2, 16, 9, 30);
        expect(shouldSend(now: at930, startHour: 9, startMinute: 30, endHour: 18), isTrue);
      });

      test('does not fire 1 minute before startMinute', () {
        final at929 = DateTime(2026, 2, 16, 9, 29);
        expect(shouldSend(now: at929, startHour: 9, startMinute: 30, endHour: 18), isFalse);
      });

      test('fires at exactly endHour:endMinute', () {
        final at1745 = DateTime(2026, 2, 16, 17, 45);
        expect(shouldSend(now: at1745, startHour: 9, endHour: 17, endMinute: 45), isTrue);
      });

      test('does not fire 1 minute after endMinute', () {
        final at1746 = DateTime(2026, 2, 16, 17, 46);
        expect(shouldSend(now: at1746, startHour: 9, endHour: 17, endMinute: 45), isFalse);
      });

      test('minute-only window works (9:15 – 9:45)', () {
        final at915 = DateTime(2026, 2, 16, 9, 15);
        final at930 = DateTime(2026, 2, 16, 9, 30);
        final at945 = DateTime(2026, 2, 16, 9, 45);
        final at946 = DateTime(2026, 2, 16, 9, 46);
        final at914 = DateTime(2026, 2, 16, 9, 14);

        expect(shouldSend(now: at914, startHour: 9, startMinute: 15, endHour: 9, endMinute: 45), isFalse);
        expect(shouldSend(now: at915, startHour: 9, startMinute: 15, endHour: 9, endMinute: 45), isTrue);
        expect(shouldSend(now: at930, startHour: 9, startMinute: 15, endHour: 9, endMinute: 45), isTrue);
        expect(shouldSend(now: at945, startHour: 9, startMinute: 15, endHour: 9, endMinute: 45), isTrue);
        expect(shouldSend(now: at946, startHour: 9, startMinute: 15, endHour: 9, endMinute: 45), isFalse);
      });

      test('backward compat: zero minutes behaves like hour-only', () {
        expect(shouldSend(now: mon09am, startHour: 9, startMinute: 0, endHour: 18, endMinute: 0), isTrue);
        expect(shouldSend(now: mon06am, startHour: 9, startMinute: 0, endHour: 18, endMinute: 0), isFalse);
      });
    });

    group('regression: midnight roll-over (_getNextHourStart)', () {
      // Before the fix, `now.hour + 1` at 23:xx produced hour=24 which
      // DateTime's raw constructor throws a RangeError for.
      // Now we use Duration arithmetic instead → should never throw.
      test('shouldSendReminder does not throw at 23:30', () {
        final lateNight = DateTime(2026, 2, 16, 23, 30);
        expect(
          () => shouldSend(now: lateNight, startHour: 9, endHour: 23),
          returnsNormally,
        );
      });

      test('does not fire past endHour at 23:30 with default range 9-18', () {
        final lateNight = DateTime(2026, 2, 16, 23, 30);
        expect(shouldSend(now: lateNight, startHour: 9, endHour: 18), isFalse);
      });

      test('fires at 23:xx when endHour includes that hour', () {
        final lateNight = DateTime(2026, 2, 16, 23, 0);
        expect(shouldSend(now: lateNight, startHour: 9, endHour: 23), isTrue);
      });
    });
  });

  group('alarm identifier', () {
    test('alarmId is a non-negative int', () {
      expect(AlarmService.alarmId, isA<int>());
      expect(AlarmService.alarmId, greaterThanOrEqualTo(0));
    });
  });

  // ─── nextNotificationTime ─────────────────────────────────────────────────

  // Default: weekdays only (both weekend days off).
  DateTime? nextNotif({
    required DateTime now,
    bool isEnabled = true,
    int startHour = 9,
    int startMinute = 0,
    int endHour = 18,
    int endMinute = 0,
    bool workOnSaturday = false,
    bool workOnSunday = false,
  }) =>
      AlarmService.nextNotificationTime(
        now: now,
        isEnabled: isEnabled,
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
        workOnSaturday: workOnSaturday,
        workOnSunday: workOnSunday,
      );

  group('nextNotificationTime', () {
    test('returns null when disabled', () {
      expect(nextNotif(now: mon10am, isEnabled: false), isNull);
    });

    test('returns next full hour when inside work window', () {
      // 10:30 on Monday → next is 11:00
      final now = DateTime(2026, 2, 16, 10, 30, 15);
      final result = nextNotif(now: now);
      expect(result, DateTime(2026, 2, 16, 11, 0));
    });

    test('returns start time when before work window', () {
      // 6:00 on Monday → next is 9:00
      expect(nextNotif(now: mon06am), DateTime(2026, 2, 16, 9, 0));
    });

    test('returns next day start when past end of window', () {
      // 19:00 on Monday → next is Tuesday 9:00
      final now = DateTime(2026, 2, 16, 19, 0);
      final result = nextNotif(now: now);
      expect(result, DateTime(2026, 2, 17, 9, 0));
    });

    test('skips both weekend days when both are off (default)', () {
      // Friday 19:00 → should skip Sat+Sun → Monday 9:00
      final fri19 = DateTime(2026, 2, 20, 19, 0); // Friday
      expect(fri19.weekday, 5); // verify it's Friday
      final result = nextNotif(now: fri19);
      expect(result, DateTime(2026, 2, 23, 9, 0)); // Monday
      expect(result!.weekday, 1); // verify Monday
    });

    test('lands on Saturday when workOnSaturday is true', () {
      // Friday 19:00, Saturday enabled → Saturday 9:00
      final fri19 = DateTime(2026, 2, 20, 19, 0);
      final result = nextNotif(now: fri19, workOnSaturday: true);
      expect(result, DateTime(2026, 2, 21, 9, 0)); // Saturday
    });

    test('skips Saturday and lands on Sunday when only workOnSunday is true', () {
      // Friday 19:00, only Sunday enabled → Sunday 9:00
      final fri19 = DateTime(2026, 2, 20, 19, 0);
      final result = nextNotif(now: fri19, workOnSunday: true);
      expect(result, DateTime(2026, 2, 22, 9, 0)); // Sunday
    });

    test('returns current hour if at exact start time', () {
      // Exactly 9:00:00 → should be 9:00
      final result = nextNotif(now: DateTime(2026, 2, 16, 9, 0, 0));
      expect(result, DateTime(2026, 2, 16, 9, 0));
    });

    test('skips to Monday when Saturday is off and now is Saturday', () {
      final sat10 = DateTime(2026, 2, 21, 10, 0);
      expect(sat10.weekday, 6); // Saturday
      final result = nextNotif(now: sat10); // both weekend days off
      expect(result!.weekday, 1); // Monday
    });

    test('stays on Saturday when workOnSaturday is true', () {
      final sat1030 = DateTime(2026, 2, 21, 10, 30);
      final result = nextNotif(now: sat1030, workOnSaturday: true);
      expect(result, DateTime(2026, 2, 21, 11, 0)); // next hour same day
    });

    test('respects custom start minute', () {
      // 9:00 with startHour=9, startMinute=30 → 9:30
      final result = nextNotif(
        now: DateTime(2026, 2, 16, 9, 0),
        startMinute: 30,
      );
      expect(result, DateTime(2026, 2, 16, 9, 30));
    });

    test('returns end of window when near end', () {
      // 17:30 with endHour=18 → 18:00
      final result = nextNotif(now: DateTime(2026, 2, 16, 17, 30));
      expect(result, DateTime(2026, 2, 16, 18, 0));
    });
  });
}
