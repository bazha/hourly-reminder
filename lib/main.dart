import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/main_shell.dart';
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
    const teal = Color(0xFF4EAAA0);

    return MaterialApp(
      title: 'Hourly Reminder',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        extensions: const [AppColors.light],
        scaffoldBackgroundColor: AppColors.light.bg,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: AppColors.light.cardBg,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.light.switchInactiveThumb;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.startColor;
            return AppColors.light.switchInactiveTrack;
          }),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: AppColors.light.sliderThumb,
          overlayColor: teal.withValues(alpha: 0.12),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.light.navBarBg,
          indicatorColor: AppColors.light.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.light.navBarSelected,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.light.navBarUnselected,
            );
          }),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: const [AppColors.dark],
        scaffoldBackgroundColor: AppColors.dark.bg,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: AppColors.dark.cardBg,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.dark.switchInactiveThumb;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.startColor;
            return AppColors.dark.switchInactiveTrack;
          }),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: AppColors.dark.sliderThumb,
          overlayColor: const Color(0xFF5CC4B8).withValues(alpha: 0.12),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.dark.navBarBg,
          indicatorColor: AppColors.dark.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.dark.navBarSelected,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.dark.navBarUnselected,
            );
          }),
        ),
      ),
      home: MainShell(
        storageService: storageService,
        alarmService: alarmService,
        statsRepository: statsRepository,
      ),
    );
  }
}
