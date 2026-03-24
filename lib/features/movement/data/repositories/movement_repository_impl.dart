import '../../domain/entities/movement_event.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_local_datasource.dart';
import '../models/movement_event_model.dart';

class MovementRepositoryImpl implements MovementRepository {
  final MovementLocalDatasource _datasource;

  MovementRepositoryImpl(this._datasource);

  @override
  Future<List<MovementEvent>> getEvents() async {
    final models = await _datasource.getEvents();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveEvent(MovementEvent event) =>
      _datasource.saveEvent(MovementEventModel.fromEntity(event));

  @override
  Future<DateTime?> getSedentaryStartTime() async =>
      _datasource.getSedentaryStartTime();

  @override
  Future<void> setSedentaryStartTime(DateTime time) =>
      _datasource.setSedentaryStartTime(time);

  @override
  Future<DateTime?> getLastNotificationSentTime() async =>
      _datasource.getLastNotificationSentTime();

  @override
  Future<void> setLastNotificationSentTime(DateTime time) =>
      _datasource.setLastNotificationSentTime(time);
}
