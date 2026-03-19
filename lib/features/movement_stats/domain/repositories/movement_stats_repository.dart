import '../entities/movement_stats.dart';

abstract class MovementStatsRepository {
  Future<MovementStats> getStats();
}
