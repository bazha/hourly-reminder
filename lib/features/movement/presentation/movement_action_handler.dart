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
    final now = DateTime.now();
    final candidate = now.add(nextInterval);

    final isWithinWorkHours = AlarmService.shouldSendReminder(
      now: candidate,
      isEnabled: StorageService.isEnabled,
      startHour: StorageService.startHour,
      startMinute: StorageService.startMinute,
      endHour: StorageService.endHour,
      endMinute: StorageService.endMinute,
      workOnSaturday: StorageService.workOnSaturday,
      workOnSunday: StorageService.workOnSunday,
    );

    if (isWithinWorkHours) {
      await AlarmService.scheduleHourlyAlarm();
    } else {
      // Falls outside work window. The existing alarm scheduler will pick up
      // at the next work window start on its own cycle.
      await AlarmService.scheduleHourlyAlarm();
    }
  }
}
