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
import 'widgets/goal_ring_painter.dart';
import 'widgets/work_hours_card.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;
  final MovementRepository movementRepository;
  final bool isActive;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
    required this.movementRepository,
    this.isActive = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserPreferences _prefs = UserPreferences();
  bool _isLoading = true;
  int _todayMovementCount = 0;
  bool _isDayOff = false;
  int _streakDays = 0;
  int _activityPercent = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _loadData();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final oldPrefs = _prefs;
    final prefs = await widget.storageService.loadPreferences();
    final count = await _getTodayMovementCount();
    var dayOff = widget.storageService.isDayOff;

    // Clear day off if today's weekday was just toggled ON in Settings.
    if (dayOff && !_isLoading) {
      final today = DateTime.now().weekday;
      final wasWorkDay = oldPrefs.isWorkDay(today);
      final isWorkDay = prefs.isWorkDay(today);
      if (!wasWorkDay && isWorkDay) {
        await widget.storageService.setDayOff(null);
        dayOff = false;
        if (prefs.isEnabled) {
          await widget.alarmService.scheduleHourlyAlarm();
        }
      }
    }

    // Load streak stats.
    int streak = 0;
    try {
      final stats = await widget.statsRepository.getStats();
      streak = stats.streak.currentStreak;
    } catch (_) {
      // Stats are optional - don't block the home screen.
    }

    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _todayMovementCount = count;
      _isDayOff = dayOff;
      _streakDays = streak;
      _recalcActivity();
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

  bool _togglingReminders = false;

  Future<void> _toggleReminders(bool value) async {
    if (_togglingReminders) return;
    _togglingReminders = true;

    // Update UI immediately so the toggle feels responsive.
    setState(() {
      _prefs = _prefs.copyWith(isEnabled: value);
    });

    try {
      if (value) {
        final hasPermission = await NotificationService.requestPermissions();
        if (!hasPermission) {
          // Revert - permission denied.
          if (mounted) {
            setState(() {
              _prefs = _prefs.copyWith(isEnabled: false);
            });
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

      await widget.storageService.savePreferences(_prefs);
    } finally {
      _togglingReminders = false;
    }
  }

  Future<void> _toggleDayOff() async {
    final today = TimeUtils.formatDate(DateTime.now());
    final newValue = !_isDayOff;
    setState(() {
      _isDayOff = newValue;
    });
    await widget.storageService.setDayOff(newValue ? today : null);
    if (newValue) {
      await widget.alarmService.cancelAlarm();
    } else if (_prefs.isEnabled) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
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

  void _recalcActivity() {
    final goal = _prefs.dailyGoal;
    _activityPercent = goal > 0 ? _todayMovementCount * 100 ~/ goal : 0;
  }

  Future<void> _recordManualMovement() async {
    // Optimistic update: show +1 and recalculate activity immediately.
    setState(() {
      _todayMovementCount++;
      _recalcActivity();
    });

    final useCase = ConfirmMovementUseCase(
      repository: widget.movementRepository,
      scheduleNext: (_) => widget.alarmService.scheduleHourlyAlarm(),
    );

    await useCase.execute(source: MovementSource.manual);

    // Re-read actual count from storage to stay in sync.
    final count = await _getTodayMovementCount();
    if (!mounted) return;
    setState(() {
      _todayMovementCount = count;
      _recalcActivity();
    });

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.movementRecorded),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  String _workDaysLabel(AppLocalizations l10n) {
    return _prefs.formatWorkDays([
      l10n.dayMon, l10n.dayTue, l10n.dayWed, l10n.dayThu,
      l10n.dayFri, l10n.daySat, l10n.daySun,
    ]);
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
            // Header
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
            if (_prefs.isEnabled && _isDayOff) ...[
              const SizedBox(height: 8),
              _DayOffChip(
                isDayOff: _isDayOff,
                onToggle: _toggleDayOff,
              ),
            ],
            const SizedBox(height: 8),
            _NextReminderBanner(
                prefs: _prefs, colors: colors, isDayOff: _isDayOff),

            // Hero ring
            const SizedBox(height: 28),
            _GoalRing(
              current: _todayMovementCount,
              goal: _prefs.dailyGoal,
              colors: colors,
            ),

            // Action button
            const SizedBox(height: 24),
            _ManualMoveButton(onPressed: _recordManualMovement),

            // Work hours
            const SizedBox(height: 24),
            WorkHoursCard(
              prefs: _prefs,
              onStartChanged: (v) => _updateTime(v, isStart: true),
              onEndChanged: (v) => _updateTime(v, isStart: false),
            ),

            // Quick stats
            const SizedBox(height: 12),
            _QuickStats(
              streakDays: _streakDays,
              activityPercent: _activityPercent,
              colors: colors,
            ),

            // Settings rows
            const SizedBox(height: 12),
            _SettingsCard(
              workDays: _workDaysLabel(l10n),
              dailyGoal: l10n.nMovements(_prefs.dailyGoal),
              colors: colors,
            ),

            // Motivational footer
            const SizedBox(height: 12),
            _MotivationalCard(colors: colors),
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
            color: isEnabled ? AppColors.primary : colors.sliderInactiveTrack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isEnabled ? l10n.toggleOn : l10n.toggleOff,
            style: AppTypography.label.copyWith(
              color: isEnabled
                  ? (colors.isDark ? Colors.black : Colors.white)
                  : colors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayOffChip extends StatelessWidget {
  final bool isDayOff;
  final VoidCallback onToggle;

  const _DayOffChip({required this.isDayOff, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDayOff
              ? AppColors.endColor.withValues(alpha: 0.15)
              : colors.sliderInactiveTrack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDayOff
                ? AppColors.endColor.withValues(alpha: 0.3)
                : colors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDayOff ? Icons.bedtime : Icons.bedtime_outlined,
              size: 14,
              color: isDayOff ? AppColors.endColor : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              isDayOff ? l10n.dayOffActive : l10n.dayOffButton,
              style: AppTypography.label.copyWith(
                color: isDayOff ? AppColors.endColor : colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextReminderBanner extends StatelessWidget {
  final UserPreferences prefs;
  final AppColors colors;
  final bool isDayOff;

  const _NextReminderBanner({
    required this.prefs,
    required this.colors,
    this.isDayOff = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isDayOff) {
      return Row(
        children: [
          Icon(Icons.bedtime, size: 16, color: colors.textMuted),
          const SizedBox(width: 8),
          Text(
            l10n.dayOffBanner,
            style: AppTypography.label.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final next = AlarmService.nextNotificationTime(
      now: now,
      isEnabled: prefs.isEnabled,
      startHour: prefs.startHour,
      startMinute: prefs.startMinute,
      endHour: prefs.endHour,
      endMinute: prefs.endMinute,
      workDays: prefs.workDaySet,
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

class _GoalRing extends StatelessWidget {
  final int current;
  final int goal;
  final AppColors colors;

  const _GoalRing({
    required this.current,
    required this.goal,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 200),
              painter: GoalRingPainter(
                progress: progress,
                trackColor: colors.ringTrack,
                fillColor: AppColors.primary,
                strokeWidth: 12,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current',
                  style: AppTypography.statLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  current == 0
                      ? l10n.goalZeroMotivation
                      : l10n.goalProgressText(goal),
                  style: AppTypography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int streakDays;
  final int activityPercent;
  final AppColors colors;

  const _QuickStats({
    required this.streakDays,
    required this.activityPercent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.loop, size: 16, color: colors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    '$streakDays',
                    style: AppTypography.statMedium
                        .copyWith(color: colors.streakColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.streakDays(streakDays),
                    style: AppTypography.label
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.show_chart, size: 16, color: colors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    '$activityPercent%',
                    style: AppTypography.statMedium
                        .copyWith(color: colors.activityColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.activityLabel,
                    style: AppTypography.label
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String workDays;
  final String dailyGoal;
  final AppColors colors;

  const _SettingsCard({
    required this.workDays,
    required this.dailyGoal,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _SettingsRow(
          icon: Icons.date_range_outlined,
          label: l10n.settingWorkDays,
          value: workDays,
          colors: colors,
        ),
        const SizedBox(height: 8),
        _SettingsRow(
          icon: Icons.adjust,
          label: l10n.settingDailyGoal,
          value: dailyGoal,
          colors: colors,
        ),
      ],
    );
  }
}

class _ManualMoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ManualMoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        child: Text(l10n.recordMovement),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColors colors;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              value,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationalCard extends StatelessWidget {
  final AppColors colors;

  const _MotivationalCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Slightly lighter than page background, not as bright as cardBg
    final surface = Color.lerp(colors.bg, colors.cardBg, colors.isDark ? 0.7 : 0.05)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: surface,
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: colors.isDark ? 0.35 : 0.12,
                child: Image.asset(
                  'assets/motivation.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      surface.withValues(alpha: 0.2),
                      surface.withValues(alpha: 0.8),
                      surface,
                    ],
                    stops: const [0.0, 0.55, 0.8],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Text(
                l10n.motivationalMessage,
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
