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

  // --- Navigation bar ---
  final Color navBarBg;
  final Color navBarSelected;
  final Color navBarUnselected;

  // --- Surfaces ---
  final Color primaryContainer;
  final Color accent;

  // --- Progress ring ---
  final Color ringTrack;

  // --- Semantic accent colors ---
  final Color streakColor;
  final Color activityColor;

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
    required this.navBarBg,
    required this.navBarSelected,
    required this.navBarUnselected,
    required this.primaryContainer,
    required this.accent,
    required this.ringTrack,
    required this.streakColor,
    required this.activityColor,
  });

  /// Dark theme - warm charcoal brown, cosy premium feel.
  static const dark = AppColors._(
    bg: Color(0xFF1B1714),
    cardBg: Color(0xFF2C2825),
    cardBorder: Color(0xFF3D3936),
    textPrimary: Color(0xFFEBEAE8),
    textSecondary: Color(0x99EBEAE8),
    textMuted: Color(0x60EBEAE8),
    switchInactiveTrack: Color(0xFF3D3936),
    switchInactiveThumb: Color(0x99EBEAE8),
    sliderInactiveTrack: Color(0xFF3D3936),
    sliderThumb: Color(0xFFE09040),
    divider: Color(0xFF3D3936),
    clockFaceInner: Color(0xFF2C2825),
    clockFaceOuter: Color(0xFF221F1C),
    clockRing: Color(0xFF3D3936),
    clockBorder: Color(0xFF3D3936),
    clockTickKey: Color(0xA6EBEAE8),
    clockTickHalf: Color(0x4DEBEAE8),
    clockTickMinor: Color(0x1FEBEAE8),
    clockLabelColor: Color(0x66EBEAE8),
    clockCenterDot: Color(0xFFEBEAE8),
    clockCenterGlow: Color(0x33EBEAE8),
    clockHandleRing: Color(0x2EFFFFFF),
    pickerBg: Color(0xFF2C2825),
    pickerInputBg: Color(0x26E09040),
    pickerText: Color(0xFFEBEAE8),
    navBarBg: Color(0xFF1B1714),
    navBarSelected: Color(0xFFE09040),
    navBarUnselected: Color(0x60EBEAE8),
    primaryContainer: Color(0xFF3A2A1A),
    accent: Color(0xFFE09040),
    ringTrack: Color(0xFF3D3936),
    streakColor: Color(0xFFE09040),
    activityColor: Color(0xFF5C8C6B),
  );

  /// Light theme - warm cream, cosy Scandinavian feel.
  static const light = AppColors._(
    bg: Color(0xFFF5F0E8),
    cardBg: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE8E0D4),
    textPrimary: Color(0xFF2C2620),
    textSecondary: Color(0xFF6B6560),
    textMuted: Color(0xFF8A8078),
    switchInactiveTrack: Color(0xFFD8D2C8),
    switchInactiveThumb: Color(0xFF8A8078),
    sliderInactiveTrack: Color(0xFFE8E0D4),
    sliderThumb: Color(0xFFCC7A2E),
    divider: Color(0xFFE8E0D4),
    clockFaceInner: Color(0xFFF0EBE3),
    clockFaceOuter: Color(0xFFE8E0D4),
    clockRing: Color(0xFFE8E0D4),
    clockBorder: Color(0xFFE8E0D4),
    clockTickKey: Color(0xA62C2620),
    clockTickHalf: Color(0x4D2C2620),
    clockTickMinor: Color(0x1F2C2620),
    clockLabelColor: Color(0x662C2620),
    clockCenterDot: Color(0xFF2C2620),
    clockCenterGlow: Color(0x332C2620),
    clockHandleRing: Color(0x2E000000),
    pickerBg: Color(0xFFF5F0E8),
    pickerInputBg: Color(0x1ACC7A2E),
    pickerText: Color(0xFF2C2620),
    navBarBg: Color(0xFFFFFFFF),
    navBarSelected: Color(0xFFCC7A2E),
    navBarUnselected: Color(0xFF8A8078),
    primaryContainer: Color(0xFFFAEDD8),
    accent: Color(0xFFCC7A2E),
    ringTrack: Color(0xFFE8E0D4),
    streakColor: Color(0xFFCC7A2E),
    activityColor: Color(0xFF4D7A5A),
  );

  /// Resolves the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  bool get isDark => identical(this, dark) || bg == dark.bg;

  // --- Shared accent colours (same in both themes) ---
  static const primary = Color(0xFFE09040); // Warm amber
  static const endColor = Color(0xFFC74B4B); // Muted red

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
    Color? navBarBg,
    Color? navBarSelected,
    Color? navBarUnselected,
    Color? primaryContainer,
    Color? accent,
    Color? ringTrack,
    Color? streakColor,
    Color? activityColor,
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
      navBarBg: navBarBg ?? this.navBarBg,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      accent: accent ?? this.accent,
      ringTrack: ringTrack ?? this.ringTrack,
      streakColor: streakColor ?? this.streakColor,
      activityColor: activityColor ?? this.activityColor,
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
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected:
          Color.lerp(navBarUnselected, other.navBarUnselected, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      streakColor: Color.lerp(streakColor, other.streakColor, t)!,
      activityColor: Color.lerp(activityColor, other.activityColor, t)!,
    );
  }

  // Coarse equality: only two compile-time constants exist (light / dark).
  // copyWith is used only for lerp during theme transitions and is never
  // persisted or compared.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppColors && other.isDark == isDark);

  @override
  int get hashCode => isDark.hashCode;
}
