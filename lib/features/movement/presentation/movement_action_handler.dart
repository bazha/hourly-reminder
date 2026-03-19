import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/alarm_service.dart';
import '../../../services/storage_service.dart';
import '../data/datasources/movement_local_datasource.dart';
import '../data/repositories/movement_repository_impl.dart';
import '../domain/usecases/confirm_movement_use_case.dart';

class MovementActionHandler {
  static Future<void> handle() async {
    if (!StorageService.isInitialized) {
      await StorageService.initialize();
    }

    final prefs = await SharedPreferences.getInstance();
    final datasource = MovementLocalDatasource(prefs);
    final repository = MovementRepositoryImpl(datasource);

    final useCase = ConfirmMovementUseCase(
      repository: repository,
      scheduleNext: (nextInterval) => _scheduleWithWorkHours(nextInterval),
    );

    await useCase.execute();
  }

  static Future<void> _scheduleWithWorkHours(Duration nextInterval) async {
    await AlarmService.scheduleHourlyAlarm();
  }
}
