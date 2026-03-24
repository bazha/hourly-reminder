import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/time_utils.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final startTime =
        TimeUtils.formatHourMinute(prefs.startHour, prefs.startMinute);
    final endTime =
        TimeUtils.formatHourMinute(prefs.endHour, prefs.endMinute);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.workHoursLabel,
                style: AppTypography.sectionLabel.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeTap(
                  dotColor: AppColors.primary,
                  label: l10n.timeChipStart,
                  time: startTime,
                  onTap: () => _pickTime(
                    context,
                    prefs.startHour,
                    prefs.startMinute,
                    onStartChanged,
                  ),
                  colors: colors,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '\u2014',
                    style: AppTypography.statMedium.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
                _TimeTap(
                  dotColor: AppColors.endColor,
                  label: l10n.timeChipEnd,
                  time: endTime,
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
        ),
      ),
    );
  }
}

class _TimeTap extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String time;
  final VoidCallback onTap;
  final AppColors colors;

  const _TimeTap({
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
        child: Column(
          children: [
            Row(
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
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: AppTypography.statMedium.copyWith(
                    color: colors.textPrimary,
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
