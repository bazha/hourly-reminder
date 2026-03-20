import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/models/user_preferences.dart';

void main() {
  group('UserPreferences', () {
    test('has correct defaults', () {
      final prefs = UserPreferences();
      expect(prefs.isEnabled, isFalse);
      expect(prefs.startHour, 9);
      expect(prefs.startMinute, 0);
      expect(prefs.endHour, 18);
      expect(prefs.endMinute, 0);
      expect(prefs.workOnSaturday, isFalse);
      expect(prefs.workOnSunday, isFalse);
      expect(prefs.notificationGender, NotificationGender.neutral);
      expect(prefs.dailyGoal, 8);
      expect(prefs.reminderIntervalMinutes, 60);
    });

    test('copyWith overrides specified fields and preserves others', () {
      final prefs = UserPreferences(
        isEnabled: false,
        startHour: 9,
        endHour: 18,
        workOnSaturday: false,
        workOnSunday: false,
      );

      // No-arg copy is equal
      expect(prefs.copyWith(), equals(prefs));

      // Single field
      final enabled = prefs.copyWith(isEnabled: true);
      expect(enabled.isEnabled, isTrue);
      expect(enabled.startHour, 9);

      // Multiple fields
      final hours = prefs.copyWith(startHour: 10, endHour: 16);
      expect(hours.startHour, 10);
      expect(hours.endHour, 16);

      // Weekend days independently
      final sat = prefs.copyWith(workOnSaturday: true);
      expect(sat.workOnSaturday, isTrue);
      expect(sat.workOnSunday, isFalse);

      // Gender
      final male = prefs.copyWith(notificationGender: NotificationGender.male);
      expect(male.notificationGender, NotificationGender.male);

      // Minutes
      final mins = prefs.copyWith(startMinute: 30, endMinute: 45);
      expect(mins.startMinute, 30);
      expect(mins.endMinute, 45);

      // Daily goal
      final goal = prefs.copyWith(dailyGoal: 12);
      expect(goal.dailyGoal, 12);

      // Interval
      final interval = prefs.copyWith(reminderIntervalMinutes: 30);
      expect(interval.reminderIntervalMinutes, 30);
      expect(interval.startHour, 9);
    });

    test('equality and hashCode include all fields', () {
      final a = UserPreferences(
        isEnabled: true,
        startHour: 9,
        startMinute: 15,
        endHour: 18,
        endMinute: 30,
        workOnSaturday: true,
        workOnSunday: false,
        notificationGender: NotificationGender.female,
        dailyGoal: 10,
        reminderIntervalMinutes: 45,
      );
      final b = UserPreferences(
        isEnabled: true,
        startHour: 9,
        startMinute: 15,
        endHour: 18,
        endMinute: 30,
        workOnSaturday: true,
        workOnSunday: false,
        notificationGender: NotificationGender.female,
        dailyGoal: 10,
        reminderIntervalMinutes: 45,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Changing any single field breaks equality
      expect(a, isNot(equals(a.copyWith(isEnabled: false))));
      expect(a, isNot(equals(a.copyWith(startHour: 8))));
      expect(a, isNot(equals(a.copyWith(endHour: 17))));
      expect(a, isNot(equals(a.copyWith(workOnSaturday: false))));
      expect(a, isNot(equals(a.copyWith(workOnSunday: true))));
      expect(
          a,
          isNot(
              equals(a.copyWith(notificationGender: NotificationGender.male))));
      expect(a, isNot(equals(a.copyWith(startMinute: 0))));
      expect(a, isNot(equals(a.copyWith(dailyGoal: 5))));
      expect(a, isNot(equals(a.copyWith(reminderIntervalMinutes: 30))));
    });

    test('time getters include minutes as fractions', () {
      final prefs = UserPreferences(
        startHour: 9,
        startMinute: 30,
        endHour: 17,
        endMinute: 45,
      );
      expect(prefs.startTime, 9.5);
      expect(prefs.endTime, 17.75);
      expect(prefs.startTotalMinutes, 570);
      expect(prefs.endTotalMinutes, 1065);
    });

    group('dailyNotificationCount', () {
      test('default window (9-18) gives 10', () {
        expect(UserPreferences().dailyNotificationCount, 10);
      });

      test('narrow window (12-12) gives 1', () {
        expect(
          UserPreferences(startHour: 12, endHour: 12).dailyNotificationCount,
          1,
        );
      });

      test('full day (0-23) gives 24', () {
        expect(
          UserPreferences(startHour: 0, endHour: 23).dailyNotificationCount,
          24,
        );
      });

      test('inverted window gives 0', () {
        expect(
          UserPreferences(startHour: 18, endHour: 9).dailyNotificationCount,
          0,
        );
      });

      test('minute-based window 9:30-17:30 gives 9', () {
        final prefs = UserPreferences(
          startHour: 9,
          startMinute: 30,
          endHour: 17,
          endMinute: 30,
        );
        expect(prefs.dailyNotificationCount, 9);
      });

      test('30 min interval doubles notification count', () {
        // 9-18 = 540 min, 540/30 + 1 = 19
        final prefs = UserPreferences(reminderIntervalMinutes: 30);
        expect(prefs.dailyNotificationCount, 19);
      });

      test('120 min interval halves notification count', () {
        // 9-18 = 540 min, 540/120 + 1 = 5
        final prefs = UserPreferences(reminderIntervalMinutes: 120);
        expect(prefs.dailyNotificationCount, 5);
      });
    });
  });
}
