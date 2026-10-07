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
      expect(a, isNot(equals(a.copyWith(endMinute: 0))));
      expect(a, isNot(equals(a.copyWith(workOnMonday: false))));
      expect(a, isNot(equals(a.copyWith(workOnTuesday: false))));
      expect(a, isNot(equals(a.copyWith(workOnWednesday: false))));
      expect(a, isNot(equals(a.copyWith(workOnThursday: false))));
      expect(a, isNot(equals(a.copyWith(workOnFriday: false))));
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

    group('hasReminderWindow', () {
      test('end before start fits no reminder', () {
        final prefs = UserPreferences(startHour: 18, endHour: 9);
        expect(prefs.hasReminderWindow, isFalse);
      });

      test('interval longer than the window fits no reminder', () {
        final prefs = UserPreferences(
            startHour: 9, endHour: 10, reminderIntervalMinutes: 120);
        expect(prefs.hasReminderWindow, isFalse);
      });

      test('interval equal to the window fits one reminder', () {
        final prefs = UserPreferences(
            startHour: 9, endHour: 10, reminderIntervalMinutes: 60);
        expect(prefs.hasReminderWindow, isTrue);
      });
    });

    group('formatWorkDays', () {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      test('default Mon-Fri formats as range', () {
        expect(UserPreferences().formatWorkDays(days), 'Mon-Fri');
      });

      test('no work days returns empty string', () {
        final prefs = UserPreferences(
          workOnMonday: false,
          workOnTuesday: false,
          workOnWednesday: false,
          workOnThursday: false,
          workOnFriday: false,
        );
        expect(prefs.formatWorkDays(days), '');
      });

      test('non-contiguous days show comma-separated', () {
        final prefs = UserPreferences(
          workOnTuesday: false,
          workOnWednesday: false,
          workOnThursday: false,
          workOnFriday: false,
          workOnSaturday: true,
        );
        expect(prefs.formatWorkDays(days), 'Mon, Sat');
      });
    });
  });
}
