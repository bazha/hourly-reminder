import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hourly_reminder/main.dart';
import 'package:hourly_reminder/services/alarm_service.dart';
import 'package:hourly_reminder/services/storage_service.dart';

void main() {
  testWidgets('App smoke test — builds without errors', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(HourlyReminderApp(
      storageService: StorageService(prefs),
      alarmService: AlarmService(),
    ));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
