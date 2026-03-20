import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/time_utils.dart';
import '../features/movement/domain/entities/movement_event.dart';
import '../features/movement/domain/repositories/movement_repository.dart';
import '../features/movement/domain/usecases/confirm_movement_use_case.dart';
import '../features/movement_stats/domain/repositories/movement_stats_repository.dart';
import '../l10n/app_localizations.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/user_preferences.dart';
import 'widgets/work_hours_card.dart';
import 'widgets/settings_card.dart';

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
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).length;
  }

  Future<void> _toggleReminders(bool value) async {
    if (value) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.permissionRequired)),
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

  Future<void> _updateInterval(int minutes) async {
    setState(() {
      _prefs = _prefs.copyWith(reminderIntervalMinutes: minutes);
    });
    await widget.storageService.savePreferences(_prefs);
    if (_prefs.isEnabled && mounted) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.movementRecorded),
          duration: const Duration(seconds: 2),
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
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.appTitle,
                  style: AppTypography.heading.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                _EnableToggle(
                  isEnabled: _prefs.isEnabled,
                  onToggle: _toggleReminders,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _NextReminderBanner(prefs: _prefs, colors: colors),
            const SizedBox(height: 24),
            _GoalProgress(
              current: _todayMovementCount,
              goal: _prefs.dailyGoal,
              colors: colors,
            ),
            const SizedBox(height: 12),
            _ManualMoveButton(onPressed: _recordManualMovement),
            const SizedBox(height: 32),
            WorkHoursCard(
              prefs: _prefs,
              onStartChanged: (v) => _updateTime(v, isStart: true),
              onEndChanged: (v) => _updateTime(v, isStart: false),
            ),
            const SizedBox(height: 32),
            SettingsSection(
              prefs: _prefs,
              onToggleSaturday: _toggleSaturday,
              onToggleSunday: _toggleSunday,
              onGenderChanged: _updateGender,
              onGoalChanged: _updateGoal,
              onIntervalChanged: _updateInterval,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnableToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _EnableToggle({required this.isEnabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      toggled: isEnabled,
      label: l10n.toggleSemanticsLabel,
      child: GestureDetector(
        onTap: () => onToggle(!isEnabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.startColor.withValues(alpha: 0.15)
                : colors.sliderInactiveTrack,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? AppColors.startColor.withValues(alpha: 0.3)
                  : colors.divider,
            ),
          ),
          child: Text(
            isEnabled ? l10n.toggleOn : l10n.toggleOff,
            style: AppTypography.label.copyWith(
              color: isEnabled ? AppColors.startColor : colors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _NextReminderBanner extends StatelessWidget {
  final UserPreferences prefs;
  final AppColors colors;

  const _NextReminderBanner({required this.prefs, required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      intervalMinutes: prefs.reminderIntervalMinutes,
    );
    final text = TimeUtils.formatNextReminder(next, now, l10n);

    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: colors.textMuted),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= goal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.todayLabel,
                  style: AppTypography.sectionLabel.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$current',
              style: AppTypography.statLarge.copyWith(
                color: isComplete ? AppColors.startColor : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.goalProgressText(goal),
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: colors.sliderInactiveTrack,
                valueColor: AlwaysStoppedAnimation(
                  isComplete ? AppColors.startColor : AppColors.primary,
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check, size: 18),
        label: Text(l10n.recordMovement,
            style: AppTypography.button.copyWith(fontSize: 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.startColor,
          side: const BorderSide(color: AppColors.startColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
