import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/entities/movement_event.dart';
import 'package:hourly_reminder/features/movement_stats/domain/usecases/get_movement_stats_use_case.dart';

void main() {
  late GetMovementStatsUseCase useCase;

  setUp(() {
    useCase = GetMovementStatsUseCase();
  });

  MovementEvent makeEvent({
    required DateTime timestamp,
    Duration sedentaryDuration = const Duration(minutes: 55),
    Duration reactionTime = const Duration(minutes: 2),
  }) {
    return MovementEvent(
      id: timestamp.microsecondsSinceEpoch.toString(),
      timestamp: timestamp,
      sedentaryDuration: sedentaryDuration,
      reactionTime: reactionTime,
      source: MovementSource.notification,
    );
  }

  group('empty events', () {
    test('returns zero stats', () {
      final now = DateTime(2026, 3, 19, 14, 0);
      final result = useCase(
        events: [],
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.totalMovements, 0);
      expect(result.today.movementCount, 0);
      expect(result.streak.currentStreak, 0);
      expect(result.streak.bestStreak, 0);
      expect(result.weeklyStats.length, 7);
      expect(result.weeklyStats.every((s) => s.movementCount == 0), isTrue);
    });
  });

  group('today stats', () {
    test('single event today shows correct daily stats', () {
      final now = DateTime(2026, 3, 19, 14, 0);
      final event = makeEvent(
        timestamp: DateTime(2026, 3, 19, 10, 0),
        sedentaryDuration: const Duration(minutes: 50),
        reactionTime: const Duration(minutes: 3),
      );

      final result = useCase(
        events: [event],
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.today.movementCount, 1);
      expect(result.today.totalSedentaryTime, const Duration(minutes: 50));
      expect(result.today.averageReactionTime, const Duration(minutes: 3));
      expect(result.totalMovements, 1);
    });

    test('multiple events today aggregates correctly', () {
      final now = DateTime(2026, 3, 19, 16, 0);
      final events = [
        makeEvent(
          timestamp: DateTime(2026, 3, 19, 10, 0),
          sedentaryDuration: const Duration(minutes: 60),
          reactionTime: const Duration(minutes: 2),
        ),
        makeEvent(
          timestamp: DateTime(2026, 3, 19, 11, 0),
          sedentaryDuration: const Duration(minutes: 40),
          reactionTime: const Duration(minutes: 4),
        ),
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.today.movementCount, 2);
      expect(result.today.totalSedentaryTime, const Duration(minutes: 100));
      expect(result.today.averageReactionTime, const Duration(minutes: 3));
    });
  });

  group('weekly stats', () {
    test('shows last 7 work days excluding today', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday

      final result = useCase(
        events: [],
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      // 7 work days back from Wed Mar 18:
      // Wed 18, Tue 17, Mon 16, Fri 13, Thu 12, Wed 11, Tue 10
      expect(result.weeklyStats.length, 7);
      expect(result.weeklyStats.last.date, DateTime(2026, 3, 18));
      expect(result.weeklyStats.first.date, DateTime(2026, 3, 10));
    });

    test('includes Saturday when workOnSaturday is true', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday

      final result = useCase(
        events: [],
        now: now,
        workOnSaturday: true,
        workOnSunday: false,
      );

      // Should include Sat Mar 14
      final dates = result.weeklyStats.map((s) => s.date).toList();
      expect(dates, contains(DateTime(2026, 3, 14)));
    });

    test('events on work days populate counts', () {
      final now = DateTime(2026, 3, 19, 14, 0);
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 18, 10, 0)),
        makeEvent(timestamp: DateTime(2026, 3, 18, 11, 0)),
        makeEvent(timestamp: DateTime(2026, 3, 17, 10, 0)),
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      final wed18 = result.weeklyStats
          .firstWhere((s) => s.date == DateTime(2026, 3, 18));
      final tue17 = result.weeklyStats
          .firstWhere((s) => s.date == DateTime(2026, 3, 17));

      expect(wed18.movementCount, 2);
      expect(tue17.movementCount, 1);
    });
  });

  group('streak', () {
    test('consecutive work days with events gives correct streak', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 19, 10, 0)), // Thu (today)
        makeEvent(timestamp: DateTime(2026, 3, 18, 10, 0)), // Wed
        makeEvent(timestamp: DateTime(2026, 3, 17, 10, 0)), // Tue
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 3);
    });

    test('gap in days resets current streak', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 19, 10, 0)), // Thu (today)
        // Wed missing
        makeEvent(timestamp: DateTime(2026, 3, 17, 10, 0)), // Tue
        makeEvent(timestamp: DateTime(2026, 3, 16, 10, 0)), // Mon
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 1);
      expect(result.streak.bestStreak, 2);
    });

    test('weekends are skipped when not work days', () {
      final now = DateTime(2026, 3, 16, 14, 0); // Monday
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 16, 10, 0)), // Mon
        // Sat/Sun skipped
        makeEvent(timestamp: DateTime(2026, 3, 13, 10, 0)), // Fri
        makeEvent(timestamp: DateTime(2026, 3, 12, 10, 0)), // Thu
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 3);
    });

    test('no events today but yesterday has events still counts streak', () {
      final now = DateTime(2026, 3, 19, 8, 0); // Thursday morning, no events yet
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 18, 10, 0)), // Wed
        makeEvent(timestamp: DateTime(2026, 3, 17, 10, 0)), // Tue
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 2);
    });
  });

  group('streak edge cases', () {
    test('today is non-work day with no events does not break', () {
      // Sunday, workOnSunday=false
      final now = DateTime(2026, 3, 15, 14, 0); // Sunday
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 13, 10, 0)), // Fri
        makeEvent(timestamp: DateTime(2026, 3, 12, 10, 0)), // Thu
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 2);
    });

    test('best streak is tracked independently from current', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday
      final events = [
        // Old streak of 4: Mon-Thu Mar 2-5
        makeEvent(timestamp: DateTime(2026, 3, 2, 10, 0)),
        makeEvent(timestamp: DateTime(2026, 3, 3, 10, 0)),
        makeEvent(timestamp: DateTime(2026, 3, 4, 10, 0)),
        makeEvent(timestamp: DateTime(2026, 3, 5, 10, 0)),
        // Current streak of 1: today only
        makeEvent(timestamp: DateTime(2026, 3, 19, 10, 0)),
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.streak.currentStreak, 1);
      expect(result.streak.bestStreak, 4);
    });

    test('both weekends enabled treats every day as work day', () {
      final now = DateTime(2026, 3, 16, 14, 0); // Monday
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 16, 10, 0)), // Mon
        makeEvent(timestamp: DateTime(2026, 3, 15, 10, 0)), // Sun
        makeEvent(timestamp: DateTime(2026, 3, 14, 10, 0)), // Sat
        makeEvent(timestamp: DateTime(2026, 3, 13, 10, 0)), // Fri
      ];

      final result = useCase(
        events: events,
        now: now,
        workOnSaturday: true,
        workOnSunday: true,
      );

      expect(result.streak.currentStreak, 4);
    });
  });

  group('all-time averages', () {
    test('computed correctly across all events', () {
      final events = [
        makeEvent(
          timestamp: DateTime(2026, 3, 18, 10, 0),
          reactionTime: const Duration(minutes: 2),
          sedentaryDuration: const Duration(minutes: 50),
        ),
        makeEvent(
          timestamp: DateTime(2026, 3, 19, 10, 0),
          reactionTime: const Duration(minutes: 4),
          sedentaryDuration: const Duration(minutes: 70),
        ),
      ];

      final result = useCase(
        events: events,
        now: DateTime(2026, 3, 19, 14, 0),
        workOnSaturday: false,
        workOnSunday: false,
      );

      expect(result.allTimeAverageReaction, const Duration(minutes: 3));
      expect(result.allTimeAverageSedentary, const Duration(minutes: 60));
    });
  });
}
