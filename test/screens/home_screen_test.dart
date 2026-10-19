import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/data/datasources/movement_local_datasource.dart';
import 'package:hourly_reminder/features/movement/data/repositories/movement_repository_impl.dart';
import 'package:hourly_reminder/features/movement_stats/data/repositories/movement_stats_repository_impl.dart';
import 'package:hourly_reminder/l10n/app_localizations_en.dart';
import 'package:hourly_reminder/main.dart';
import 'package:hourly_reminder/services/alarm_service.dart';
import 'package:hourly_reminder/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> pumpApp(
    WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final movementRepo = MovementRepositoryImpl(MovementLocalDatasource(prefs));
  await tester.pumpWidget(HourlyReminderApp(
    prefs: prefs,
    storageService: storageService,
    alarmService: AlarmService(),
    statsRepository: MovementStatsRepositoryImpl(
      movementRepository: movementRepo,
      storageService: storageService,
    ),
    movementRepository: movementRepo,
    initialLocale: const Locale('en'),
  ));
  await tester.pumpAndSettle();
  return prefs;
}

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('banner warns when reminders are on but none fits',
      (tester) async {
    await pumpApp(tester, {
      'is_enabled': true,
      'start_hour': 18,
      'end_hour': 9,
    });

    expect(find.text(l10n.noReminderFits), findsOneWidget);
    expect(find.text(l10n.remindersDisabled), findsNothing);
  });

  testWidgets('end time that fits no reminder is saved with a warning',
      (tester) async {
    final prefs = await pumpApp(tester, {'is_enabled': false});

    // Work hours 9:00-18:00: set the end to 8:00 through the time picker.
    await tester.ensureVisible(find.text('18:00'));
    await tester.tap(find.text('18:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '8');
    await tester.enterText(fields.at(1), '00');
    await tester.tap(find.text('AM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(StorageService(prefs).loadPreferences().endHour, 8);
    expect(find.text(l10n.noReminderFits), findsOneWidget);
  });

  testWidgets('banner says disabled when reminders are off', (tester) async {
    await pumpApp(tester, {
      'is_enabled': false,
      'start_hour': 18,
      'end_hour': 9,
    });

    expect(find.text(l10n.remindersDisabled), findsOneWidget);
  });
}
