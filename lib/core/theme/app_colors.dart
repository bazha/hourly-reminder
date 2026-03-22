import 'package:flutter/material.dart';

/// Centralized design-token palette for light and dark themes.
///
/// Usage: `final c = AppColors.of(context);`
class AppColors extends ThemeExtension<AppColors> {
  // --- Background ---
  final Color bg;

  // --- Cards ---
  final Color cardBg;
  final Color cardBorder;

  // --- Text ---
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // --- Controls ---
  final Color switchInactiveTrack;
  final Color switchInactiveThumb;
  final Color sliderInactiveTrack;
  final Color sliderThumb;
  final Color divider;

  // --- Clock face ---
  final Color clockFaceInner;
  final Color clockFaceOuter;
  final Color clockRing;
  final Color clockBorder;
  final Color clockTickKey;
  final Color clockTickHalf;
  final Color clockTickMinor;
  final Color clockLabelColor;
  final Color clockCenterDot;
  final Color clockCenterGlow;
  final Color clockHandleRing;

  // --- Time picker dialog ---
  final Color pickerBg;
  final Color pickerInputBg;
  final Color pickerText;

  // --- Button ---
  final Color buttonTextColor;

  // --- Navigation bar ---
  final Color navBarBg;
  final Color navBarSelected;
  final Color navBarUnselected;

  // --- Surfaces ---
  final Color primaryContainer;
  final Color accent;

  const AppColors._({
    required this.bg,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.switchInactiveTrack,
    required this.switchInactiveThumb,
    required this.sliderInactiveTrack,
    required this.sliderThumb,
    required this.divider,
    required this.clockFaceInner,
    required this.clockFaceOuter,
    required this.clockRing,
    required this.clockBorder,
    required this.clockTickKey,
    required this.clockTickHalf,
    required this.clockTickMinor,
    required this.clockLabelColor,
    required this.clockCenterDot,
    required this.clockCenterGlow,
    required this.clockHandleRing,
    required this.pickerBg,
    required this.pickerInputBg,
    required this.pickerText,
    required this.buttonTextColor,
    required this.navBarBg,
    required this.navBarSelected,
    required this.navBarUnselected,
    required this.primaryContainer,
    required this.accent,
  });

  /// Dark theme - near-black with blue undertone, Linear aesthetic.
  static const dark = AppColors._(
    bg: Color(0xFF111318),
    cardBg: Color(0xFF1A1D24),
    cardBorder: Color(0xFF25282F),
    textPrimary: Color(0xFFECEEF1),
    textSecondary: Color(0xFF7D8590),
    textMuted: Color(0xFF484F58),
    switchInactiveTrack: Color(0xFF25282F),
    switchInactiveThumb: Color(0xFF7D8590),
    sliderInactiveTrack: Color(0xFF25282F),
    sliderThumb: Color(0xFF4EAAA0),
    divider: Color(0xFF25282F),
    clockFaceInner: Color(0xFF1A1D24),
    clockFaceOuter: Color(0xFF151820),
    clockRing: Color(0xFF25282F),
    clockBorder: Color(0xFF25282F),
    clockTickKey: Color(0xA6ECEEF1),
    clockTickHalf: Color(0x4DECEEF1),
    clockTickMinor: Color(0x1FECEEF1),
    clockLabelColor: Color(0x66ECEEF1),
    clockCenterDot: Color(0xFFECEEF1),
    clockCenterGlow: Color(0x33ECEEF1),
    clockHandleRing: Color(0x2EFFFFFF),
    pickerBg: Color(0xFF1A1D24),
    pickerInputBg: Color(0x264EAAA0),
    pickerText: Color(0xFFECEEF1),
    buttonTextColor: Colors.white,
    navBarBg: Color(0xFF111318),
    navBarSelected: Color(0xFF4EAAA0),
    navBarUnselected: Color(0xFF484F58),
    primaryContainer: Color(0xFF1A3A36),
    accent: Color(0xFFF5A623),
  );

  /// Light theme - cool near-white, crisp borders.
  static const light = AppColors._(
    bg: Color(0xFFF8F9FA),
    cardBg: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E5E9),
    textPrimary: Color(0xFF1B1F23),
    textSecondary: Color(0xFF656D76),
    textMuted: Color(0xFF8B949E),
    switchInactiveTrack: Color(0xFFD1D5DB),
    switchInactiveThumb: Color(0xFF8B949E),
    sliderInactiveTrack: Color(0xFFE2E5E9),
    sliderThumb: Color(0xFF3D9A8F),
    divider: Color(0xFFE2E5E9),
    clockFaceInner: Color(0xFFF0F1F3),
    clockFaceOuter: Color(0xFFE8EAED),
    clockRing: Color(0xFFE2E5E9),
    clockBorder: Color(0xFFE2E5E9),
    clockTickKey: Color(0xA61B1F23),
    clockTickHalf: Color(0x4D1B1F23),
    clockTickMinor: Color(0x1F1B1F23),
    clockLabelColor: Color(0x661B1F23),
    clockCenterDot: Color(0xFF1B1F23),
    clockCenterGlow: Color(0x331B1F23),
    clockHandleRing: Color(0x2E000000),
    pickerBg: Color(0xFFF8F9FA),
    pickerInputBg: Color(0x1A3D9A8F),
    pickerText: Color(0xFF1B1F23),
    buttonTextColor: Colors.white,
    navBarBg: Color(0xFFFFFFFF),
    navBarSelected: Color(0xFF3D9A8F),
    navBarUnselected: Color(0xFF8B949E),
    primaryContainer: Color(0xFFE6F5F3),
    accent: Color(0xFFF5A623),
  );

  /// Resolves the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  bool get isDark => identical(this, dark) || bg == dark.bg;

  // --- Shared accent colours (same in both themes) ---
  static const primary = Color(0xFF4EAAA0); // Teal
  static const endColor = Color(0xFFE57373); // Coral
  static const nowColor = Color(0xFFF5A623); // Amber

  // --- ThemeExtension overrides ---

  @override
  AppColors copyWith({
    Color? bg,
    Color? cardBg,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? switchInactiveTrack,
    Color? switchInactiveThumb,
    Color? sliderInactiveTrack,
    Color? sliderThumb,
    Color? divider,
    Color? clockFaceInner,
    Color? clockFaceOuter,
    Color? clockRing,
    Color? clockBorder,
    Color? clockTickKey,
    Color? clockTickHalf,
    Color? clockTickMinor,
    Color? clockLabelColor,
    Color? clockCenterDot,
    Color? clockCenterGlow,
    Color? clockHandleRing,
    Color? pickerBg,
    Color? pickerInputBg,
    Color? pickerText,
    Color? buttonTextColor,
    Color? navBarBg,
    Color? navBarSelected,
    Color? navBarUnselected,
    Color? primaryContainer,
    Color? accent,
  }) {
    return AppColors._(
      bg: bg ?? this.bg,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      switchInactiveTrack: switchInactiveTrack ?? this.switchInactiveTrack,
      switchInactiveThumb: switchInactiveThumb ?? this.switchInactiveThumb,
      sliderInactiveTrack: sliderInactiveTrack ?? this.sliderInactiveTrack,
      sliderThumb: sliderThumb ?? this.sliderThumb,
      divider: divider ?? this.divider,
      clockFaceInner: clockFaceInner ?? this.clockFaceInner,
      clockFaceOuter: clockFaceOuter ?? this.clockFaceOuter,
      clockRing: clockRing ?? this.clockRing,
      clockBorder: clockBorder ?? this.clockBorder,
      clockTickKey: clockTickKey ?? this.clockTickKey,
      clockTickHalf: clockTickHalf ?? this.clockTickHalf,
      clockTickMinor: clockTickMinor ?? this.clockTickMinor,
      clockLabelColor: clockLabelColor ?? this.clockLabelColor,
      clockCenterDot: clockCenterDot ?? this.clockCenterDot,
      clockCenterGlow: clockCenterGlow ?? this.clockCenterGlow,
      clockHandleRing: clockHandleRing ?? this.clockHandleRing,
      pickerBg: pickerBg ?? this.pickerBg,
      pickerInputBg: pickerInputBg ?? this.pickerInputBg,
      pickerText: pickerText ?? this.pickerText,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors._(
      bg: Color.lerp(bg, other.bg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      switchInactiveTrack:
          Color.lerp(switchInactiveTrack, other.switchInactiveTrack, t)!,
      switchInactiveThumb:
          Color.lerp(switchInactiveThumb, other.switchInactiveThumb, t)!,
      sliderInactiveTrack:
          Color.lerp(sliderInactiveTrack, other.sliderInactiveTrack, t)!,
      sliderThumb: Color.lerp(sliderThumb, other.sliderThumb, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      clockFaceInner: Color.lerp(clockFaceInner, other.clockFaceInner, t)!,
      clockFaceOuter: Color.lerp(clockFaceOuter, other.clockFaceOuter, t)!,
      clockRing: Color.lerp(clockRing, other.clockRing, t)!,
      clockBorder: Color.lerp(clockBorder, other.clockBorder, t)!,
      clockTickKey: Color.lerp(clockTickKey, other.clockTickKey, t)!,
      clockTickHalf: Color.lerp(clockTickHalf, other.clockTickHalf, t)!,
      clockTickMinor: Color.lerp(clockTickMinor, other.clockTickMinor, t)!,
      clockLabelColor: Color.lerp(clockLabelColor, other.clockLabelColor, t)!,
      clockCenterDot: Color.lerp(clockCenterDot, other.clockCenterDot, t)!,
      clockCenterGlow: Color.lerp(clockCenterGlow, other.clockCenterGlow, t)!,
      clockHandleRing: Color.lerp(clockHandleRing, other.clockHandleRing, t)!,
      pickerBg: Color.lerp(pickerBg, other.pickerBg, t)!,
      pickerInputBg: Color.lerp(pickerInputBg, other.pickerInputBg, t)!,
      pickerText: Color.lerp(pickerText, other.pickerText, t)!,
      buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected:
          Color.lerp(navBarUnselected, other.navBarUnselected, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppColors &&
          other.bg == bg &&
          other.cardBg == cardBg &&
          other.textPrimary == textPrimary);

  @override
  int get hashCode => Object.hash(bg, cardBg, textPrimary);
}
