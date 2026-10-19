import '../../../movement/domain/entities/movement_event.dart';
import '../entities/movement_stats.dart';

class GetMovementStatsUseCase {
  MovementStats call({
    required List<MovementEvent> events,
    required DateTime now,
    required Set<int> workDays,
    required int dailyGoal,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    // Group events by date
    final byDate = <DateTime, List<MovementEvent>>{};
    for (final e in events) {
      final date =
          DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      byDate.putIfAbsent(date, () => []).add(e);
    }

    // Today's stats
    final todayEvents = byDate[today] ?? [];
    final todayStats = _buildDailyStats(today, todayEvents);

    // Last 7 work days (excluding today, going backward)
    final recentWorkDays = _lastWorkDays(
      today,
      count: 7,
      workDays: workDays,
    );
    final weeklyStats = recentWorkDays.map((date) {
      final dayEvents = byDate[date] ?? [];
      return _buildDailyStats(date, dayEvents);
    }).toList();

    // Streak: consecutive work days with at least 1 movement
    final streak = _computeStreak(
      byDate: byDate,
      today: today,
      workDays: workDays,
    );

    // All-time averages
    final totalMovements = events.length;
    final allTimeAverageReaction = totalMovements > 0
        ? Duration(
            milliseconds: events.fold<int>(
                    0, (sum, e) => sum + e.reactionTime.inMilliseconds) ~/
                totalMovements)
        : Duration.zero;
    final allTimeAverageSedentary = totalMovements > 0
        ? Duration(
            milliseconds: events.fold<int>(
                    0, (sum, e) => sum + e.sedentaryDuration.inMilliseconds) ~/
                totalMovements)
        : Duration.zero;

    return MovementStats(
      today: todayStats,
      weeklyStats: weeklyStats,
      streak: streak,
      totalMovements: totalMovements,
      allTimeAverageReaction: allTimeAverageReaction,
      allTimeAverageSedentary: allTimeAverageSedentary,
      dailyGoal: dailyGoal,
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

    final totalSedentary = events.fold<int>(
        0, (sum, e) => sum + e.sedentaryDuration.inMilliseconds);
    final avgReaction =
        events.fold<int>(0, (sum, e) => sum + e.reactionTime.inMilliseconds) ~/
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
    required Set<int> workDays,
  }) {
    // Guard: without this, the loop below spins forever.
    if (workDays.isEmpty) return [];
    final result = <DateTime>[];
    var date = today.subtract(const Duration(days: 1));
    final maxIterations = count * 7; // at worst one work day per week
    for (var i = 0; i < maxIterations && result.length < count; i++) {
      if (workDays.contains(date.weekday)) {
        result.add(date);
      }
      date = date.subtract(const Duration(days: 1));
    }
    return result.reversed.toList();
  }

  StreakInfo _computeStreak({
    required Map<DateTime, List<MovementEvent>> byDate,
    required DateTime today,
    required Set<int> workDays,
  }) {
    if (workDays.isEmpty) {
      return StreakInfo(currentStreak: 0, bestStreak: 0);
    }

    final best = _findBestStreak(byDate: byDate, workDays: workDays);
    var current = 0;

    // Check if today counts (work day with events).
    var date = today;
    if (workDays.contains(date.weekday) &&
        byDate.containsKey(date) &&
        (byDate[date]?.isNotEmpty ?? false)) {
      current = 1;
    } else {
      // Today doesn't count yet, but don't break streak if today is a work day
      // that hasn't ended. Start checking from yesterday.
      date = today.subtract(const Duration(days: 1));
      // Skip non-work days (at most 7 to cycle a full week).
      for (var skip = 0; skip < 7 && !workDays.contains(date.weekday); skip++) {
        date = date.subtract(const Duration(days: 1));
      }
      if (byDate.containsKey(date) && (byDate[date]?.isNotEmpty ?? false)) {
        current = 1;
        date = date.subtract(const Duration(days: 1));
      } else {
        return StreakInfo(currentStreak: 0, bestStreak: best);
      }
    }

    // Walk backward. When today counted (first branch above), date is still
    // `today` here, so step back one day. When yesterday counted (else
    // branch), date was already advanced past today.
    if (date == today) {
      date = today.subtract(const Duration(days: 1));
    }
    for (var safety = 0; safety < 365; safety++) {
      // Skip non-work days (at most 7 to cycle a full week).
      for (var skip = 0; skip < 7 && !workDays.contains(date.weekday); skip++) {
        date = date.subtract(const Duration(days: 1));
      }
      if (byDate.containsKey(date) && (byDate[date]?.isNotEmpty ?? false)) {
        current++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return StreakInfo(
      currentStreak: current,
      bestStreak: current > best ? current : best,
    );
  }

  int _findBestStreak({
    required Map<DateTime, List<MovementEvent>> byDate,
    required Set<int> workDays,
  }) {
    if (byDate.isEmpty) return 0;

    final sortedDates = byDate.keys.toList()..sort();
    var best = 0;
    var current = 0;

    DateTime? prevWorkDay;
    for (final date in sortedDates) {
      if (byDate[date]?.isEmpty ?? true) continue;
      if (!workDays.contains(date.weekday)) continue;

      if (prevWorkDay == null) {
        current = 1;
      } else {
        // Check if this date is the next work day after prevWorkDay
        var expected = prevWorkDay.add(const Duration(days: 1));
        for (var skip = 0;
            skip < 7 && !workDays.contains(expected.weekday);
            skip++) {
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
