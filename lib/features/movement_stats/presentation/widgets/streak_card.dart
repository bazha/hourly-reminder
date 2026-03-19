import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_utils.dart';
import '../../domain/entities/movement_stats.dart';

class StreakCard extends StatelessWidget {
  final StreakInfo streak;
  final int totalMovements;
  final Duration allTimeAverageReaction;
  final Duration allTimeAverageSedentary;

  const StreakCard({
    super.key,
    required this.streak,
    required this.totalMovements,
    required this.allTimeAverageReaction,
    required this.allTimeAverageSedentary,
  });

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
              'Общая статистика',
              style: AppTypography.cardTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStreakRow(colors),
            const SizedBox(height: 16),
            Divider(color: colors.divider),
            const SizedBox(height: 12),
            _buildStatRow('Всего разминок', '$totalMovements', colors),
            const SizedBox(height: 8),
            _buildStatRow(
              'Ср. реакция',
              TimeUtils.formatDuration(allTimeAverageReaction),
              colors,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'Ср. время сидения',
              TimeUtils.formatDuration(allTimeAverageSedentary),
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakRow(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                '${streak.currentStreak}',
                style: AppTypography.statNumber.copyWith(
                  fontSize: 36,
                  color: AppColors.startColor,
                ),
              ),
              Text(
                _streakLabel(streak.currentStreak),
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${streak.bestStreak}',
                style: AppTypography.statNumber.copyWith(
                  fontSize: 36,
                  color: colors.textMuted,
                ),
              ),
              Text(
                'Лучшая серия',
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _streakLabel(int days) {
    final mod100 = days % 100;
    final mod10 = days % 10;
    if (mod10 == 1 && mod100 != 11) return 'день подряд';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дня подряд';
    }
    return 'дней подряд';
  }
}
