import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await service.loadPreferences();
      expect(prefs, equals(UserPreferences()));
    });

    test('round-trips all preference fields', () async {
      final expected = UserPreferences(
        isEnabled: true,
        startHour: 8,
        startMinute: 30,
        endHour: 17,
        endMinute: 45,
        workOnSaturday: true,
        workOnSunday: false,
        notificationGender: NotificationGender.female,
        dailyGoal: 12,
      );
      await service.savePreferences(expected);
      final loaded = await service.loadPreferences();
      expect(loaded, equals(expected));
    });

    test('overwrites previously saved preferences', () async {
      await service.savePreferences(
        UserPreferences(isEnabled: true, startHour: 8),
      );
      await service.savePreferences(
        UserPreferences(isEnabled: false, startHour: 10),
      );
      final loaded = await service.loadPreferences();
      expect(loaded.isEnabled, isFalse);
      expect(loaded.startHour, 10);
    });

    test('persists all gender values', () async {
      for (final gender in NotificationGender.values) {
        await service.savePreferences(
          UserPreferences(notificationGender: gender),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.notificationGender, gender, reason: gender.name);
      }
    });

    test('unknown gender string falls back to neutral', () async {
      SharedPreferences.setMockInitialValues({
        'notification_gender': 'unknown_value',
      });
      final prefs = await SharedPreferences.getInstance();
      final freshService = StorageService(prefs);
      final loaded = await freshService.loadPreferences();
      expect(loaded.notificationGender, NotificationGender.neutral);
    });

    test('sync getters reflect saved preferences', () async {
      await service.savePreferences(
        UserPreferences(
          isEnabled: true,
          startHour: 7,
          endHour: 15,
          workOnSaturday: true,
          workOnSunday: false,
          dailyGoal: 10,
        ),
      );
      expect(service.isEnabled, isTrue);
      expect(service.startHour, 7);
      expect(service.endHour, 15);
      expect(service.workOnSaturday, isTrue);
      expect(service.workOnSunday, isFalse);
      expect(service.dailyGoal, 10);
    });
  });
}
