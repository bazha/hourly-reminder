class IntervalCalculator {
  static const _fastReactionThreshold = Duration(minutes: 3);
  static const _shortInterval = Duration(minutes: 30);
  static const _longInterval = Duration(minutes: 45);

  static Duration compute(Duration reactionTime) {
    if (reactionTime <= _fastReactionThreshold) {
      return _shortInterval;
    }
    return _longInterval;
  }
}
