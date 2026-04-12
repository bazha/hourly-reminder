import '../entities/movement_event.dart';
import '../repositories/movement_repository.dart';
import 'interval_calculator.dart';

typedef ScheduleCallback = Future<void> Function(Duration nextInterval);
typedef NowProvider = DateTime Function();
typedef IdGenerator = String Function();

class ConfirmMovementUseCase {
  final MovementRepository _repository;
  final ScheduleCallback _scheduleNext;
  final NowProvider _now;
  final IdGenerator _generateId;

  ConfirmMovementUseCase({
    required MovementRepository repository,
    required ScheduleCallback scheduleNext,
    NowProvider? now,
    IdGenerator? generateId,
  })  : _repository = repository,
        _scheduleNext = scheduleNext,
        _now = now ?? DateTime.now,
        _generateId = generateId ??
            (() => DateTime.now().microsecondsSinceEpoch.toString());

  Future<Duration> execute({
    MovementSource source = MovementSource.notification,
    int baseIntervalMinutes = 60,
  }) async {
    final now = _now();

    final notificationSentTime =
        await _repository.getLastNotificationSentTime();
    final sedentaryStartTime = await _repository.getSedentaryStartTime();

    final reactionTime = source == MovementSource.manual
        ? Duration.zero
        : (notificationSentTime != null
            ? now.difference(notificationSentTime)
            : Duration.zero);

    final sedentaryDuration = sedentaryStartTime != null
        ? now.difference(sedentaryStartTime)
        : Duration.zero;

    final event = MovementEvent(
      id: _generateId(),
      timestamp: now,
      sedentaryDuration: sedentaryDuration,
      reactionTime: reactionTime,
      source: source,
    );

    await _repository.saveEvent(event);

    final nextInterval = IntervalCalculator.compute(
      reactionTime,
      baseIntervalMinutes: baseIntervalMinutes,
      source: source,
    );

    await _scheduleNext(nextInterval);
    await _repository.setSedentaryStartTime(now);

    return nextInterval;
  }
}
