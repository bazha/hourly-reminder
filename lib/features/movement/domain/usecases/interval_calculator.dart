import '../entities/movement_event.dart';

class IntervalCalculator {
  static const _fastReactionThreshold = Duration(minutes: 3);
  static const _minimumInterval = Duration(minutes: 10);

  /// Computes the next reminder interval based on reaction time and source.
  ///
  /// For notification responses, scales proportionally with [baseIntervalMinutes]:
  /// - Fast reaction (<=3 min): base * 0.5
  /// - Slow reaction (>3 min): base * 0.75
  /// - Minimum: 10 minutes
  ///
  /// For manual movement, returns the full base interval since the user
  /// proactively moved without waiting for a notification.
  static Duration compute(
    Duration reactionTime, {
    int baseIntervalMinutes = 60,
    MovementSource source = MovementSource.notification,
  }) {
    if (source == MovementSource.manual) {
      return Duration(minutes: baseIntervalMinutes);
    }
    final factor = reactionTime <= _fastReactionThreshold ? 0.5 : 0.75;
    final minutes = (baseIntervalMinutes * factor).round();
    final result = Duration(minutes: minutes);
    return result < _minimumInterval ? _minimumInterval : result;
  }
}
