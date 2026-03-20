class IntervalCalculator {
  static const _fastReactionThreshold = Duration(minutes: 3);
  static const _minimumInterval = Duration(minutes: 10);

  /// Computes the next reminder interval based on reaction time.
  ///
  /// Scales proportionally with [baseIntervalMinutes]:
  /// - Fast reaction (<=3 min): base * 0.5
  /// - Slow reaction (>3 min): base * 0.75
  /// - Minimum: 10 minutes
  static Duration compute(
    Duration reactionTime, {
    int baseIntervalMinutes = 60,
  }) {
    final factor = reactionTime <= _fastReactionThreshold ? 0.5 : 0.75;
    final minutes = (baseIntervalMinutes * factor).round();
    final result = Duration(minutes: minutes);
    return result < _minimumInterval ? _minimumInterval : result;
  }
}
