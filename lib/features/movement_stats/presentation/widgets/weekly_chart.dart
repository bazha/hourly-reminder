import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/movement_stats.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyStats> weeklyStats;
  final int dailyGoal;

  const WeeklyChart({
    super.key,
    required this.weeklyStats,
    required this.dailyGoal,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.thisWeek,
                  style: AppTypography.sectionLabel.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                if (weeklyStats.isNotEmpty)
                  Text(
                    _dateRange(),
                    style: AppTypography.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: weeklyStats.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noData,
                        style: TextStyle(color: colors.textMuted),
                      ),
                    )
                  : _WeeklyBarChart(
                      weeklyStats: weeklyStats, dailyGoal: dailyGoal),
            ),
          ],
        ),
      ),
    );
  }

  String _dateRange() {
    if (weeklyStats.isEmpty) return '';
    final first = weeklyStats.first.date;
    final last = weeklyStats.last.date;
    return '${first.day.toString().padLeft(2, '0')}.${first.month.toString().padLeft(2, '0')} - '
        '${last.day.toString().padLeft(2, '0')}.${last.month.toString().padLeft(2, '0')}';
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyStats> weeklyStats;
  final int dailyGoal;

  const _WeeklyBarChart({required this.weeklyStats, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final maxCount = weeklyStats
        .map((s) => s.movementCount)
        .fold(0, (a, b) => a > b ? a : b);
    final maxY = (maxCount > dailyGoal ? maxCount : dailyGoal).toDouble() + 2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.cardBg,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final count = rod.toY.toInt();
              return BarTooltipItem(
                '$count',
                TextStyle(
                    color: colors.textPrimary, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyStats.length) {
                  return const SizedBox.shrink();
                }
                final date = weeklyStats[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${TimeUtils.dayName(l10n, date.weekday)}\n${date.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: colors.textMuted,
                    ),
                  ),
                );
              },
              reservedSize: 36,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: dailyGoal.toDouble(),
              color: colors.textMuted.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [4, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                style: TextStyle(
                  fontSize: 9,
                  color: colors.textMuted,
                ),
                labelResolver: (_) => l10n.goalLine,
              ),
            ),
          ],
        ),
        barGroups: List.generate(weeklyStats.length, (i) {
          final count = weeklyStats[i].movementCount.toDouble();
          final isEmpty = count == 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: isEmpty ? 0.3 : count,
                color: isEmpty ? colors.divider : AppColors.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
