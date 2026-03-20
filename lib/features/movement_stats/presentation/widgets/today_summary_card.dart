import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/movement_stats.dart';

class TodaySummaryCard extends StatelessWidget {
  final DailyStats today;
  final int dailyGoal;

  const TodaySummaryCard({
    super.key,
    required this.today,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final goalMet = today.movementCount >= dailyGoal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.fitness_center,
            label: l10n.metricMovements,
            value: '${today.movementCount}/$dailyGoal',
            accentColor: goalMet ? AppColors.startColor : colors.accent,
            colors: colors,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.event_seat_outlined,
            label: l10n.metricSedentary,
            value: TimeUtils.formatDuration(today.totalSedentaryTime, l10n),
            accentColor: AppColors.endColor,
            colors: colors,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.bolt_outlined,
            label: l10n.metricReaction,
            value: TimeUtils.formatDuration(today.averageReactionTime, l10n),
            accentColor: colors.accent,
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final AppColors colors;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: accentColor),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style:
                          AppTypography.statMedium.copyWith(color: accentColor),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTypography.sectionLabel.copyWith(
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
