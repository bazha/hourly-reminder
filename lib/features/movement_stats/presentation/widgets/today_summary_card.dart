import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_utils.dart';
import '../../domain/entities/movement_stats.dart';

class TodaySummaryCard extends StatelessWidget {
  final DailyStats today;

  const TodaySummaryCard({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.cardBorder),
      ),
      color: colors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сегодня',
              style: AppTypography.cardTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Разминок',
                    value: '${today.movementCount}',
                    color: AppColors.startColor,
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: 'Сидел',
                    value: TimeUtils.formatDuration(today.totalSedentaryTime),
                    color: AppColors.endColor,
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: 'Реакция',
                    value: TimeUtils.formatDuration(today.averageReactionTime),
                    color: colors.accent,
                    colors: colors,
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppColors colors;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.statNumber.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
