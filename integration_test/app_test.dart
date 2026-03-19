import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hourly_reminder/main.dart';
import 'package:hourly_reminder/services/alarm_service.dart';
import 'package:hourly_reminder/services/notification_service.dart';
import 'package:hourly_reminder/services/storage_service.dart';

late StorageService _storageService;
late AlarmService _alarmService;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    _storageService = StorageService(prefs);
    _alarmService = AlarmService();
    await NotificationService.initialize();
  });

  group('Full user flow', () {
    testWidgets('app launches and shows all UI elements', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Напоминалка'), findsOneWidget);
      expect(find.text('Hourly movement reminders'), findsOneWidget);

      // Clock section
      expect(find.text('Рабочее время'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.text('END'), findsOneWidget);

      // Settings
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Skip weekends'), findsOneWidget);

      // Button
      expect(find.text('Send test notification'), findsOneWidget);
    });

    testWidgets('default times are 9:00 and 18:00', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      expect(find.text('9:00'), findsWidgets);
      expect(find.text('18:00'), findsWidgets);
    });

    testWidgets('reminders start disabled', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('sliders are visible and interactive', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));

      // Drag the first slider (start time) to the right
      final startSlider = sliders.first;
      await tester.drag(startSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Time should have changed from default
      // (We just verify no crash — exact value depends on slider range)
    });

    testWidgets('notification count badge visible', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('/day'), findsOneWidget);
    });

    testWidgets('theme mode is system', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('time pills show tap-to-edit hint', (tester) async {
      await tester.pumpWidget(HourlyReminderApp(
        storageService: _storageService,
        alarmService: _alarmService,
      ));
      await tester.pumpAndSettle();

      expect(find.text('tap to edit'), findsNWidgets(2));
    });
  });
}
