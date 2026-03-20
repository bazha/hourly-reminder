import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hourly_reminder/main.dart';
import 'package:hourly_reminder/features/movement/data/datasources/movement_local_datasource.dart';
import 'package:hourly_reminder/features/movement/data/repositories/movement_repository_impl.dart';
import 'package:hourly_reminder/features/movement_stats/data/repositories/movement_stats_repository_impl.dart';
import 'package:hourly_reminder/services/alarm_service.dart';
import 'package:hourly_reminder/services/storage_service.dart';

void main() {
  testWidgets('App smoke test — builds without errors', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    final datasource = MovementLocalDatasource(prefs);
    final movementRepo = MovementRepositoryImpl(datasource);
    final statsRepo = MovementStatsRepositoryImpl(
      movementRepository: movementRepo,
      storageService: storageService,
    );

    await tester.pumpWidget(HourlyReminderApp(
      storageService: storageService,
      alarmService: AlarmService(),
      statsRepository: statsRepo,
      movementRepository: movementRepo,
    ));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
