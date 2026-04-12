import '../../../movement/domain/repositories/movement_repository.dart';
import '../../../../services/storage_service.dart';
import '../../domain/entities/movement_stats.dart';
import '../../domain/repositories/movement_stats_repository.dart';
import '../../domain/usecases/get_movement_stats_use_case.dart';

class MovementStatsRepositoryImpl implements MovementStatsRepository {
  final MovementRepository _movementRepository;
  final StorageService _storageService;
  final GetMovementStatsUseCase _useCase;

  MovementStatsRepositoryImpl({
    required MovementRepository movementRepository,
    required StorageService storageService,
    GetMovementStatsUseCase? useCase,
  })  : _movementRepository = movementRepository,
        _storageService = storageService,
        _useCase = useCase ?? GetMovementStatsUseCase();

  @override
  Future<MovementStats> getStats() async {
    final events = await _movementRepository.getEvents();
    final prefs = _storageService.loadPreferences();

    return _useCase(
      events: events,
      now: DateTime.now(),
      workDays: prefs.workDaySet,
      dailyGoal: prefs.dailyGoal,
    );
  }
}
