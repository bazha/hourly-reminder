import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/movement_stats.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyStats> weeklyStats;

  const WeeklyChart({super.key, required this.weeklyStats});

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
              'За неделю',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: weeklyStats.isEmpty
                  ? Center(
                      child: Text(
                        'Нет данных',
                        style: TextStyle(color: colors.textMuted),
                      ),
                    )
                  : _buildChart(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(AppColors colors) {
    final maxY = weeklyStats
        .map((s) => s.movementCount)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 1 ? 1 : maxY + 1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.cardBg,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final count = rod.toY.toInt();
              return BarTooltipItem(
                '$count',
                TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
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
                    '${_shortDayName(date.weekday)}\n${date.day}',
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
        barGroups: List.generate(weeklyStats.length, (i) {
          final count = weeklyStats[i].movementCount.toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count,
                color: AppColors.primary.withValues(alpha: count > 0 ? 1 : 0.3),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _shortDayName(int weekday) {
    const names = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return names[weekday - 1];
  }
}
