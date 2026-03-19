import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'features/movement/data/datasources/movement_local_datasource.dart';
import 'features/movement/data/repositories/movement_repository_impl.dart';
import 'features/movement_stats/data/repositories/movement_stats_repository_impl.dart';
import 'features/movement_stats/domain/repositories/movement_stats_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final alarmService = AlarmService();

  // Initialize sedentary start time on first launch.
  final datasource = MovementLocalDatasource(prefs);
  if (datasource.getSedentaryStartTime() == null) {
    await datasource.setSedentaryStartTime(DateTime.now());
  }

  final movementRepository = MovementRepositoryImpl(datasource);
  final statsRepository = MovementStatsRepositoryImpl(
    movementRepository: movementRepository,
    storageService: storageService,
  );

  runApp(HourlyReminderApp(
    storageService: storageService,
    alarmService: alarmService,
    statsRepository: statsRepository,
  ));
}

class HourlyReminderApp extends StatelessWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;

  const HourlyReminderApp({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly Reminder',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        extensions: const [AppColors.light],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: const [AppColors.dark],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: HomeScreen(
        storageService: storageService,
        alarmService: alarmService,
        statsRepository: statsRepository,
      ),
    );
  }
}
