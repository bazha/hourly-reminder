import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общая статистика',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.startColor,
                ),
              ),
              Text(
                _streakLabel(streak.currentStreak),
                style: TextStyle(
                  fontSize: 12,
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
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: colors.textMuted,
                ),
              ),
              Text(
                'Лучшая серия',
                style: TextStyle(
                  fontSize: 12,
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
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
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
