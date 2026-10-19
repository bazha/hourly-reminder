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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.today.movementCount, 2);
      expect(result.today.totalSedentaryTime, const Duration(minutes: 100));
      expect(result.today.averageReactionTime, const Duration(minutes: 3));
    });
  });

  group('weekly stats', () {
    test('includes Saturday when Saturday is a work day', () {
      final now = DateTime(2026, 3, 19, 14, 0); // Thursday

      final result = useCase(
        events: [],
        now: now,
        workDays: {1, 2, 3, 4, 5, 6},
        dailyGoal: 8,
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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      final wed18 =
          result.weeklyStats.firstWhere((s) => s.date == DateTime(2026, 3, 18));
      final tue17 =
          result.weeklyStats.firstWhere((s) => s.date == DateTime(2026, 3, 17));

      expect(wed18.movementCount, 2);
      expect(tue17.movementCount, 1);
    });
  });

  group('streak', () {
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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.streak.currentStreak, 1);
      expect(result.streak.bestStreak, 2);
    });

    test('no events today but yesterday has events still counts streak', () {
      final now =
          DateTime(2026, 3, 19, 8, 0); // Thursday morning, no events yet
      final events = [
        makeEvent(timestamp: DateTime(2026, 3, 18, 10, 0)), // Wed
        makeEvent(timestamp: DateTime(2026, 3, 17, 10, 0)), // Tue
      ];

      final result = useCase(
        events: events,
        now: now,
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.streak.currentStreak, 2);
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
        workDays: {1, 2, 3, 4, 5, 6, 7},
        dailyGoal: 8,
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
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.allTimeAverageReaction, const Duration(minutes: 3));
      expect(result.allTimeAverageSedentary, const Duration(minutes: 60));
    });
  });

  // The DST part only fails in a time zone with DST (run with
  // TZ=Europe/Berlin). In any zone these also cover the basic cases: a streak
  // that includes today and crosses a weekend, and the last 7 work days
  // excluding today. EU switches: spring forward 2026-03-29, fall back
  // 2026-10-25.
  group('DST switch', () {
    List<MovementEvent> eventsOn(List<DateTime> days) => [
          for (final d in days)
            makeEvent(timestamp: d.add(const Duration(hours: 11)))
        ];

    final fallBackDays = [
      for (final d in [19, 20, 21, 22, 23, 26, 27, 28]) DateTime(2026, 10, d),
    ];
    final springForwardDays = [
      for (final d in [23, 24, 25, 26, 27, 30, 31]) DateTime(2026, 3, d),
      DateTime(2026, 4, 1),
    ];

    test('streak continues across the fall-back switch', () {
      final result = useCase(
        events: eventsOn(fallBackDays),
        now: DateTime(2026, 10, 28, 12),
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.streak.currentStreak, 8);
      expect(result.streak.bestStreak, 8);
    });

    test('streak continues across the spring-forward switch', () {
      final result = useCase(
        events: eventsOn(springForwardDays),
        now: DateTime(2026, 4, 1, 12),
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.streak.currentStreak, 8);
      expect(result.streak.bestStreak, 8);
    });

    test('weekly stats across a switch use midnight dates with counts', () {
      final result = useCase(
        events: eventsOn(fallBackDays),
        now: DateTime(2026, 10, 28, 12),
        workDays: {1, 2, 3, 4, 5},
        dailyGoal: 8,
      );

      expect(result.weeklyStats.map((d) => d.date), [
        for (final d in [19, 20, 21, 22, 23, 26, 27]) DateTime(2026, 10, d),
      ]);
      expect(result.weeklyStats.map((d) => d.movementCount), everyElement(1));
    });
  });
}
