import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/core/theme/app_colors.dart';

void main() {
  test('dark and light palettes are distinct', () {
    expect(AppColors.dark.bg, isNot(equals(AppColors.light.bg)));
    expect(AppColors.dark.isDark, isTrue);
    expect(AppColors.light.isDark, isFalse);
    expect(AppColors.dark == AppColors.light, isFalse);
    expect(AppColors.dark.hashCode, isNot(AppColors.light.hashCode));
  });

  test('shared accent constants have expected values', () {
    expect(AppColors.startColor, const Color(0xFF4EAAA0));
    expect(AppColors.endColor, const Color(0xFFE57373));
    expect(AppColors.primary, const Color(0xFF4EAAA0));
    expect(AppColors.nowColor, const Color(0xFFF5A623));
  });

  testWidgets('AppColors.of resolves correct palette per brightness', (tester) async {
    late AppColors result;

    Widget buildWithKey(Brightness brightness, Key key) {
      return MaterialApp(
        key: key,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4EAAA0),
            brightness: brightness,
          ),
          extensions: [brightness == Brightness.dark ? AppColors.dark : AppColors.light],
        ),
        home: Builder(
          builder: (context) {
            result = AppColors.of(context);
            return const SizedBox();
          },
        ),
      );
    }

    await tester.pumpWidget(buildWithKey(Brightness.dark, const Key('d')));
    expect(result.isDark, isTrue);

    await tester.pumpWidget(buildWithKey(Brightness.light, const Key('l')));
    expect(result.isDark, isFalse);
  });

  test('copyWith overrides specified field and preserves others', () {
    final modified = AppColors.light.copyWith(bg: Colors.red);
    expect(modified.bg, Colors.red);
    expect(modified.textPrimary, AppColors.light.textPrimary);

    final copy = AppColors.dark.copyWith();
    expect(copy.bg, AppColors.dark.bg);
  });

  test('lerp produces intermediate values', () {
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(mid.bg, isNot(AppColors.light.bg));
    expect(mid.bg, isNot(AppColors.dark.bg));
  });
}
