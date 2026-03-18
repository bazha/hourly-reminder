import '../../domain/entities/movement_event.dart';

class MovementEventModel {
  final String id;
  final int timestampMillis;
  final int sedentaryDurationMillis;
  final int reactionTimeMillis;
  final String source;

  const MovementEventModel({
    required this.id,
    required this.timestampMillis,
    required this.sedentaryDurationMillis,
    required this.reactionTimeMillis,
    required this.source,
  });

  factory MovementEventModel.fromEntity(MovementEvent event) {
    return MovementEventModel(
      id: event.id,
      timestampMillis: event.timestamp.millisecondsSinceEpoch,
      sedentaryDurationMillis: event.sedentaryDuration.inMilliseconds,
      reactionTimeMillis: event.reactionTime.inMilliseconds,
      source: event.source.name,
    );
  }

  MovementEvent toEntity() {
    return MovementEvent(
      id: id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMillis),
      sedentaryDuration: Duration(milliseconds: sedentaryDurationMillis),
      reactionTime: Duration(milliseconds: reactionTimeMillis),
      source: MovementSource.values.firstWhere(
        (s) => s.name == source,
        orElse: () => MovementSource.manual,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampMillis': timestampMillis,
      'sedentaryDurationMillis': sedentaryDurationMillis,
      'reactionTimeMillis': reactionTimeMillis,
      'source': source,
    };
  }

  factory MovementEventModel.fromJson(Map<String, dynamic> json) {
    return MovementEventModel(
      id: json['id'] as String,
      timestampMillis: json['timestampMillis'] as int,
      sedentaryDurationMillis: json['sedentaryDurationMillis'] as int,
      reactionTimeMillis: json['reactionTimeMillis'] as int,
      source: json['source'] as String,
    );
  }
}
