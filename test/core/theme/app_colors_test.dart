import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/theme/app_colors.dart';

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
    test('dark equals itself', () {
      expect(AppColors.dark == AppColors.dark, isTrue);
    });

    test('light equals itself', () {
      expect(AppColors.light == AppColors.light, isTrue);
    });

    test('dark does not equal light', () {
      expect(AppColors.dark == AppColors.light, isFalse);
    });

    test('hashCode is consistent with equality', () {
      expect(AppColors.dark.hashCode, AppColors.dark.hashCode);
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

  group('AppColors.of', () {
    testWidgets('returns dark palette for dark theme', (tester) async {
      late AppColors result;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              result = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result.isDark, isTrue);
    });

    testWidgets('returns light palette for light theme', (tester) async {
      late AppColors result;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              result = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result.isDark, isFalse);
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
    });
  });
}
