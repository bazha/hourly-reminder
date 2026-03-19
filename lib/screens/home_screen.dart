import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/user_preferences.dart';
import 'widgets/work_hours_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/test_notification_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserPreferences _prefs = UserPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await StorageService.loadPreferences();
    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminders(bool value) async {
    if (value) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешите уведомления в настройках')),
          );
        }
        return;
      }
      await AlarmService.scheduleHourlyAlarm();
    } else {
      await AlarmService.cancelAlarm();
    }

    setState(() {
      _prefs = _prefs.copyWith(isEnabled: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  // Обновить время начала (в формате double: 9.5 = 9:30)
  Future<void> _updateStartTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(startHour: hour, startMinute: minute);
    });
    await StorageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await AlarmService.scheduleHourlyAlarm();
    }
  }

  // Обновить время окончания
  Future<void> _updateEndTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(endHour: hour, endMinute: minute);
    });
    await StorageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await AlarmService.scheduleHourlyAlarm();
    }
  }

  Future<void> _toggleSaturday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSaturday: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  Future<void> _toggleSunday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSunday: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  Future<void> _updateGender(NotificationGender gender) async {
    setState(() {
      _prefs = _prefs.copyWith(notificationGender: gender);
    });
    await StorageService.savePreferences(_prefs);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Напоминалка',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.appBarFg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WorkHoursCard(
              prefs: _prefs,
              onStartChanged: _updateStartTime,
              onEndChanged: _updateEndTime,
            ),
            const SizedBox(height: 20),
            SettingsCard(
              prefs: _prefs,
              onToggleReminders: _toggleReminders,
              onStartChanged: _updateStartTime,
              onEndChanged: _updateEndTime,
              onToggleSaturday: _toggleSaturday,
              onToggleSunday: _toggleSunday,
              onGenderChanged: _updateGender,
            ),
            const SizedBox(height: 20),
            const TestNotificationButton(),
          ],
        ),
      ),
    );
  }
}
