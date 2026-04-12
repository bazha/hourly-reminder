import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/alarm_service.dart';
import '../data/datasources/movement_local_datasource.dart';
import '../data/repositories/movement_repository_impl.dart';
import '../domain/usecases/confirm_movement_use_case.dart';

class MovementActionHandler {
  static Future<void> handle() async {
    final prefs = await SharedPreferences.getInstance();
    final datasource = MovementLocalDatasource(prefs);
    final repository = MovementRepositoryImpl(datasource);
    final alarmService = AlarmService();

    final useCase = ConfirmMovementUseCase(
      repository: repository,
      // iOS limitation: flutter_local_notifications doesn't support replacing
      // the scheduled alarm with an adaptive interval. The computed nextInterval
      // is not applied; the standard hourly alarm is rescheduled instead.
      // On Android, AlreadyMovedReceiver handles adaptive intervals natively.
      scheduleNext: (_) => alarmService.scheduleHourlyAlarm(),
    );

    final intervalMinutes = prefs.getInt('reminder_interval_minutes') ?? 60;
    await useCase.execute(baseIntervalMinutes: intervalMinutes);
  }
}
