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

    test('fromEntity preserves all fields', () {
      final model = MovementEventModel.fromEntity(entity);

      expect(model.id, 'test-1');
      expect(model.timestampMillis, entity.timestamp.millisecondsSinceEpoch);
      expect(model.sedentaryDurationMillis, 75 * 60 * 1000);
      expect(model.reactionTimeMillis, 150 * 1000);
      expect(model.source, 'notification');
    });

    test('toEntity preserves all fields', () {
      final model = MovementEventModel.fromEntity(entity);
      final restored = model.toEntity();

      expect(restored.id, entity.id);
      expect(restored.timestamp, entity.timestamp);
      expect(restored.sedentaryDuration, entity.sedentaryDuration);
      expect(restored.reactionTime, entity.reactionTime);
      expect(restored.source, entity.source);
    });

    test('JSON round-trip preserves all fields', () {
      final model = MovementEventModel.fromEntity(entity);
      final json = model.toJson();
      final restored = MovementEventModel.fromJson(json);

      expect(restored.id, model.id);
      expect(restored.timestampMillis, model.timestampMillis);
      expect(restored.sedentaryDurationMillis, model.sedentaryDurationMillis);
      expect(restored.reactionTimeMillis, model.reactionTimeMillis);
      expect(restored.source, model.source);
    });

    test('fromEntity handles manual source', () {
      final manualEvent = MovementEvent(
        id: 'test-2',
        timestamp: DateTime(2026, 3, 16, 11, 0),
        sedentaryDuration: const Duration(minutes: 30),
        reactionTime: Duration.zero,
        source: MovementSource.manual,
      );

      final model = MovementEventModel.fromEntity(manualEvent);
      expect(model.source, 'manual');

      final restored = model.toEntity();
      expect(restored.source, MovementSource.manual);
    });

    test('toJson produces expected keys', () {
      final model = MovementEventModel.fromEntity(entity);
      final json = model.toJson();

      expect(json.containsKey('id'), true);
      expect(json.containsKey('timestampMillis'), true);
      expect(json.containsKey('sedentaryDurationMillis'), true);
      expect(json.containsKey('reactionTimeMillis'), true);
      expect(json.containsKey('source'), true);
      expect(json.length, 5);
    });
  });
}
