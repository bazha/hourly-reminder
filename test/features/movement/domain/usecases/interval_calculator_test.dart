import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/usecases/interval_calculator.dart';

void main() {
  group('IntervalCalculator.compute', () {
    test('returns 30 minutes for zero reaction time', () {
      expect(
        IntervalCalculator.compute(Duration.zero),
        const Duration(minutes: 30),
      );
    });

    test('returns 30 minutes for 1 minute reaction time', () {
      expect(
        IntervalCalculator.compute(const Duration(minutes: 1)),
        const Duration(minutes: 30),
      );
    });

    test('returns 30 minutes for 2 minute reaction time', () {
      expect(
        IntervalCalculator.compute(const Duration(minutes: 2)),
        const Duration(minutes: 30),
      );
    });

    test('returns 30 minutes for exactly 3 minutes', () {
      expect(
        IntervalCalculator.compute(const Duration(minutes: 3)),
        const Duration(minutes: 30),
      );
    });

    test('returns 45 minutes for 3 minutes and 1 second', () {
      expect(
        IntervalCalculator.compute(
            const Duration(minutes: 3, seconds: 1)),
        const Duration(minutes: 45),
      );
    });

    test('returns 45 minutes for 5 minutes', () {
      expect(
        IntervalCalculator.compute(const Duration(minutes: 5)),
        const Duration(minutes: 45),
      );
    });

    test('returns 45 minutes for 10 minutes', () {
      expect(
        IntervalCalculator.compute(const Duration(minutes: 10)),
        const Duration(minutes: 45),
      );
    });

    test('returns 45 minutes for 1 hour', () {
      expect(
        IntervalCalculator.compute(const Duration(hours: 1)),
        const Duration(minutes: 45),
      );
    });

    test('returns 30 minutes for 2 minutes 59 seconds', () {
      expect(
        IntervalCalculator.compute(
            const Duration(minutes: 2, seconds: 59)),
        const Duration(minutes: 30),
      );
    });
  });
}
