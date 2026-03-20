import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/notification_service.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.prefs,
    required this.onToggleSaturday,
    required this.onToggleSunday,
    required this.onGenderChanged,
    required this.onGoalChanged,
    required this.onIntervalChanged,
  });

  final UserPreferences prefs;
  final ValueChanged<bool> onToggleSaturday;
  final ValueChanged<bool> onToggleSunday;
  final ValueChanged<NotificationGender> onGenderChanged;
  final ValueChanged<int> onGoalChanged;
  final ValueChanged<int> onIntervalChanged;

  String _workDaysLabel(AppLocalizations l10n) {
    if (prefs.workOnSaturday && prefs.workOnSunday) return l10n.workDaysMonSun;
    if (prefs.workOnSaturday) return l10n.workDaysMonSat;
    if (prefs.workOnSunday) return l10n.workDaysMonFriSun;
    return l10n.workDaysMonFri;
  }

  String _genderLabel(AppLocalizations l10n) {
    return switch (prefs.notificationGender) {
      NotificationGender.neutral => l10n.genderNeutralShort,
      NotificationGender.male => l10n.genderMaleShort,
      NotificationGender.female => l10n.genderFemaleShort,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.settingsLabel,
            style: AppTypography.sectionLabel.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
        _SettingsRow(
          icon: Icons.calendar_today_outlined,
          label: l10n.settingWorkDays,
          value: _workDaysLabel(l10n),
          colors: colors,
          onTap: () => _showWorkDaysSheet(context),
        ),
        Divider(height: 1, color: colors.divider),
        _SettingsRow(
          icon: Icons.flag_outlined,
          label: l10n.settingDailyGoal,
          value: l10n.nMovements(prefs.dailyGoal),
          colors: colors,
          onTap: () => _showGoalSheet(context),
        ),
        Divider(height: 1, color: colors.divider),
        _SettingsRow(
          icon: Icons.timer_outlined,
          label: l10n.settingInterval,
          value: l10n.nMinutes(prefs.reminderIntervalMinutes),
          colors: colors,
          onTap: () => _showIntervalSheet(context),
        ),
        Divider(height: 1, color: colors.divider),
        _SettingsRow(
          icon: Icons.notifications_outlined,
          label: l10n.settingNotificationStyle,
          value: _genderLabel(l10n),
          colors: colors,
          onTap: () => _showGenderSheet(context),
        ),
        Divider(height: 1, color: colors.divider),
        _SettingsRow(
          icon: Icons.language_outlined,
          label: l10n.settingLanguage,
          value: _currentLanguageLabel(context, l10n),
          colors: colors,
          onTap: () => _showLanguageSheet(context),
        ),
        Divider(height: 1, color: colors.divider),
        _SettingsRow(
          icon: Icons.send_outlined,
          label: l10n.settingTestNotification,
          colors: colors,
          onTap: () async {
            await NotificationService.showHourlyNotification();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.testNotificationSent),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.startColor,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  String _currentLanguageLabel(BuildContext context, AppLocalizations l10n) {
    final code = Localizations.localeOf(context).languageCode;
    return switch (code) {
      'ru' => l10n.languageRu,
      'en' => l10n.languageEn,
      'be' => l10n.languageBe,
      _ => l10n.languageSystem,
    };
  }

  void _showLanguageSheet(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (null, l10n.languageSystem),
      (const Locale('ru'), l10n.languageRu),
      (const Locale('en'), l10n.languageEn),
      (const Locale('be'), l10n.languageBe),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingLanguage,
              style:
                  AppTypography.cardTitle.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final (locale, label) = option;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  label,
                  style: AppTypography.bodyMedium
                      .copyWith(color: colors.textPrimary),
                ),
                onTap: () {
                  HourlyReminderApp.setLocale(context, locale);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showWorkDaysSheet(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingWorkDays,
              style:
                  AppTypography.cardTitle.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 20),
            _SheetToggleRow(
              label: l10n.saturday,
              value: prefs.workOnSaturday,
              onChanged: (v) {
                onToggleSaturday(v);
                Navigator.pop(ctx);
              },
              colors: colors,
            ),
            const SizedBox(height: 12),
            _SheetToggleRow(
              label: l10n.sunday,
              value: prefs.workOnSunday,
              onChanged: (v) {
                onToggleSunday(v);
                Navigator.pop(ctx);
              },
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalSheet(BuildContext context) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _IntervalPicker(
        currentInterval: prefs.reminderIntervalMinutes,
        onChanged: onIntervalChanged,
        colors: colors,
      ),
    );
  }

  void _showGoalSheet(BuildContext context) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _GoalPicker(
        currentGoal: prefs.dailyGoal,
        onChanged: onGoalChanged,
        colors: colors,
      ),
    );
  }

  void _showGenderSheet(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingNotificationStyle,
              style:
                  AppTypography.cardTitle.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            ...NotificationGender.values.map((gender) {
              final label = switch (gender) {
                NotificationGender.neutral => l10n.genderNeutralFull,
                NotificationGender.male => l10n.genderMaleFull,
                NotificationGender.female => l10n.genderFemaleFull,
              };
              final example = switch (gender) {
                NotificationGender.neutral => l10n.genderNeutralExample,
                NotificationGender.male => l10n.genderMaleExample,
                NotificationGender.female => l10n.genderFemaleExample,
              };
              final isSelected = prefs.notificationGender == gender;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  example,
                  style:
                      AppTypography.label.copyWith(color: colors.textSecondary),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  onGenderChanged(gender);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final AppColors colors;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textMuted),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style:
                    AppTypography.label.copyWith(color: colors.textSecondary),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SheetToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors colors;

  const _SheetToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.startColor,
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }
}

class _GoalPicker extends StatefulWidget {
  final int currentGoal;
  final ValueChanged<int> onChanged;
  final AppColors colors;

  const _GoalPicker({
    required this.currentGoal,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<_GoalPicker> createState() => _GoalPickerState();
}

class _GoalPickerState extends State<_GoalPicker> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentGoal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.settingDailyGoal,
            style: AppTypography.cardTitle.copyWith(
              color: widget.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.nMovements(_value.round()),
            style: AppTypography.statMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _value,
            min: 1,
            max: 15,
            divisions: 14,
            label: '${_value.round()}',
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.primary,
            inactiveColor: widget.colors.sliderInactiveTrack,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1',
                  style: AppTypography.label
                      .copyWith(color: widget.colors.textMuted)),
              Text('15',
                  style: AppTypography.label
                      .copyWith(color: widget.colors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onChanged(_value.round());
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.done,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalPicker extends StatefulWidget {
  final int currentInterval;
  final ValueChanged<int> onChanged;
  final AppColors colors;

  const _IntervalPicker({
    required this.currentInterval,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<_IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<_IntervalPicker> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentInterval.toDouble();
  }

  String _formatInterval(int minutes) {
    if (minutes >= 60 && minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours ч';
    }
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours ч $mins мин';
    }
    return '$minutes мин';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.settingInterval,
            style: AppTypography.cardTitle.copyWith(
              color: widget.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatInterval(_value.round()),
            style: AppTypography.statMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _value,
            min: 15,
            max: 120,
            divisions: 7,
            label: _formatInterval(_value.round()),
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.primary,
            inactiveColor: widget.colors.sliderInactiveTrack,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.intervalSliderMin,
                  style: AppTypography.label
                      .copyWith(color: widget.colors.textMuted)),
              Text(AppLocalizations.of(context)!.intervalSliderMax,
                  style: AppTypography.label
                      .copyWith(color: widget.colors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onChanged(_value.round());
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.done,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
