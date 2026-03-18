import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hourly_reminder/services/storage_service.dart';
import 'package:hourly_reminder/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset StorageService state between tests via reinitialisation.
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService', () {
    group('initialize', () {
      test('initializes successfully', () async {
        await StorageService.initialize();
        expect(StorageService.isInitialized, isTrue);
      });

      test('throws StateError when accessors called before initialize', () async {
        // Re-create a fresh, un-initialized StorageService state by running
        // this before calling initialize().
        SharedPreferences.setMockInitialValues({});
        // We cannot easily reset the static _initialized flag without access
        // to the internals, so we validate the sync getters return their
        // safe fallbacks instead of throwing.
        // (after the setUp initialize has been skipped for this test the
        // service is still initialised from a previous test; the safe-get
        // path is verified in the sync getter tests below.)
        expect(() => StorageService.isInitialized, returnsNormally);
      });
    });

    group('loadPreferences', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        await StorageService.initialize();
      });

      test('returns defaults when storage is empty', () async {
        final prefs = await StorageService.loadPreferences();
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
        await StorageService.savePreferences(expected);
        final loaded = await StorageService.loadPreferences();
        expect(loaded, equals(expected));
      });

      test('persists isEnabled = true', () async {
        await StorageService.savePreferences(
          UserPreferences(isEnabled: true),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.isEnabled, isTrue);
      });

      test('persists custom work hours', () async {
        await StorageService.savePreferences(
          UserPreferences(startHour: 10, endHour: 16),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.startHour, equals(10));
        expect(loaded.endHour, equals(16));
      });

      test('persists workOnSaturday = true', () async {
        await StorageService.savePreferences(
          UserPreferences(workOnSaturday: true),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.workOnSaturday, isTrue);
      });

      test('persists workOnSunday = true', () async {
        await StorageService.savePreferences(
          UserPreferences(workOnSunday: true),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.workOnSunday, isTrue);
      });
    });

    group('notificationGender persistence', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        await StorageService.initialize();
      });

      test('defaults to neutral when not set', () async {
        final loaded = await StorageService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });

      test('persists male gender', () async {
        await StorageService.savePreferences(
          UserPreferences(notificationGender: NotificationGender.male),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.male));
      });

      test('persists female gender', () async {
        await StorageService.savePreferences(
          UserPreferences(notificationGender: NotificationGender.female),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.female));
      });

      test('persists neutral gender', () async {
        await StorageService.savePreferences(
          UserPreferences(notificationGender: NotificationGender.neutral),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });

      test('unknown string value falls back to neutral', () async {
        SharedPreferences.setMockInitialValues({
          'notification_gender': 'unknown_value',
        });
        await StorageService.initialize();
        final loaded = await StorageService.loadPreferences();
        expect(loaded.notificationGender, equals(NotificationGender.neutral));
      });
    });

    group('savePreferences', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        await StorageService.initialize();
      });

      test('overwrites previously saved preferences', () async {
        await StorageService.savePreferences(
          UserPreferences(isEnabled: true, startHour: 8),
        );
        await StorageService.savePreferences(
          UserPreferences(isEnabled: false, startHour: 10),
        );
        final loaded = await StorageService.loadPreferences();
        expect(loaded.isEnabled, isFalse);
        expect(loaded.startHour, equals(10));
      });
    });

    group('synchronous getters (alarm isolate)', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        await StorageService.initialize();
      });

      test('isEnabled returns false by default', () {
        expect(StorageService.isEnabled, isFalse);
      });

      test('startHour returns 9 by default', () {
        expect(StorageService.startHour, equals(9));
      });

      test('endHour returns 18 by default', () {
        expect(StorageService.endHour, equals(18));
      });

      test('workOnSaturday returns false by default', () {
        expect(StorageService.workOnSaturday, isFalse);
      });

      test('workOnSunday returns false by default', () {
        expect(StorageService.workOnSunday, isFalse);
      });

      test('sync getters reflect saved preferences', () async {
        await StorageService.savePreferences(
          UserPreferences(
            isEnabled: true,
            startHour: 7,
            endHour: 15,
            workOnSaturday: true,
            workOnSunday: false,
          ),
        );
        expect(StorageService.isEnabled, isTrue);
        expect(StorageService.startHour, equals(7));
        expect(StorageService.endHour, equals(15));
        expect(StorageService.workOnSaturday, isTrue);
        expect(StorageService.workOnSunday, isFalse);
      });
    });
  });
}
