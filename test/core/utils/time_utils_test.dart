import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/utils/time_utils.dart';
import 'package:hourly_reminder/l10n/app_localizations_en.dart';

void main() {
  group('TimeUtils.formatDate', () {
    test('formats date as YYYY-MM-DD with zero-padded month and day', () {
      expect(TimeUtils.formatDate(DateTime(2026, 3, 24)), '2026-03-24');
      expect(TimeUtils.formatDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(TimeUtils.formatDate(DateTime(2026, 12, 31)), '2026-12-31');
      expect(TimeUtils.formatDate(DateTime(2026, 1, 1)), '2026-01-01');
    });
  });

  group('TimeUtils.dayName', () {
    final l10n = AppLocalizationsEn();

    test('returns correct day name for each weekday', () {
      expect(TimeUtils.dayName(l10n, 1), 'Mon');
      expect(TimeUtils.dayName(l10n, 5), 'Fri');
      expect(TimeUtils.dayName(l10n, 7), 'Sun');
    });
  });

  group('TimeUtils.formatNextReminder', () {
    final l10n = AppLocalizationsEn();

    test('returns disabled text when next is null', () {
      final result = TimeUtils.formatNextReminder(
        null,
        DateTime(2026, 3, 24, 10, 0),
        l10n,
      );
      expect(result, l10n.remindersDisabled);
    });

    test('returns today format when same day', () {
      final now = DateTime(2026, 3, 24, 10, 0);
      final next = DateTime(2026, 3, 24, 11, 30);
      final result = TimeUtils.formatNextReminder(next, now, l10n);
      expect(result, l10n.nextReminderToday('11:30'));
    });

    test('returns tomorrow format when next day', () {
      final now = DateTime(2026, 3, 24, 18, 0);
      final next = DateTime(2026, 3, 25, 10, 0);
      final result = TimeUtils.formatNextReminder(next, now, l10n);
      expect(result, l10n.nextReminderTomorrow('10:00'));
    });

    test('returns day name format when 2+ days away', () {
      final now = DateTime(2026, 3, 20, 18, 0); // Friday
      final next = DateTime(2026, 3, 23, 10, 0); // Monday
      final result = TimeUtils.formatNextReminder(next, now, l10n);
      expect(result, l10n.nextReminderOnDay('Mon', '10:00'));
    });
  });

  group('TimeUtils.formatDuration', () {
    final l10n = AppLocalizationsEn();

    test('formats seconds for durations under 1 minute', () {
      expect(
        TimeUtils.formatDuration(const Duration(seconds: 45), l10n),
        l10n.durationSeconds(45),
      );
    });

    test('formats minutes for durations under 1 hour', () {
      expect(
        TimeUtils.formatDuration(const Duration(minutes: 30), l10n),
        l10n.durationMinutes(30),
      );
    });

    test('formats hours and minutes', () {
      expect(
        TimeUtils.formatDuration(const Duration(hours: 1, minutes: 15), l10n),
        l10n.durationHoursMinutes(1, 15),
      );
    });

    test('formats exact hours without minutes', () {
      expect(
        TimeUtils.formatDuration(const Duration(hours: 2), l10n),
        l10n.durationHours(2),
      );
    });

    test('zero duration shows 0 seconds', () {
      expect(
        TimeUtils.formatDuration(Duration.zero, l10n),
        l10n.durationSeconds(0),
      );
    });
  });

  group('TimeUtils.formatHourMinute', () {
    test('formats with default minute', () {
      expect(TimeUtils.formatHourMinute(9), '9:00');
      expect(TimeUtils.formatHourMinute(0), '0:00');
      expect(TimeUtils.formatHourMinute(23), '23:00');
    });

    test('formats with explicit minute', () {
      expect(TimeUtils.formatHourMinute(9, 30), '9:30');
      expect(TimeUtils.formatHourMinute(18, 45), '18:45');
      expect(TimeUtils.formatHourMinute(0, 5), '0:05');
    });

    test('pads single-digit minutes', () {
      expect(TimeUtils.formatHourMinute(12, 0), '12:00');
      expect(TimeUtils.formatHourMinute(12, 1), '12:01');
      expect(TimeUtils.formatHourMinute(12, 9), '12:09');
    });

    test('edge cases', () {
      expect(TimeUtils.formatHourMinute(23, 59), '23:59');
      expect(TimeUtils.formatHourMinute(0, 0), '0:00');
    });
  });
}
