import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/entities/movement_stats.dart';
import '../domain/repositories/movement_stats_repository.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/streak_card.dart';

class StatsScreen extends StatefulWidget {
  final MovementStatsRepository repository;
  final bool isActive;

  const StatsScreen({
    super.key,
    required this.repository,
    this.isActive = true,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  MovementStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(StatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.repository.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Не удалось загрузить статистику';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadStats();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    return _buildContent(colors);
  }

  Widget _buildContent(AppColors colors) {
    final stats = _stats!;
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика',
              style: AppTypography.heading.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            TodaySummaryCard(today: stats.today, dailyGoal: stats.dailyGoal),
            const SizedBox(height: 20),
            WeeklyChart(
              weeklyStats: stats.weeklyStats,
              dailyGoal: stats.dailyGoal,
            ),
            const SizedBox(height: 20),
            StreakCard(
              streak: stats.streak,
              totalMovements: stats.totalMovements,
              allTimeAverageReaction: stats.allTimeAverageReaction,
              allTimeAverageSedentary: stats.allTimeAverageSedentary,
            ),
          ],
        ),
      ),
    );
  }
}
