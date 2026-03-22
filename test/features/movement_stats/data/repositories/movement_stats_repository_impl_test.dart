import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';
import 'package:hourly_reminder/features/movement_stats/data/repositories/movement_stats_repository_impl.dart';
import 'package:hourly_reminder/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fake_movement_repository.dart';

void main() {
  group('MovementStatsRepositoryImpl', () {
    test('delegates to use case with events and preferences', () async {
      SharedPreferences.setMockInitialValues({
        'work_on_saturday': true,
        'work_on_sunday': false,
      });

      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      final events = [
        MovementEvent(
          id: '1',
          timestamp: DateTime.now(),
          sedentaryDuration: const Duration(minutes: 55),
          reactionTime: const Duration(minutes: 2),
          source: MovementSource.notification,
        ),
      ];

      final repo = MovementStatsRepositoryImpl(
        movementRepository: FakeMovementRepository(events),
        storageService: storageService,
      );

      final stats = await repo.getStats();

      expect(stats.totalMovements, 1);
      expect(stats.today.movementCount, 1);
    });

    test('returns empty stats when no events', () async {
      SharedPreferences.setMockInitialValues({});

      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      final repo = MovementStatsRepositoryImpl(
        movementRepository: FakeMovementRepository(),
        storageService: storageService,
      );

      final stats = await repo.getStats();

      expect(stats.totalMovements, 0);
      expect(stats.today.movementCount, 0);
      expect(stats.streak.currentStreak, 0);
    });
  });
}
