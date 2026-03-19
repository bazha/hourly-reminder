class DailyStats {
  final DateTime date;
  final int movementCount;
  final Duration totalSedentaryTime;
  final Duration averageReactionTime;

  const DailyStats({
    required this.date,
    required this.movementCount,
    required this.totalSedentaryTime,
    required this.averageReactionTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStats &&
          date == other.date &&
          movementCount == other.movementCount &&
          totalSedentaryTime == other.totalSedentaryTime &&
          averageReactionTime == other.averageReactionTime;

  @override
  int get hashCode =>
      Object.hash(date, movementCount, totalSedentaryTime, averageReactionTime);
}

class StreakInfo {
  final int currentStreak;
  final int bestStreak;

  const StreakInfo({
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakInfo &&
          currentStreak == other.currentStreak &&
          bestStreak == other.bestStreak;

  @override
  int get hashCode => Object.hash(currentStreak, bestStreak);
}

class MovementStats {
  final DailyStats today;
  final List<DailyStats> weeklyStats;
  final StreakInfo streak;
  final int totalMovements;
  final Duration allTimeAverageReaction;
  final Duration allTimeAverageSedentary;

  const MovementStats({
    required this.today,
    required this.weeklyStats,
    required this.streak,
    required this.totalMovements,
    required this.allTimeAverageReaction,
    required this.allTimeAverageSedentary,
  });

}
