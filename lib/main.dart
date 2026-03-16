import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io' show Platform;
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/alarm_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  await NotificationService.initialize();
  await StorageService.initialize();

  runApp(const HourlyReminderApp());
}

class HourlyReminderApp extends StatelessWidget {
  const HourlyReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
