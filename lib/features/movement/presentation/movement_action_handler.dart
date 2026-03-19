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
      scheduleNext: (nextInterval) => alarmService.scheduleHourlyAlarm(),
    );

    await useCase.execute();
  }
}
