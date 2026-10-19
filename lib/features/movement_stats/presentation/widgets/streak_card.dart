import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StreakRow(streak: streak),
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 16),
            _StatRow(label: l10n.totalMovements, value: '$totalMovements'),
            const SizedBox(height: 12),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 12),
            _StatRow(
              label: l10n.avgReaction,
              value: TimeUtils.formatDuration(allTimeAverageReaction, l10n),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 12),
            _StatRow(
              label: l10n.avgSedentary,
              value: TimeUtils.formatDuration(allTimeAverageSedentary, l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final StreakInfo streak;

  const _StreakRow({required this.streak});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${streak.currentStreak}',
                style: AppTypography.statSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.streakDays(streak.currentStreak),
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.currentStreak,
                style: AppTypography.sectionLabel.copyWith(
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 60,
          color: colors.divider,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${streak.bestStreak}',
                style: AppTypography.statSmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.streakDays(streak.bestStreak),
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.bestStreak,
                style: AppTypography.sectionLabel.copyWith(
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
}
