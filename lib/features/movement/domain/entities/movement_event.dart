enum MovementSource { notification, manual }

class MovementEvent {
  final String id;
  final DateTime timestamp;
  final Duration sedentaryDuration;
  final Duration reactionTime;
  final MovementSource source;

  const MovementEvent({
    required this.id,
    required this.timestamp,
    required this.sedentaryDuration,
    required this.reactionTime,
    required this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          sedentaryDuration == other.sedentaryDuration &&
          reactionTime == other.reactionTime &&
          source == other.source;

  @override
  int get hashCode => Object.hash(
        id,
        timestamp,
        sedentaryDuration,
        reactionTime,
        source,
      );

  @override
  String toString() =>
      'MovementEvent(id: $id, timestamp: $timestamp, '
      'sedentaryDuration: $sedentaryDuration, '
      'reactionTime: $reactionTime, source: $source)';
}
