import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/data/models/movement_event_model.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';

void main() {
  group('MovementEventModel', () {
    final entity = MovementEvent(
      id: 'test-1',
      timestamp: DateTime(2026, 3, 16, 10, 30),
      sedentaryDuration: const Duration(hours: 1, minutes: 15),
      reactionTime: const Duration(minutes: 2, seconds: 30),
      source: MovementSource.notification,
    );

    test('entity -> model -> JSON -> model -> entity round-trip', () {
      final model = MovementEventModel.fromEntity(entity);

      // fromEntity maps fields correctly
      expect(model.id, 'test-1');
      expect(model.timestampMillis, entity.timestamp.millisecondsSinceEpoch);
      expect(model.source, 'notification');

      // JSON round-trip preserves all fields
      final json = model.toJson();
      expect(json.length, 5);
      final restored = MovementEventModel.fromJson(json).toEntity();

      expect(restored.id, entity.id);
      expect(restored.timestamp, entity.timestamp);
      expect(restored.sedentaryDuration, entity.sedentaryDuration);
      expect(restored.reactionTime, entity.reactionTime);
      expect(restored.source, entity.source);
    });

    test('handles manual source', () {
      final manualEvent = MovementEvent(
        id: 'test-2',
        timestamp: DateTime(2026, 3, 16, 11, 0),
        sedentaryDuration: const Duration(minutes: 30),
        reactionTime: Duration.zero,
        source: MovementSource.manual,
      );

      final model = MovementEventModel.fromEntity(manualEvent);
      expect(model.source, 'manual');
      expect(model.toEntity().source, MovementSource.manual);
    });
  });
}
