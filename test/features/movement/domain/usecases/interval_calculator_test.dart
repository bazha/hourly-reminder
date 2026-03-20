import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/features/movement/domain/usecases/interval_calculator.dart';

void main() {
  group('IntervalCalculator.compute', () {
    test('returns 30 minutes for reaction <= 3 minutes', () {
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

    test('returns 45 minutes for reaction > 3 minutes', () {
      const long = Duration(minutes: 45);
      for (final input in [
        const Duration(minutes: 3, seconds: 1),
        const Duration(minutes: 5),
        const Duration(hours: 1),
      ]) {
        expect(IntervalCalculator.compute(input), long, reason: '$input');
      }
    });
  });
}
