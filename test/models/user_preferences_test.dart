import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/models/user_preferences.dart';

void main() {
  group('UserPreferences', () {
    group('defaults', () {
      test('has correct default values', () {
        final prefs = UserPreferences();
        expect(prefs.isEnabled, isFalse);
        expect(prefs.startHour, equals(9));
        expect(prefs.endHour, equals(18));
        expect(prefs.workOnSaturday, isFalse);
        expect(prefs.workOnSunday, isFalse);
      });
    });

    group('copyWith', () {
      test('returns same values when no arguments given', () {
        final prefs = UserPreferences(
          isEnabled: true,
          startHour: 8,
          endHour: 17,
          workOnSaturday: true,
          workOnSunday: false,
        );
        final copy = prefs.copyWith();
        expect(copy, equals(prefs));
      });

      test('overrides only isEnabled', () {
        final prefs = UserPreferences(
          isEnabled: false,
          startHour: 9,
          endHour: 18,
          workOnSaturday: false,
          workOnSunday: false,
        );
        final copy = prefs.copyWith(isEnabled: true);
        expect(copy.isEnabled, isTrue);
        expect(copy.startHour, equals(9));
        expect(copy.endHour, equals(18));
        expect(copy.workOnSaturday, isFalse);
        expect(copy.workOnSunday, isFalse);
      });

      test('overrides work hours', () {
        final prefs = UserPreferences();
        final copy = prefs.copyWith(startHour: 10, endHour: 16);
        expect(copy.startHour, equals(10));
        expect(copy.endHour, equals(16));
        expect(copy.isEnabled, isFalse);
        expect(copy.workOnSaturday, isFalse);
        expect(copy.workOnSunday, isFalse);
      });

      test('overrides workOnSaturday independently', () {
        final prefs = UserPreferences(workOnSaturday: false, workOnSunday: false);
        final copy = prefs.copyWith(workOnSaturday: true);
        expect(copy.workOnSaturday, isTrue);
        expect(copy.workOnSunday, isFalse);
      });

      test('overrides workOnSunday independently', () {
        final prefs = UserPreferences(workOnSaturday: false, workOnSunday: false);
        final copy = prefs.copyWith(workOnSunday: true);
        expect(copy.workOnSaturday, isFalse);
        expect(copy.workOnSunday, isTrue);
      });

      test('overrides both weekend days at once', () {
        final prefs = UserPreferences();
        final copy = prefs.copyWith(workOnSaturday: true, workOnSunday: true);
        expect(copy.workOnSaturday, isTrue);
        expect(copy.workOnSunday, isTrue);
      });
    });

    group('time getters', () {
      test('startTime returns startHour as double', () {
        final prefs = UserPreferences(startHour: 9);
        expect(prefs.startTime, equals(9.0));
      });

      test('endTime returns endHour as double', () {
        final prefs = UserPreferences(endHour: 18);
        expect(prefs.endTime, equals(18.0));
      });
    });

    group('equality', () {
      test('two identical instances are equal', () {
        final a = UserPreferences(
          isEnabled: true,
          startHour: 9,
          endHour: 18,
          workOnSaturday: true,
          workOnSunday: false,
        );
        final b = UserPreferences(
          isEnabled: true,
          startHour: 9,
          endHour: 18,
          workOnSaturday: true,
          workOnSunday: false,
        );
        expect(a, equals(b));
      });

      test('different isEnabled are not equal', () {
        final a = UserPreferences(isEnabled: true);
        final b = UserPreferences(isEnabled: false);
        expect(a, isNot(equals(b)));
      });

      test('different startHour are not equal', () {
        final a = UserPreferences(startHour: 8);
        final b = UserPreferences(startHour: 9);
        expect(a, isNot(equals(b)));
      });

      test('different endHour are not equal', () {
        final a = UserPreferences(endHour: 17);
        final b = UserPreferences(endHour: 18);
        expect(a, isNot(equals(b)));
      });

      test('different workOnSaturday are not equal', () {
        final a = UserPreferences(workOnSaturday: true);
        final b = UserPreferences(workOnSaturday: false);
        expect(a, isNot(equals(b)));
      });

      test('different workOnSunday are not equal', () {
        final a = UserPreferences(workOnSunday: true);
        final b = UserPreferences(workOnSunday: false);
        expect(a, isNot(equals(b)));
      });

      test('hashCode is same for equal instances', () {
        final a = UserPreferences(
          isEnabled: true,
          startHour: 9,
          endHour: 18,
          workOnSaturday: true,
          workOnSunday: true,
        );
        final b = UserPreferences(
          isEnabled: true,
          startHour: 9,
          endHour: 18,
          workOnSaturday: true,
          workOnSunday: true,
        );
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('dailyNotificationCount', () {
      test('default window (9–18) gives 10 notifications', () {
        expect(UserPreferences().dailyNotificationCount, equals(10));
      });

      test('narrow window (12–12) gives 1 notification', () {
        expect(
          UserPreferences(startHour: 12, endHour: 12).dailyNotificationCount,
          equals(1),
        );
      });

      test('full day (0–23) gives 24 notifications', () {
        expect(
          UserPreferences(startHour: 0, endHour: 23).dailyNotificationCount,
          equals(24),
        );
      });

      test('custom window (6–14) gives 9 notifications', () {
        expect(
          UserPreferences(startHour: 6, endHour: 14).dailyNotificationCount,
          equals(9),
        );
      });

      test('inverted window (start > end) gives 0 notifications', () {
        expect(
          UserPreferences(startHour: 18, endHour: 9).dailyNotificationCount,
          equals(0),
        );
      });
    });

    group('minute fields', () {
      test('defaults to zero minutes', () {
        final prefs = UserPreferences();
        expect(prefs.startMinute, equals(0));
        expect(prefs.endMinute, equals(0));
      });

      test('copyWith overrides minutes', () {
        final prefs = UserPreferences();
        final copy = prefs.copyWith(startMinute: 30, endMinute: 45);
        expect(copy.startMinute, equals(30));
        expect(copy.endMinute, equals(45));
        expect(copy.startHour, equals(9));
        expect(copy.endHour, equals(18));
      });

      test('startTime includes minutes as fraction', () {
        final prefs = UserPreferences(startHour: 9, startMinute: 30);
        expect(prefs.startTime, equals(9.5));
      });

      test('endTime includes minutes as fraction', () {
        final prefs = UserPreferences(endHour: 17, endMinute: 45);
        expect(prefs.endTime, equals(17.75));
      });

      test('startTotalMinutes computes correctly', () {
        final prefs = UserPreferences(startHour: 9, startMinute: 30);
        expect(prefs.startTotalMinutes, equals(570));
      });

      test('endTotalMinutes computes correctly', () {
        final prefs = UserPreferences(endHour: 17, endMinute: 45);
        expect(prefs.endTotalMinutes, equals(1065));
      });

      test('equality includes minutes', () {
        final a = UserPreferences(startMinute: 15);
        final b = UserPreferences(startMinute: 30);
        expect(a, isNot(equals(b)));
      });

      test('hashCode includes minutes', () {
        final a = UserPreferences(startMinute: 15, endMinute: 45);
        final b = UserPreferences(startMinute: 15, endMinute: 45);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('dailyNotificationCount with minutes window 9:30-17:30', () {
        final prefs = UserPreferences(
          startHour: 9, startMinute: 30,
          endHour: 17, endMinute: 30,
        );
        // 17:30 - 9:30 = 8h → 8/1 + 1 = 9 notifications
        expect(prefs.dailyNotificationCount, equals(9));
      });
    });
  });
}
