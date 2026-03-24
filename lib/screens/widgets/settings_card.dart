import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

void showSheet(BuildContext context, WidgetBuilder builder) {
  final colors = AppColors.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: colors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: builder,
  );
}

String formatInterval(int minutes, AppLocalizations l10n) {
  if (minutes >= 60 && minutes % 60 == 0) {
    return l10n.durationHours(minutes ~/ 60);
  }
  if (minutes > 60) {
    return l10n.durationHoursMinutes(minutes ~/ 60, minutes % 60);
  }
  return l10n.nMinutes(minutes);
}

void showLanguageSheet(BuildContext context) {
  final colors = AppColors.of(context);
  final l10n = AppLocalizations.of(context)!;
  final options = [
    (null, l10n.languageSystem),
    (const Locale('ru'), l10n.languageRu),
    (const Locale('en'), l10n.languageEn),
    (const Locale('be'), l10n.languageBe),
  ];
  showSheet(
    context,
    (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingLanguage,
            style: AppTypography.cardTitle.copyWith(color: colors.textPrimary),
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

void showWorkDaysSheet(
  BuildContext context, {
  required UserPreferences prefs,
  required Future<void> Function(int weekday, bool value) onWorkDayChanged,
}) {
  final colors = AppColors.of(context);
  final l10n = AppLocalizations.of(context)!;
  final dayNames = [
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday,
  ];
  showSheet(
    context,
    (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingWorkDays,
            style: AppTypography.cardTitle.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          for (int weekday = 1; weekday <= 7; weekday++)
            _SheetToggleRow(
              label: dayNames[weekday - 1],
              value: prefs.isWorkDay(weekday),
              onChanged: (v) async {
                await onWorkDayChanged(weekday, v);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              colors: colors,
            ),
        ],
      ),
    ),
  );
}

void showIntervalSheet(
  BuildContext context, {
  required UserPreferences prefs,
  required ValueChanged<int> onIntervalChanged,
}) {
  final l10n = AppLocalizations.of(context)!;
  showSheet(
    context,
    (_) => SliderPicker(
      title: l10n.settingInterval,
      currentValue: prefs.reminderIntervalMinutes,
      min: 15,
      max: 120,
      divisions: 7,
      formatValue: (v) => formatInterval(v, l10n),
      minLabel: l10n.intervalSliderMin,
      maxLabel: l10n.intervalSliderMax,
      onChanged: onIntervalChanged,
      colors: AppColors.of(context),
    ),
  );
}

void showGoalSheet(
  BuildContext context, {
  required UserPreferences prefs,
  required ValueChanged<int> onGoalChanged,
}) {
  final l10n = AppLocalizations.of(context)!;
  showSheet(
    context,
    (_) => SliderPicker(
      title: l10n.settingDailyGoal,
      currentValue: prefs.dailyGoal,
      min: 1,
      max: 15,
      divisions: 14,
      formatValue: (v) => l10n.nMovements(v),
      minLabel: '1',
      maxLabel: '15',
      onChanged: onGoalChanged,
      colors: AppColors.of(context),
    ),
  );
}

void showGenderSheet(
  BuildContext context, {
  required UserPreferences prefs,
  required ValueChanged<NotificationGender> onGenderChanged,
}) {
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
            l10n.settingNotificationStyle,
            style: AppTypography.cardTitle.copyWith(color: colors.textPrimary),
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
                  ? const Icon(Icons.check, color: AppColors.primary, size: 20)
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

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final AppColors colors;
  final VoidCallback? onTap;
  final bool showChevron;
  final IconData? trailingIcon;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.colors,
    this.onTap,
    this.showChevron = true,
    this.trailingIcon,
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
            if (trailingIcon != null)
              Icon(trailingIcon, size: 18, color: colors.textMuted)
            else if (showChevron)
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
          activeTrackColor: AppColors.primary,
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }
}

class SliderPicker extends StatefulWidget {
  final String title;
  final int currentValue;
  final double min;
  final double max;
  final int divisions;
  final String Function(int) formatValue;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<int> onChanged;
  final AppColors colors;

  const SliderPicker({
    super.key,
    required this.title,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.formatValue,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<SliderPicker> createState() => _SliderPickerState();
}

class _SliderPickerState extends State<SliderPicker> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTypography.cardTitle.copyWith(
              color: widget.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.formatValue(_value.round()),
            style: AppTypography.statMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.formatValue(_value.round()),
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.primary,
            inactiveColor: widget.colors.sliderInactiveTrack,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.minLabel,
                  style: AppTypography.label
                      .copyWith(color: widget.colors.textMuted)),
              Text(widget.maxLabel,
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
                l10n.done,
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
