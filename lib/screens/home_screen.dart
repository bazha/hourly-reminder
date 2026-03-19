import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../features/movement_stats/domain/repositories/movement_stats_repository.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    final colors = AppColors.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Напоминалка',
              style: AppTypography.heading.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 6),
            _StatusPill(isEnabled: _prefs.isEnabled, colors: colors),
            const SizedBox(height: 24),
            WorkHoursCard(
              prefs: _prefs,
              onStartChanged: _updateStartTime,
              onEndChanged: _updateEndTime,
            ),
            const SizedBox(height: 16),
            ReminderToggleCard(
              isEnabled: _prefs.isEnabled,
              onToggle: _toggleReminders,
            ),
            const SizedBox(height: 16),
            ScheduleCard(
              prefs: _prefs,
              onStartChanged: _updateStartTime,
              onEndChanged: _updateEndTime,
            ),
            const SizedBox(height: 16),
            OptionsCard(
              prefs: _prefs,
              onToggleSaturday: _toggleSaturday,
              onToggleSunday: _toggleSunday,
              onGenderChanged: _updateGender,
            ),
            const SizedBox(height: 16),
            const TestNotificationButton(),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isEnabled;
  final AppColors colors;

  const _StatusPill({required this.isEnabled, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.startColor.withValues(alpha: 0.12)
            : colors.sliderInactiveTrack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.startColor : colors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isEnabled ? 'Включены' : 'Выключены',
            style: AppTypography.label.copyWith(
              color: isEnabled ? AppColors.startColor : colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
