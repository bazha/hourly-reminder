import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';
import 'package:hourly_reminder/features/movement/domain/repositories/movement_repository.dart';

class FakeMovementRepository implements MovementRepository {
  MovementEvent? savedEvent;
  DateTime? sedentaryStartTime;
  DateTime? lastNotificationSentTime;
  DateTime? updatedSedentaryStartTime;
  List<MovementEvent> events;

  FakeMovementRepository([this.events = const []]);

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
