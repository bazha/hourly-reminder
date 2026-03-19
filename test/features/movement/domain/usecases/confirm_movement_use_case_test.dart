import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';
import 'package:hourly_reminder/features/movement/domain/repositories/movement_repository.dart';
import 'package:hourly_reminder/features/movement/domain/usecases/confirm_movement_use_case.dart';

class FakeMovementRepository implements MovementRepository {
  MovementEvent? savedEvent;
  DateTime? sedentaryStartTime;
  DateTime? lastNotificationSentTime;
  DateTime? updatedSedentaryStartTime;
  List<MovementEvent> events = [];

  @override
  Future<List<MovementEvent>> getEvents() async => events;

  @override
  Future<void> saveEvent(MovementEvent event) async {
    savedEvent = event;
  }

  @override
  Future<DateTime?> getSedentaryStartTime() async => sedentaryStartTime;

  @override
  Future<void> setSedentaryStartTime(DateTime time) async {
    updatedSedentaryStartTime = time;
  }

  @override
  Future<DateTime?> getLastNotificationSentTime() async =>
      lastNotificationSentTime;

  @override
  Future<void> setLastNotificationSentTime(DateTime time) async {
    lastNotificationSentTime = time;
  }
}

void main() {
  late FakeMovementRepository repository;
  Duration? scheduledInterval;

  setUp(() {
    repository = FakeMovementRepository();
    scheduledInterval = null;
  });

  ConfirmMovementUseCase createUseCase({
    required DateTime now,
    String id = 'test-id',
  }) {
    return ConfirmMovementUseCase(
      repository: repository,
      scheduleNext: (interval) async {
        scheduledInterval = interval;
      },
      now: () => now,
      generateId: () => id,
    );
  }

  group('ConfirmMovementUseCase', () {
    test('returns 30 min interval for fast reaction (<=3 min)', () async {
      final notifTime = DateTime(2026, 3, 16, 10, 0);
      final now = DateTime(2026, 3, 16, 10, 2); // 2 min later
      repository.lastNotificationSentTime = notifTime;
      repository.sedentaryStartTime = DateTime(2026, 3, 16, 9, 0);

      final useCase = createUseCase(now: now);
      final result = await useCase.execute();

      expect(result, const Duration(minutes: 30));
      expect(scheduledInterval, const Duration(minutes: 30));
    });

    test('returns 45 min interval for slow reaction (>3 min)', () async {
      final notifTime = DateTime(2026, 3, 16, 10, 0);
      final now = DateTime(2026, 3, 16, 10, 5); // 5 min later
      repository.lastNotificationSentTime = notifTime;
      repository.sedentaryStartTime = DateTime(2026, 3, 16, 9, 0);

      final useCase = createUseCase(now: now);
      final result = await useCase.execute();

      expect(result, const Duration(minutes: 45));
      expect(scheduledInterval, const Duration(minutes: 45));
    });

    test('persists correct MovementEvent', () async {
      final notifTime = DateTime(2026, 3, 16, 10, 0);
      final sedentaryStart = DateTime(2026, 3, 16, 9, 0);
      final now = DateTime(2026, 3, 16, 10, 1);
      repository.lastNotificationSentTime = notifTime;
      repository.sedentaryStartTime = sedentaryStart;

      final useCase = createUseCase(now: now, id: 'evt-1');
      await useCase.execute();

      final event = repository.savedEvent!;
      expect(event.id, 'evt-1');
      expect(event.timestamp, now);
      expect(event.reactionTime, const Duration(minutes: 1));
      expect(event.sedentaryDuration, const Duration(hours: 1, minutes: 1));
      expect(event.source, MovementSource.notification);
    });

    test('resets sedentary start time to now', () async {
      final now = DateTime(2026, 3, 16, 10, 2);
      repository.lastNotificationSentTime = DateTime(2026, 3, 16, 10, 0);
      repository.sedentaryStartTime = DateTime(2026, 3, 16, 9, 0);

      final useCase = createUseCase(now: now);
      await useCase.execute();

      expect(repository.updatedSedentaryStartTime, now);
    });

    test('handles missing notification sent time gracefully', () async {
      final now = DateTime(2026, 3, 16, 10, 0);
      repository.lastNotificationSentTime = null;
      repository.sedentaryStartTime = DateTime(2026, 3, 16, 9, 0);

      final useCase = createUseCase(now: now);
      final result = await useCase.execute();

      // Zero reaction time -> 30 min
      expect(result, const Duration(minutes: 30));
      expect(repository.savedEvent!.reactionTime, Duration.zero);
    });

    test('handles missing sedentary start time gracefully', () async {
      final now = DateTime(2026, 3, 16, 10, 2);
      repository.lastNotificationSentTime = DateTime(2026, 3, 16, 10, 0);
      repository.sedentaryStartTime = null;

      final useCase = createUseCase(now: now);
      await useCase.execute();

      expect(repository.savedEvent!.sedentaryDuration, Duration.zero);
    });
  });
}
