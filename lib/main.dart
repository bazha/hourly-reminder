import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'features/movement/data/datasources/movement_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await StorageService.initialize();

  // Initialize sedentary start time on first launch.
  final prefs = await SharedPreferences.getInstance();
  final datasource = MovementLocalDatasource(prefs);
  if (datasource.getSedentaryStartTime() == null) {
    await datasource.setSedentaryStartTime(DateTime.now());
  }

  runApp(const HourlyReminderApp());
}

class HourlyReminderApp extends StatelessWidget {
  const HourlyReminderApp({super.key});

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
      home: const HomeScreen(),
    );
  }
}
