import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_preferences.dart';
import '../../widgets/work_hours_clock.dart';
import '../../core/utils/time_utils.dart';

class WorkHoursCard extends StatelessWidget {
  const WorkHoursCard({
    super.key,
    required this.prefs,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final UserPreferences prefs;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;

  Future<void> _pickTime(
    BuildContext context,
    int currentHour,
    int currentMinute,
    ValueChanged<double> onChanged,
  ) async {
    final colors = AppColors.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                surface: colors.pickerBg,
                onSurface: colors.pickerText,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onChanged(picked.hour + picked.minute / 60.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'РАБОЧИЕ ЧАСЫ',
              style: AppTypography.sectionLabel.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
        ),
        WorkHoursClock(
          startTime: prefs.startTime,
          endTime: prefs.endTime,
          size: 220,
          onStartTimeChanged: onStartChanged,
          onEndTimeChanged: onEndChanged,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeChip(
              dotColor: AppColors.startColor,
              label: 'Начало',
              time: TimeUtils.formatHourMinute(
                  prefs.startHour, prefs.startMinute),
              onTap: () => _pickTime(
                context,
                prefs.startHour,
                prefs.startMinute,
                onStartChanged,
              ),
              colors: colors,
            ),
            const SizedBox(width: 12),
            _TimeChip(
              dotColor: AppColors.endColor,
              label: 'Конец',
              time: TimeUtils.formatHourMinute(prefs.endHour, prefs.endMinute),
              onTap: () => _pickTime(
                context,
                prefs.endHour,
                prefs.endMinute,
                onEndChanged,
              ),
              colors: colors,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String time;
  final VoidCallback onTap;
  final AppColors colors;

  const _TimeChip({
    required this.dotColor,
    required this.label,
    required this.time,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label $time',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$label $time',
                style: AppTypography.label.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
