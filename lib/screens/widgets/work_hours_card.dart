import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Рабочее время',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            WorkHoursClock(
              startTime: prefs.startTime,
              endTime: prefs.endTime,
              size: 250,
              onStartTimeChanged: onStartChanged,
              onEndTimeChanged: onEndChanged,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.startColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Начало: ${TimeUtils.formatHourMinute(prefs.startHour, prefs.startMinute)}',
                  style: const TextStyle(
                    color: AppColors.startColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.endColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Конец: ${TimeUtils.formatHourMinute(prefs.endHour, prefs.endMinute)}',
                  style: const TextStyle(
                    color: AppColors.endColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
