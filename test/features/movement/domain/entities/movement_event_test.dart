import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';

void main() {
  group('MovementEvent', () {
    test('creates instance with all fields', () {
      final event = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );

      expect(event.id, 'evt-1');
      expect(event.timestamp, DateTime(2026, 3, 16, 10, 0));
      expect(event.sedentaryDuration, const Duration(hours: 1));
      expect(event.reactionTime, const Duration(minutes: 2));
      expect(event.source, MovementSource.notification);
    });

    test('equality holds for identical values', () {
      final a = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );
      final b = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when id differs', () {
      final a = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );
      final b = MovementEvent(
        id: 'evt-2',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );

      expect(a, isNot(equals(b)));
    });

    test('inequality when source differs', () {
      final a = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );
      final b = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.manual,
      );

      expect(a, isNot(equals(b)));
    });

    test('toString includes all fields', () {
      final event = MovementEvent(
        id: 'evt-1',
        timestamp: DateTime(2026, 3, 16, 10, 0),
        sedentaryDuration: const Duration(hours: 1),
        reactionTime: const Duration(minutes: 2),
        source: MovementSource.notification,
      );

      final str = event.toString();
      expect(str, contains('evt-1'));
      expect(str, contains('MovementEvent'));
    });
  });

  group('MovementSource', () {
    test('has notification and manual values', () {
      expect(MovementSource.values.length, 2);
      expect(MovementSource.values, contains(MovementSource.notification));
      expect(MovementSource.values, contains(MovementSource.manual));
    });
  });
}
