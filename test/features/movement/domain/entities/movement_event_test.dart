import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';

void main() {
  final base = MovementEvent(
    id: 'evt-1',
    timestamp: DateTime(2026, 3, 16, 10, 0),
    sedentaryDuration: const Duration(hours: 1),
    reactionTime: const Duration(minutes: 2),
    source: MovementSource.notification,
  );

  test('creates instance with correct fields', () {
    expect(base.id, 'evt-1');
    expect(base.timestamp, DateTime(2026, 3, 16, 10, 0));
    expect(base.sedentaryDuration, const Duration(hours: 1));
    expect(base.reactionTime, const Duration(minutes: 2));
    expect(base.source, MovementSource.notification);
  });

  test('equality and hashCode work correctly', () {
    final same = MovementEvent(
      id: 'evt-1',
      timestamp: DateTime(2026, 3, 16, 10, 0),
      sedentaryDuration: const Duration(hours: 1),
      reactionTime: const Duration(minutes: 2),
      source: MovementSource.notification,
    );
    expect(base, equals(same));
    expect(base.hashCode, same.hashCode);

    // Different id
    final diffId = MovementEvent(
      id: 'evt-2',
      timestamp: base.timestamp,
      sedentaryDuration: base.sedentaryDuration,
      reactionTime: base.reactionTime,
      source: base.source,
    );
    expect(base, isNot(equals(diffId)));

    // Different source
    final diffSource = MovementEvent(
      id: base.id,
      timestamp: base.timestamp,
      sedentaryDuration: base.sedentaryDuration,
      reactionTime: base.reactionTime,
      source: MovementSource.manual,
    );
    expect(base, isNot(equals(diffSource)));
  });

  test('toString includes id', () {
    expect(base.toString(), contains('evt-1'));
  });
}
