import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/theme/app_colors.dart';

/// Helper to build a MaterialApp with AppColors registered as a ThemeExtension.
Widget _buildApp({
  required Brightness brightness,
  required WidgetBuilder builder,
}) {
  final isLight = brightness == Brightness.light;
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      extensions: const [AppColors.light],
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      extensions: const [AppColors.dark],
    ),
    themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
    home: Builder(builder: builder),
  );
}

void main() {
  group('AppColors static palettes', () {
    test('dark and light have distinct background colors', () {
      expect(AppColors.dark.bg, isNot(equals(AppColors.light.bg)));
    });

    test('dark palette isDark returns true', () {
      expect(AppColors.dark.isDark, isTrue);
    });

    test('light palette isDark returns false', () {
      expect(AppColors.light.isDark, isFalse);
    });

    test('dark text is white, light text is dark', () {
      expect(AppColors.dark.textPrimary, Colors.white);
      expect(AppColors.light.textPrimary, isNot(Colors.white));
    });
  });

  group('AppColors equality', () {
    test('dark does not equal light', () {
      expect(AppColors.dark == AppColors.light, isFalse);
    });

    test('hashCode is consistent with equality', () {
      expect(AppColors.dark.hashCode, isNot(AppColors.light.hashCode));
    });
  });

  group('AppColors shared accent constants', () {
    test('startColor is emerald', () {
      expect(AppColors.startColor, const Color(0xFF34D399));
    });

    test('endColor is rose', () {
      expect(AppColors.endColor, const Color(0xFFFB7185));
    });

    test('primary is indigo', () {
      expect(AppColors.primary, const Color(0xFF818CF8));
    });

    test('nowColor is amber', () {
      expect(AppColors.nowColor, const Color(0xFFFBBF24));
    });
  });

  group('AppColors.of (ThemeExtension)', () {
    testWidgets('returns dark palette for dark theme', (tester) async {
      late AppColors result;
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.dark,
          builder: (context) {
            result = AppColors.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(result.isDark, isTrue);
    });

    testWidgets('returns light palette for light theme', (tester) async {
      late AppColors result;
      await tester.pumpWidget(
        _buildApp(
          brightness: Brightness.light,
          builder: (context) {
            result = AppColors.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(result.isDark, isFalse);
    });

    testWidgets('theme switches without restart', (tester) async {
      late AppColors result;
      Widget buildWithExtension(
        AppColors colors,
        Brightness brightness,
        Key key,
      ) {
        return MaterialApp(
          key: key,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: brightness,
            ),
            extensions: [colors],
          ),
          home: Builder(
            builder: (context) {
              result = AppColors.of(context);
              return const SizedBox();
            },
          ),
        );
      }

      await tester.pumpWidget(
        buildWithExtension(AppColors.light, Brightness.light, const Key('l')),
      );
      expect(result.isDark, isFalse);

      await tester.pumpWidget(
        buildWithExtension(AppColors.dark, Brightness.dark, const Key('d')),
      );
      expect(result.isDark, isTrue);
    });
  });

  group('AppColors token completeness', () {
    test('dark palette has non-null essential fields', () {
      final c = AppColors.dark;
      expect(c.bg, isNotNull);
      expect(c.cardBg, isNotNull);
      expect(c.cardBorder, isNotNull);
      expect(c.textPrimary, isNotNull);
      expect(c.textSecondary, isNotNull);
      expect(c.textMuted, isNotNull);
      expect(c.clockFaceInner, isNotNull);
      expect(c.clockFaceOuter, isNotNull);
      expect(c.appBarBg, isNotNull);
      expect(c.appBarFg, isNotNull);
      expect(c.startSliderInactive, isNotNull);
      expect(c.endSliderInactive, isNotNull);
      expect(c.weekendSwitchActive, isNotNull);
    });

    test('light palette has non-null essential fields', () {
      final c = AppColors.light;
      expect(c.bg, isNotNull);
      expect(c.cardBg, isNotNull);
      expect(c.cardBorder, isNotNull);
      expect(c.textPrimary, isNotNull);
      expect(c.textSecondary, isNotNull);
      expect(c.textMuted, isNotNull);
      expect(c.clockFaceInner, isNotNull);
      expect(c.clockFaceOuter, isNotNull);
      expect(c.appBarBg, isNotNull);
      expect(c.appBarFg, isNotNull);
      expect(c.startSliderInactive, isNotNull);
      expect(c.endSliderInactive, isNotNull);
      expect(c.weekendSwitchActive, isNotNull);
    });
  });

  group('ThemeExtension methods', () {
    test('copyWith produces valid instance with overridden field', () {
      final modified = AppColors.light.copyWith(bg: Colors.red);
      expect(modified.bg, Colors.red);
      expect(modified.textPrimary, AppColors.light.textPrimary);
    });

    test('copyWith with no args returns equivalent instance', () {
      final copy = AppColors.dark.copyWith();
      expect(copy.bg, AppColors.dark.bg);
      expect(copy.appBarBg, AppColors.dark.appBarBg);
    });

    test('lerp at 0 returns start values', () {
      final result = AppColors.light.lerp(AppColors.dark, 0);
      expect(result.bg, AppColors.light.bg);
    });

    test('lerp at 1 returns end values', () {
      final result = AppColors.light.lerp(AppColors.dark, 1);
      expect(result.bg, AppColors.dark.bg);
    });

    test('lerp at 0.5 produces intermediate color', () {
      final result = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(result.bg, isNot(AppColors.light.bg));
      expect(result.bg, isNot(AppColors.dark.bg));
    });
  });
}
