import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/time_utils.dart';
import '../features/movement/domain/entities/movement_event.dart';
import '../features/movement/domain/repositories/movement_repository.dart';
import '../features/movement/domain/usecases/confirm_movement_use_case.dart';
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
  final MovementRepository movementRepository;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
    required this.movementRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserPreferences _prefs = UserPreferences();
  bool _isLoading = true;
  int _todayMovementCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await widget.storageService.loadPreferences();
    final count = await _getTodayMovementCount();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _todayMovementCount = count;
      _isLoading = false;
    });
  }

  Future<int> _getTodayMovementCount() async {
    final events = await widget.movementRepository.getEvents();
    final today = DateTime.now();
    return events.where((e) {
      final d = e.timestamp;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).length;
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

  Future<void> _updateTime(double time, {required bool isStart}) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = isStart
          ? _prefs.copyWith(startHour: hour, startMinute: minute)
          : _prefs.copyWith(endHour: hour, endMinute: minute);
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

  Future<void> _updateGoal(int goal) async {
    setState(() {
      _prefs = _prefs.copyWith(dailyGoal: goal);
    });
    await widget.storageService.savePreferences(_prefs);
  }

  Future<void> _recordManualMovement() async {
    final useCase = ConfirmMovementUseCase(
      repository: widget.movementRepository,
      scheduleNext: (_) => widget.alarmService.scheduleHourlyAlarm(),
    );

    await useCase.execute(source: MovementSource.manual);

    final count = await _getTodayMovementCount();
    if (!mounted) return;
    setState(() {
      _todayMovementCount = count;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Записано! Таймер сброшен'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.startColor,
        ),
      );
    }
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
            const SizedBox(height: 4),
            _NextReminderText(prefs: _prefs, colors: colors),
            const SizedBox(height: 20),
            _GoalProgress(
              current: _todayMovementCount,
              goal: _prefs.dailyGoal,
              colors: colors,
            ),
            const SizedBox(height: 20),
            _ManualMoveButton(onPressed: _recordManualMovement),
            const SizedBox(height: 20),
            WorkHoursCard(
              prefs: _prefs,
              onStartChanged: (v) => _updateTime(v, isStart: true),
              onEndChanged: (v) => _updateTime(v, isStart: false),
            ),
            const SizedBox(height: 16),
            ReminderToggleCard(
              isEnabled: _prefs.isEnabled,
              onToggle: _toggleReminders,
            ),
            const SizedBox(height: 16),
            ScheduleCard(
              prefs: _prefs,
              onStartChanged: (v) => _updateTime(v, isStart: true),
              onEndChanged: (v) => _updateTime(v, isStart: false),
            ),
            const SizedBox(height: 16),
            OptionsCard(
              prefs: _prefs,
              onToggleSaturday: _toggleSaturday,
              onToggleSunday: _toggleSunday,
              onGenderChanged: _updateGender,
              onGoalChanged: _updateGoal,
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

class _NextReminderText extends StatelessWidget {
  final UserPreferences prefs;
  final AppColors colors;

  const _NextReminderText({required this.prefs, required this.colors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = AlarmService.nextNotificationTime(
      now: now,
      isEnabled: prefs.isEnabled,
      startHour: prefs.startHour,
      startMinute: prefs.startMinute,
      endHour: prefs.endHour,
      endMinute: prefs.endMinute,
      workOnSaturday: prefs.workOnSaturday,
      workOnSunday: prefs.workOnSunday,
    );
    final text = TimeUtils.formatNextReminder(next, now);

    return Text(
      text,
      style: AppTypography.label.copyWith(color: colors.textMuted),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final int current;
  final int goal;
  final AppColors colors;

  const _GoalProgress({
    required this.current,
    required this.goal,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= goal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Сегодня',
                  style: AppTypography.cardTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  '$current/$goal',
                  style: AppTypography.statNumber.copyWith(
                    color: isComplete ? AppColors.startColor : colors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: colors.sliderInactiveTrack,
                valueColor: AlwaysStoppedAnimation(
                  isComplete ? AppColors.startColor : colors.accent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isComplete ? 'Цель выполнена!' : 'разминок из $goal',
              style: AppTypography.label.copyWith(
                color: isComplete ? AppColors.startColor : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualMoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ManualMoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: Text('Я подвигался!', style: AppTypography.button),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.startColor,
          side: const BorderSide(color: AppColors.startColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
