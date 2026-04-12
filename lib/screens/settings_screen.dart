import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/time_utils.dart';
import '../l10n/app_localizations.dart';
import '../models/user_preferences.dart';
import '../main.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'widgets/settings_card.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final bool isActive;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.alarmService,
    this.isActive = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserPreferences _prefs = UserPreferences();
  bool _isLoading = true;
  bool _isDayOff = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadPrefs();
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = widget.storageService.loadPreferences();
    final dayOff = widget.storageService.isDayOff;
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _isDayOff = dayOff;
      _isLoading = false;
    });
  }

  Future<void> _toggleDayOff() async {
    final newValue = !_isDayOff;
    setState(() => _isDayOff = newValue);
    final today = newValue ? TimeUtils.formatDate(DateTime.now()) : null;
    await widget.storageService.setDayOff(today);
    if (newValue) {
      await widget.alarmService.cancelAlarm();
    } else if (_prefs.isEnabled) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
  }

  Future<void> _saveAndReschedule(UserPreferences updated,
      {bool reschedule = false}) async {
    setState(() => _prefs = updated);
    await widget.storageService.savePreferences(updated);
    if (reschedule && updated.isEnabled && mounted) {
      await widget.alarmService.scheduleHourlyAlarm();
    }
  }

  Future<void> _updateTime(double time, {required bool isStart}) async {
    final (:hour, :minute) = TimeUtils.doubleToHourMinute(time);
    final updated = isStart
        ? _prefs.copyWith(startHour: hour, startMinute: minute)
        : _prefs.copyWith(endHour: hour, endMinute: minute);
    await _saveAndReschedule(updated, reschedule: true);
  }

  Future<void> _toggleWorkDay(int weekday, bool value) async {
    final updated = switch (weekday) {
      1 => _prefs.copyWith(workOnMonday: value),
      2 => _prefs.copyWith(workOnTuesday: value),
      3 => _prefs.copyWith(workOnWednesday: value),
      4 => _prefs.copyWith(workOnThursday: value),
      5 => _prefs.copyWith(workOnFriday: value),
      6 => _prefs.copyWith(workOnSaturday: value),
      7 => _prefs.copyWith(workOnSunday: value),
      _ => _prefs,
    };
    await _saveAndReschedule(updated);

    // If today's weekday was toggled on, clear day off since the user
    // explicitly wants to work today, and reschedule the alarm.
    if (value && weekday == DateTime.now().weekday) {
      await widget.storageService.setDayOff(null);
      if (mounted) setState(() => _isDayOff = false);
      if (updated.isEnabled) {
        await widget.alarmService.scheduleHourlyAlarm();
      }
    }
  }

  Future<void> _updateInterval(int minutes) async {
    final updated = _prefs.copyWith(reminderIntervalMinutes: minutes);
    await _saveAndReschedule(updated, reschedule: true);
  }

  Future<void> _updateGoal(int goal) async {
    final updated = _prefs.copyWith(dailyGoal: goal);
    await _saveAndReschedule(updated);
  }

  Future<void> _updateGender(NotificationGender gender) async {
    final updated = _prefs.copyWith(notificationGender: gender);
    await _saveAndReschedule(updated);
  }

  Future<void> _sendFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: 'bazhanau.arthur@gmail.com',
      queryParameters: {'subject': l10n.aboutFeedback},
    );
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.feedbackNoEmail)),
      );
    }
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _RateDialog(),
    );
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
            Text(
              l10n.navSettings,
              style: AppTypography.heading.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // --- SCHEDULE ---
            _SectionHeader(label: l10n.sectionSchedule),
            _SectionCard(
              children: [
                _DayOffRow(
                  isDayOff: _isDayOff,
                  onToggle: _toggleDayOff,
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.date_range_outlined,
                  label: l10n.settingWorkDays,
                  value: _workDaysLabel(l10n),
                  onTap: () => showWorkDaysSheet(
                    context,
                    prefs: _prefs,
                    onWorkDayChanged: _toggleWorkDay,
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.access_time_outlined,
                  label: l10n.settingWorkHours,
                  value:
                      '${TimeUtils.formatHourMinute(_prefs.startHour, _prefs.startMinute)} - ${TimeUtils.formatHourMinute(_prefs.endHour, _prefs.endMinute)}',
                  onTap: () => _showWorkHoursSheet(context),
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.timer_outlined,
                  label: l10n.settingInterval,
                  value: l10n.nMinutes(_prefs.reminderIntervalMinutes),
                  onTap: () => showIntervalSheet(
                    context,
                    prefs: _prefs,
                    onIntervalChanged: _updateInterval,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- NOTIFICATIONS ---
            _SectionHeader(label: l10n.sectionNotifications),
            _SectionCard(
              children: [
                SettingsRow(
                  icon: Icons.adjust,
                  label: l10n.settingDailyGoal,
                  value: l10n.nMovements(_prefs.dailyGoal),
                  onTap: () => showGoalSheet(
                    context,
                    prefs: _prefs,
                    onGoalChanged: _updateGoal,
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: l10n.settingNotificationStyle,
                  value: _genderLabel(l10n),
                  onTap: () => showGenderSheet(
                    context,
                    prefs: _prefs,
                    onGenderChanged: _updateGender,
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.send_outlined,
                  label: l10n.settingTestNotification,
                  onTap: () async {
                    await NotificationService.showHourlyNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.testNotificationSent),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GENERAL ---
            _SectionHeader(label: l10n.sectionGeneral),
            _SectionCard(
              children: [
                SettingsRow(
                  icon: Icons.language_outlined,
                  label: l10n.settingLanguage,
                  value: _currentLanguageLabel(l10n),
                  onTap: () => showLanguageSheet(context),
                ),
                Divider(height: 1, color: colors.divider),
                const _ThemeRow(),
              ],
            ),
            const SizedBox(height: 24),

            // --- ABOUT ---
            _SectionHeader(label: l10n.sectionAbout),
            _SectionCard(
              children: [
                SettingsRow(
                  icon: Icons.info_outline,
                  label: l10n.aboutVersion,
                  value: appVersion,
                  showChevron: false,
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.star_outline,
                  label: l10n.aboutRateApp,
                  onTap: () => _showRateDialog(context),
                ),
                Divider(height: 1, color: colors.divider),
                SettingsRow(
                  icon: Icons.mail_outline,
                  label: l10n.aboutFeedback,
                  trailingIcon: Icons.open_in_new,
                  onTap: () => _sendFeedback(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _workDaysLabel(AppLocalizations l10n) =>
      TimeUtils.formatWorkDaysLabel(_prefs, l10n);

  String _genderLabel(AppLocalizations l10n) {
    return switch (_prefs.notificationGender) {
      NotificationGender.neutral => l10n.genderNeutralShort,
      NotificationGender.male => l10n.genderMaleShort,
      NotificationGender.female => l10n.genderFemaleShort,
    };
  }

  String _currentLanguageLabel(AppLocalizations l10n) {
    final code = Localizations.localeOf(context).languageCode;
    return switch (code) {
      'ru' => l10n.languageRu,
      'en' => l10n.languageEn,
      'be' => l10n.languageBe,
      _ => l10n.languageSystem,
    };
  }

  void _showWorkHoursSheet(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    showSheet(
      context,
      (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingWorkHours,
              style:
                  AppTypography.cardTitle.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _WorkHoursButton(
                    label: l10n.timeChipStart,
                    time: TimeUtils.formatHourMinute(
                        _prefs.startHour, _prefs.startMinute),
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      pickTime(
                        context,
                        _prefs.startHour,
                        _prefs.startMinute,
                        (v) => _updateTime(v, isStart: true),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WorkHoursButton(
                    label: l10n.timeChipEnd,
                    time: TimeUtils.formatHourMinute(
                        _prefs.endHour, _prefs.endMinute),
                    color: AppColors.endColor,
                    onTap: () {
                      Navigator.pop(ctx);
                      pickTime(
                        context,
                        _prefs.endHour,
                        _prefs.endMinute,
                        (v) => _updateTime(v, isStart: false),
                      );
                    },
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

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: AppTypography.sectionLabel.copyWith(color: colors.textMuted),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Icon(Icons.palette_outlined, size: 20, color: colors.textMuted),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.settingTheme,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          const _ThemeSegment(),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment();

  static const _modes = [ThemeMode.system, ThemeMode.dark, ThemeMode.light];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.themeSystem, l10n.themeDark, l10n.themeLight];
    final currentMode = HourlyReminderApp.getThemeMode(context);
    final activeIndex = _modes.indexOf(currentMode);

    return Container(
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            Semantics(
              button: true,
              selected: i == activeIndex,
              label: labels[i],
              child: GestureDetector(
                onTap: () => HourlyReminderApp.setThemeMode(context, _modes[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == activeIndex
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    labels[i],
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      color: i == activeIndex
                          ? Colors.white
                          : colors.textSecondary,
                      fontWeight:
                          i == activeIndex ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkHoursButton extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  final VoidCallback onTap;

  const _WorkHoursButton({
    required this.label,
    required this.time,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTypography.cardTitle.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayOffRow extends StatelessWidget {
  final bool isDayOff;
  final VoidCallback onToggle;

  const _DayOffRow({
    required this.isDayOff,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Icon(
            isDayOff ? Icons.bedtime : Icons.bedtime_outlined,
            size: 20,
            color: isDayOff ? AppColors.endColor : colors.textMuted,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.dayOffButton,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          Switch(
            value: isDayOff,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.endColor,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _RateDialog extends StatefulWidget {
  const _RateDialog();

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  int _rating = 0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: colors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.rateTitle,
              style: AppTypography.cardTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _submitted ? l10n.rateThanks : l10n.rateMessage,
              style: AppTypography.label.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                final filled = starIndex <= _rating;
                return GestureDetector(
                  onTap: _submitted
                      ? null
                      : () => setState(() => _rating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey('$starIndex-$filled'),
                        size: 40,
                        color: filled ? AppColors.primary : colors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (!_submitted) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.rateCancel,
                        style: AppTypography.button.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: _rating == 0
                          ? null
                          : () {
                              // UX-only - no backend submission in this version.
                              setState(() => _submitted = true);
                              Future.delayed(
                                const Duration(milliseconds: 800),
                                () {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            _rating > 0 ? AppColors.primary : colors.divider,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.rateSend,
                        style: AppTypography.button.copyWith(
                          color: _rating > 0 ? Colors.white : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
