import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hourly_reminder/core/utils/time_utils.dart';
import 'package:hourly_reminder/services/storage_service.dart';
import 'package:hourly_reminder/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = StorageService(prefs);
  });

  group('StorageService', () {
    test('returns defaults when storage is empty', () async {
      final prefs = service.loadPreferences();
      expect(prefs, equals(UserPreferences()));
    });

    test('round-trips all preference fields', () async {
      // Every field differs from its default, so a missing save or load
      // can't pass by falling back to the default value.
      final expected = UserPreferences(
        isEnabled: true,
        startHour: 8,
        startMinute: 30,
        endHour: 17,
        endMinute: 45,
        workOnMonday: false,
        workOnTuesday: false,
        workOnWednesday: false,
        workOnThursday: false,
        workOnFriday: false,
        workOnSaturday: true,
        workOnSunday: true,
        notificationGender: NotificationGender.female,
        dailyGoal: 12,
        reminderIntervalMinutes: 45,
      );
      await service.savePreferences(expected);
      final loaded = service.loadPreferences();
      expect(loaded, equals(expected));
    });

    test('overwrites previously saved preferences', () async {
      await service.savePreferences(
        UserPreferences(isEnabled: true, startHour: 8),
      );
      await service.savePreferences(
        UserPreferences(isEnabled: false, startHour: 10),
      );
      final loaded = service.loadPreferences();
      expect(loaded.isEnabled, isFalse);
      expect(loaded.startHour, 10);
    });

    test('setDayOff stores and clears date string', () async {
      expect(service.dayOffDate, isNull);
      expect(service.isDayOff, isFalse);

      await service.setDayOff('2026-03-24');
      expect(service.dayOffDate, '2026-03-24');

      await service.setDayOff(null);
      expect(service.dayOffDate, isNull);
      expect(service.isDayOff, isFalse);
    });

    test('isDayOff returns true only when stored date matches today', () async {
      final todayStr = TimeUtils.formatDate(DateTime.now());

      await service.setDayOff(todayStr);
      expect(service.isDayOff, isTrue);

      await service.setDayOff('2000-01-01');
      expect(service.isDayOff, isFalse);
    });

    test('unknown gender string falls back to neutral', () async {
      SharedPreferences.setMockInitialValues({
        'notification_gender': 'unknown_value',
      });
      final prefs = await SharedPreferences.getInstance();
      final freshService = StorageService(prefs);
      final loaded = freshService.loadPreferences();
      expect(loaded.notificationGender, NotificationGender.neutral);
    });
  });
}
