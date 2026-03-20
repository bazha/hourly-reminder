import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/usecases/interval_calculator.dart';

void main() {
  group('IntervalCalculator.compute', () {
    test('returns 30 minutes for reaction <= 3 minutes (default base)', () {
      const short = Duration(minutes: 30);
      for (final input in [
        Duration.zero,
        const Duration(minutes: 1),
        const Duration(minutes: 2, seconds: 59),
        const Duration(minutes: 3),
      ]) {
        expect(IntervalCalculator.compute(input), short, reason: '$input');
      }
    });

    test('returns 45 minutes for reaction > 3 minutes (default base)', () {
      const long = Duration(minutes: 45);
      for (final input in [
        const Duration(minutes: 3, seconds: 1),
        const Duration(minutes: 5),
        const Duration(hours: 1),
      ]) {
        expect(IntervalCalculator.compute(input), long, reason: '$input');
      }
    });

    test('scales proportionally with 30 min base interval', () {
      // Fast: 30 * 0.5 = 15 min
      expect(
        IntervalCalculator.compute(Duration.zero, baseIntervalMinutes: 30),
        const Duration(minutes: 15),
      );
      // Slow: 30 * 0.75 = 22.5 -> 23 min (rounded)
      expect(
        IntervalCalculator.compute(
          const Duration(minutes: 5),
          baseIntervalMinutes: 30,
        ),
        const Duration(minutes: 23),
      );
    });

    test('scales proportionally with 120 min base interval', () {
      // Fast: 120 * 0.5 = 60 min
      expect(
        IntervalCalculator.compute(Duration.zero, baseIntervalMinutes: 120),
        const Duration(minutes: 60),
      );
      // Slow: 120 * 0.75 = 90 min
      expect(
        IntervalCalculator.compute(
          const Duration(minutes: 5),
          baseIntervalMinutes: 120,
        ),
        const Duration(minutes: 90),
      );
    });

    test('enforces 10 minute minimum', () {
      // 15 * 0.5 = 7.5 -> 8, but clamped to 10
      expect(
        IntervalCalculator.compute(Duration.zero, baseIntervalMinutes: 15),
        const Duration(minutes: 10),
      );
    });
  });
}
