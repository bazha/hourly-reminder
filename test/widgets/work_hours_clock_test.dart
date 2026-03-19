import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/theme/app_colors.dart';
import 'package:hourly_reminder/widgets/work_hours_clock.dart';

void main() {
  Widget buildClock({
    double startTime = 9.0,
    double endTime = 18.0,
    double size = 200,
    DateTime? currentTime,
    ValueChanged<double>? onStartTimeChanged,
    ValueChanged<double>? onEndTimeChanged,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        extensions: const [AppColors.dark],
      ),
      home: Scaffold(
        body: Center(
          child: WorkHoursClock(
            startTime: startTime,
            endTime: endTime,
            size: size,
            currentTime: currentTime,
            onStartTimeChanged: onStartTimeChanged,
            onEndTimeChanged: onEndTimeChanged,
          ),
        ),
      ),
    );
  }

  group('WorkHoursClock rendering', () {
    testWidgets('renders with current time indicator', (tester) async {
      await tester.pumpWidget(buildClock(
        currentTime: DateTime(2026, 1, 1, 12, 30),
      ));
      expect(find.byType(WorkHoursClock), findsOneWidget);
    });

    testWidgets('renders at specified size', (tester) async {
      const testSize = 300.0;
      await tester.pumpWidget(buildClock(size: testSize));

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WorkHoursClock),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, testSize);
      expect(sizedBox.height, testSize);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const [AppColors.light],
        ),
        home: const Scaffold(
          body: Center(
            child: WorkHoursClock(
              startTime: 9.0,
              endTime: 18.0,
              size: 200,
            ),
          ),
        ),
      ));
      expect(find.byType(WorkHoursClock), findsOneWidget);
    });

    testWidgets('renders with edge time values', (tester) async {
      await tester.pumpWidget(buildClock(startTime: 0.0, endTime: 23.75));
      expect(find.byType(WorkHoursClock), findsOneWidget);
    });
  });

  group('WorkHoursClock gestures', () {
    testWidgets('pan gesture triggers callback', (tester) async {
      double? lastStart;
      double? lastEnd;

      await tester.pumpWidget(buildClock(
        onStartTimeChanged: (v) => lastStart = v,
        onEndTimeChanged: (v) => lastEnd = v,
      ));

      final center = tester.getCenter(find.byType(WorkHoursClock));

      // Drag from center toward 12 o'clock position (top)
      await tester.timedDragFrom(
        center,
        const Offset(0, -80),
        const Duration(milliseconds: 300),
      );

      // At least one callback should have fired
      expect(lastStart != null || lastEnd != null, isTrue);
    });
  });
}
