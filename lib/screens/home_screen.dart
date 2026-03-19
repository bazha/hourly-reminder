import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/movement_stats/domain/repositories/movement_stats_repository.dart';
import '../features/movement_stats/presentation/stats_screen.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/user_preferences.dart';
import 'widgets/work_hours_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/test_notification_button.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
  });

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
    final prefs = await widget.storageService.loadPreferences();
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
      await widget.alarmService.scheduleHourlyAlarm();
    } else {
      await widget.alarmService.cancelAlarm();
    }

    setState(() {
      _prefs = _prefs.copyWith(isEnabled: value);
    });
    await widget.storageService.savePreferences(_prefs);
  }

  // Обновить время начала (в формате double: 9.5 = 9:30)
  Future<void> _updateStartTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(startHour: hour, startMinute: minute);
    });
    await widget.storageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
  }

  // Обновить время окончания
  Future<void> _updateEndTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(endHour: hour, endMinute: minute);
    });
    await widget.storageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
  }

  Future<void> _toggleSaturday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSaturday: value);
    });
    await widget.storageService.savePreferences(_prefs);
  }

  Future<void> _toggleSunday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSunday: value);
    });
    await widget.storageService.savePreferences(_prefs);
  }

  Future<void> _updateGender(NotificationGender gender) async {
    setState(() {
      _prefs = _prefs.copyWith(notificationGender: gender);
    });
    await widget.storageService.savePreferences(_prefs);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Статистика',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StatsScreen(
                    repository: widget.statsRepository,
                  ),
                ),
              );
            },
          ),
        ],
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
