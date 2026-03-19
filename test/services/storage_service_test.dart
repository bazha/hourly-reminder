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
    group('loadPreferences', () {
      test('returns defaults when storage is empty', () async {
        final prefs = await service.loadPreferences();
        expect(prefs.isEnabled, isFalse);
        expect(prefs.startHour, equals(9));
        expect(prefs.endHour, equals(18));
        expect(prefs.workOnSaturday, isFalse);
        expect(prefs.workOnSunday, isFalse);
      });

      test('returns saved values after savePreferences', () async {
        final expected = UserPreferences(
          isEnabled: true,
          startHour: 8,
          endHour: 17,
          workOnSaturday: true,
          workOnSunday: false,
        );
        await service.savePreferences(expected);
        final loaded = await service.loadPreferences();
        expect(loaded, equals(expected));
      });

      test('persists custom work hours', () async {
        await service.savePreferences(
          UserPreferences(startHour: 10, endHour: 16),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.startHour, equals(10));
        expect(loaded.endHour, equals(16));
      });

      test('persists workOnSunday = true', () async {
        await service.savePreferences(
          UserPreferences(workOnSunday: true),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.workOnSunday, isTrue);
      });
    });

    group('notificationGender persistence', () {
      test('defaults to neutral when not set', () async {
        final loaded = await service.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });

      test('persists male gender', () async {
        await service.savePreferences(
          UserPreferences(notificationGender: NotificationGender.male),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.male));
      });

      test('persists female gender', () async {
        await service.savePreferences(
          UserPreferences(notificationGender: NotificationGender.female),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.female));
      });

      test('persists neutral gender', () async {
        await service.savePreferences(
          UserPreferences(notificationGender: NotificationGender.neutral),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });

      test('unknown string value falls back to neutral', () async {
        SharedPreferences.setMockInitialValues({
          'notification_gender': 'unknown_value',
        });
        final prefs = await SharedPreferences.getInstance();
        final freshService = StorageService(prefs);
        final loaded = await freshService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });
    });

    group('savePreferences', () {
      test('overwrites previously saved preferences', () async {
        await service.savePreferences(
          UserPreferences(isEnabled: true, startHour: 8),
        );
        await service.savePreferences(
          UserPreferences(isEnabled: false, startHour: 10),
        );
        final loaded = await service.loadPreferences();
        expect(loaded.isEnabled, isFalse);
        expect(loaded.startHour, equals(10));
      });
    });

    group('synchronous getters (alarm isolate)', () {
      test('isEnabled returns false by default', () {
        expect(service.isEnabled, isFalse);
      });

      test('startHour returns 9 by default', () {
        expect(service.startHour, equals(9));
      });

      test('endHour returns 18 by default', () {
        expect(service.endHour, equals(18));
      });

      test('workOnSaturday returns false by default', () {
        expect(service.workOnSaturday, isFalse);
      });

      test('workOnSunday returns false by default', () {
        expect(service.workOnSunday, isFalse);
      });

      test('sync getters reflect saved preferences', () async {
        await service.savePreferences(
          UserPreferences(
            isEnabled: true,
            startHour: 7,
            endHour: 15,
            workOnSaturday: true,
            workOnSunday: false,
          ),
        );
        expect(service.isEnabled, isTrue);
        expect(service.startHour, equals(7));
        expect(service.endHour, equals(15));
        expect(service.workOnSaturday, isTrue);
        expect(service.workOnSunday, isFalse);
      });
    });
  });
}
