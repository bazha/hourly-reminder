import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/utils/time_utils.dart';

void main() {
  group('TimeUtils.formatTime', () {
    test('formats whole hours', () {
      expect(TimeUtils.formatTime(0.0), '0:00');
      expect(TimeUtils.formatTime(9.0), '9:00');
      expect(TimeUtils.formatTime(23.0), '23:00');
    });

    test('formats half hours', () {
      expect(TimeUtils.formatTime(9.5), '9:30');
      expect(TimeUtils.formatTime(0.5), '0:30');
    });

    test('formats quarter hours', () {
      expect(TimeUtils.formatTime(9.25), '9:15');
      expect(TimeUtils.formatTime(18.75), '18:45');
    });

    test('formats arbitrary fractions', () {
      expect(TimeUtils.formatTime(12.33), '12:20');
      expect(TimeUtils.formatTime(7.1), '7:06');
    });
  });

  group('TimeUtils.formatHourMinute', () {
    test('formats with default minute', () {
      expect(TimeUtils.formatHourMinute(9), '9:00');
      expect(TimeUtils.formatHourMinute(0), '0:00');
      expect(TimeUtils.formatHourMinute(23), '23:00');
    });

    test('formats with explicit minute', () {
      expect(TimeUtils.formatHourMinute(9, 30), '9:30');
      expect(TimeUtils.formatHourMinute(18, 45), '18:45');
      expect(TimeUtils.formatHourMinute(0, 5), '0:05');
    });

    test('pads single-digit minutes', () {
      expect(TimeUtils.formatHourMinute(12, 0), '12:00');
      expect(TimeUtils.formatHourMinute(12, 1), '12:01');
      expect(TimeUtils.formatHourMinute(12, 9), '12:09');
    });

    test('edge cases', () {
      expect(TimeUtils.formatHourMinute(23, 59), '23:59');
      expect(TimeUtils.formatHourMinute(0, 0), '0:00');
    });
  });

  group('TimeUtils.formatDurationRaw', () {
    test('formats seconds for sub-minute durations', () {
      expect(TimeUtils.formatDurationRaw(Duration.zero), '0с');
      expect(TimeUtils.formatDurationRaw(const Duration(seconds: 30)), '30с');
      expect(TimeUtils.formatDurationRaw(const Duration(seconds: 59)), '59с');
    });

    test('formats minutes for sub-hour durations', () {
      expect(TimeUtils.formatDurationRaw(const Duration(minutes: 1)), '1м');
      expect(TimeUtils.formatDurationRaw(const Duration(minutes: 45)), '45м');
      expect(
          TimeUtils.formatDurationRaw(const Duration(minutes: 59, seconds: 30)),
          '59м');
    });

    test('formats hours and minutes for long durations', () {
      expect(TimeUtils.formatDurationRaw(const Duration(hours: 1)), '1ч');
      expect(TimeUtils.formatDurationRaw(const Duration(hours: 2, minutes: 15)),
          '2ч 15м');
      expect(TimeUtils.formatDurationRaw(const Duration(hours: 5, minutes: 0)),
          '5ч');
    });
  });
}
