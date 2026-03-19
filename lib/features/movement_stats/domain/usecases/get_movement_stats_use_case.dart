import '../../../movement/domain/entities/movement_event.dart';
import '../entities/movement_stats.dart';

class GetMovementStatsUseCase {
  MovementStats call({
    required List<MovementEvent> events,
    required DateTime now,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    // Group events by date
    final byDate = <DateTime, List<MovementEvent>>{};
    for (final e in events) {
      final date = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      byDate.putIfAbsent(date, () => []).add(e);
    }

    // Today's stats
    final todayEvents = byDate[today] ?? [];
    final todayStats = _buildDailyStats(today, todayEvents);

    // Last 7 work days (excluding today, going backward)
    final workDays = _lastWorkDays(
      today,
      count: 7,
      workOnSaturday: workOnSaturday,
      workOnSunday: workOnSunday,
    );
    final weeklyStats = workDays.map((date) {
      final dayEvents = byDate[date] ?? [];
      return _buildDailyStats(date, dayEvents);
    }).toList();

    // Streak: consecutive work days with at least 1 movement
    final streak = _computeStreak(
      byDate: byDate,
      today: today,
      workOnSaturday: workOnSaturday,
      workOnSunday: workOnSunday,
    );

    // All-time averages
    final totalMovements = events.length;
    final allTimeAverageReaction = totalMovements > 0
        ? Duration(
            milliseconds: events
                    .map((e) => e.reactionTime.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                totalMovements)
        : Duration.zero;
    final allTimeAverageSedentary = totalMovements > 0
        ? Duration(
            milliseconds: events
                    .map((e) => e.sedentaryDuration.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                totalMovements)
        : Duration.zero;

    return MovementStats(
      today: todayStats,
      weeklyStats: weeklyStats,
      streak: streak,
      totalMovements: totalMovements,
      allTimeAverageReaction: allTimeAverageReaction,
      allTimeAverageSedentary: allTimeAverageSedentary,
    );
  }

  DailyStats _buildDailyStats(DateTime date, List<MovementEvent> events) {
    if (events.isEmpty) {
      return DailyStats(
        date: date,
        movementCount: 0,
        totalSedentaryTime: Duration.zero,
        averageReactionTime: Duration.zero,
      );
    }

    final totalSedentary = events
        .map((e) => e.sedentaryDuration.inMilliseconds)
        .reduce((a, b) => a + b);
    final avgReaction = events
            .map((e) => e.reactionTime.inMilliseconds)
            .reduce((a, b) => a + b) ~/
        events.length;

    return DailyStats(
      date: date,
      movementCount: events.length,
      totalSedentaryTime: Duration(milliseconds: totalSedentary),
      averageReactionTime: Duration(milliseconds: avgReaction),
    );
  }

  List<DateTime> _lastWorkDays(
    DateTime today, {
    required int count,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    final result = <DateTime>[];
    var date = today.subtract(const Duration(days: 1));
    while (result.length < count) {
      if (_isWorkDay(date, workOnSaturday, workOnSunday)) {
        result.add(date);
      }
      date = date.subtract(const Duration(days: 1));
    }
    return result.reversed.toList();
  }

  bool _isWorkDay(DateTime date, bool workOnSaturday, bool workOnSunday) {
    if (date.weekday == DateTime.saturday) return workOnSaturday;
    if (date.weekday == DateTime.sunday) return workOnSunday;
    return true;
  }

  StreakInfo _computeStreak({
    required Map<DateTime, List<MovementEvent>> byDate,
    required DateTime today,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    var current = 0;
    var best = 0;

    // Check if today counts (has events)
    var date = today;
    if (byDate.containsKey(date) && (byDate[date]?.isNotEmpty ?? false)) {
      current = 1;
    } else {
      // Today doesn't count yet, but don't break streak if today is a work day
      // that hasn't ended. Start checking from yesterday.
      date = today.subtract(const Duration(days: 1));
      // Skip non-work days
      while (!_isWorkDay(date, workOnSaturday, workOnSunday)) {
        date = date.subtract(const Duration(days: 1));
      }
      if (byDate.containsKey(date) && (byDate[date]?.isNotEmpty ?? false)) {
        current = 1;
        date = date.subtract(const Duration(days: 1));
      } else {
        // No streak at all
        return StreakInfo(currentStreak: 0, bestStreak: _findBestStreak(
          byDate: byDate,
          workOnSaturday: workOnSaturday,
          workOnSunday: workOnSunday,
        ));
      }
    }

    // Walk backward from the day before `date`
    if (date == today) {
      date = today.subtract(const Duration(days: 1));
    }
    while (true) {
      // Skip non-work days
      while (!_isWorkDay(date, workOnSaturday, workOnSunday)) {
        date = date.subtract(const Duration(days: 1));
      }
      if (byDate.containsKey(date) && (byDate[date]?.isNotEmpty ?? false)) {
        current++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    best = _findBestStreak(
      byDate: byDate,
      workOnSaturday: workOnSaturday,
      workOnSunday: workOnSunday,
    );
    if (current > best) best = current;

    return StreakInfo(currentStreak: current, bestStreak: best);
  }

  int _findBestStreak({
    required Map<DateTime, List<MovementEvent>> byDate,
    required bool workOnSaturday,
    required bool workOnSunday,
  }) {
    if (byDate.isEmpty) return 0;

    final sortedDates = byDate.keys.toList()..sort();
    var best = 0;
    var current = 0;

    DateTime? prevWorkDay;
    for (final date in sortedDates) {
      if (byDate[date]?.isEmpty ?? true) continue;
      if (!_isWorkDay(date, workOnSaturday, workOnSunday)) continue;

      if (prevWorkDay == null) {
        current = 1;
      } else {
        // Check if this date is the next work day after prevWorkDay
        var expected = prevWorkDay.add(const Duration(days: 1));
        while (!_isWorkDay(expected, workOnSaturday, workOnSunday)) {
          expected = expected.add(const Duration(days: 1));
        }
        if (date == expected) {
          current++;
        } else {
          current = 1;
        }
      }
      if (current > best) best = current;
      prevWorkDay = date;
    }

    return best;
  }
}
