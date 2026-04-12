import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
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
  bool _hasError = false;

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
          _hasError = false;
        });
      }
    } catch (e, stack) {
      debugPrint('StatsScreen: failed to load stats: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasError) {
      return SafeArea(child: _StatsErrorView(onRetry: _reload));
    }
    return SafeArea(
      child: _StatsContent(stats: _stats!, onRefresh: _loadStats),
    );
  }
}

class _StatsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _StatsErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.statsLoadError,
              style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final MovementStats stats;
  final Future<void> Function() onRefresh;

  const _StatsContent({required this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.navStats,
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
