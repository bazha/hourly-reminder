import '../entities/movement_event.dart';

abstract class MovementRepository {
  Future<List<MovementEvent>> getEvents();
  Future<void> saveEvent(MovementEvent event);
  Future<DateTime?> getSedentaryStartTime();
  Future<void> setSedentaryStartTime(DateTime time);
  Future<DateTime?> getLastNotificationSentTime();
  Future<void> setLastNotificationSentTime(DateTime time);
}
