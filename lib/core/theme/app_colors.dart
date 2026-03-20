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
  final Color clockPillBg;
  final Color clockPillBorder;

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

  // --- Slider inactive tints ---
  final Color startSliderInactive;
  final Color endSliderInactive;

  // --- Weekend switch ---
  final Color weekendSwitchActive;

  // --- Navigation bar ---
  final Color navBarBg;
  final Color navBarSelected;
  final Color navBarUnselected;

  // --- Surfaces ---
  final Color surface;
  final Color onSurface;
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
    required this.clockPillBg,
    required this.clockPillBorder,
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
    required this.startSliderInactive,
    required this.endSliderInactive,
    required this.weekendSwitchActive,
    required this.navBarBg,
    required this.navBarSelected,
    required this.navBarUnselected,
    required this.surface,
    required this.onSurface,
    required this.primaryContainer,
    required this.accent,
  });

  /// Dark theme - charcoal background, elevated dark cards.
  static const dark = AppColors._(
    bg:              Color(0xFF15181E),
    cardBg:          Color(0xFF1E2128),
    cardBorder:      Color(0x14FFFFFF),
    textPrimary:     Color(0xFFE8E8E8),
    textSecondary:   Color(0xFF8E95A2),
    textMuted:       Color(0xFF5A6070),
    switchInactiveTrack: Color(0xFF3A3F4A),
    switchInactiveThumb: Color(0xFF8E95A2),
    sliderInactiveTrack: Color(0xFF2A2F38),
    sliderThumb:     Color(0xFF5CC4B8),
    divider:         Color(0xFF2A2F38),
    clockPillBg:     Color(0xFF252A32),
    clockPillBorder: Color(0x14FFFFFF),
    clockFaceInner:  Color(0xFF252A32),
    clockFaceOuter:  Color(0xFF1A1E24),
    clockRing:       Color(0x14FFFFFF),
    clockBorder:     Color(0x14FFFFFF),
    clockTickKey:    Color(0xA6E8E8E8),
    clockTickHalf:   Color(0x4DE8E8E8),
    clockTickMinor:  Color(0x1FE8E8E8),
    clockLabelColor: Color(0x66E8E8E8),
    clockCenterDot:  Color(0xFFE8E8E8),
    clockCenterGlow: Color(0x33E8E8E8),
    clockHandleRing: Color(0x2EFFFFFF),
    pickerBg:        Color(0xFF1E2128),
    pickerInputBg:   Color(0x265CC4B8),
    pickerText:      Color(0xFFE8E8E8),
    buttonTextColor: Colors.white,
    startSliderInactive: Color(0x264EAAA0),
    endSliderInactive:   Color(0x26E57373),
    weekendSwitchActive: Color(0xFF5CC4B8),
    navBarBg:        Color(0xFF1E2128),
    navBarSelected:  Color(0xFF5CC4B8),
    navBarUnselected: Color(0xFF5A6070),
    surface:         Color(0xFF1E2128),
    onSurface:       Color(0xFFE8E8E8),
    primaryContainer: Color(0xFF1A3A36),
    accent:          Color(0xFFF5A623),
  );

  /// Light theme - warm off-white background, clean white cards.
  static const light = AppColors._(
    bg:              Color(0xFFF5F3EE),
    cardBg:          Color(0xFFFFFFFF),
    cardBorder:      Color(0x0D000000),
    textPrimary:     Color(0xFF1A1C1E),
    textSecondary:   Color(0xFF6B7280),
    textMuted:       Color(0xFF9CA3AF),
    switchInactiveTrack: Color(0xFFD1D5DB),
    switchInactiveThumb: Color(0xFF9CA3AF),
    sliderInactiveTrack: Color(0xFFE5E7EB),
    sliderThumb:     Color(0xFF4EAAA0),
    divider:         Color(0xFFE5E7EB),
    clockPillBg:     Color(0xFFF0EDE8),
    clockPillBorder: Color(0x14000000),
    clockFaceInner:  Color(0xFFF0EDE8),
    clockFaceOuter:  Color(0xFFE5E1DB),
    clockRing:       Color(0x1A000000),
    clockBorder:     Color(0x14000000),
    clockTickKey:    Color(0xA61A1C1E),
    clockTickHalf:   Color(0x4D1A1C1E),
    clockTickMinor:  Color(0x1F1A1C1E),
    clockLabelColor: Color(0x661A1C1E),
    clockCenterDot:  Color(0xFF1A1C1E),
    clockCenterGlow: Color(0x331A1C1E),
    clockHandleRing: Color(0x2E000000),
    pickerBg:        Color(0xFFF5F3EE),
    pickerInputBg:   Color(0x1A4EAAA0),
    pickerText:      Color(0xFF1A1C1E),
    buttonTextColor: Colors.white,
    startSliderInactive: Color(0x1A4EAAA0),
    endSliderInactive:   Color(0x1AE57373),
    weekendSwitchActive: Color(0xFF4EAAA0),
    navBarBg:        Color(0xFFFFFFFF),
    navBarSelected:  Color(0xFF4EAAA0),
    navBarUnselected: Color(0xFF9CA3AF),
    surface:         Color(0xFFFFFFFF),
    onSurface:       Color(0xFF1A1C1E),
    primaryContainer: Color(0xFFE6F5F3),
    accent:          Color(0xFFF5A623),
  );

  /// Resolves the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  bool get isDark => identical(this, dark) || bg == dark.bg;

  // --- Shared accent colours (same in both themes) ---
  static const startColor = Color(0xFF4EAAA0);   // Teal
  static const endColor   = Color(0xFFE57373);    // Coral
  static const primary    = Color(0xFF4EAAA0);    // Teal
  static const nowColor   = Color(0xFFF5A623);    // Amber

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
    Color? clockPillBg,
    Color? clockPillBorder,
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
    Color? startSliderInactive,
    Color? endSliderInactive,
    Color? weekendSwitchActive,
    Color? navBarBg,
    Color? navBarSelected,
    Color? navBarUnselected,
    Color? surface,
    Color? onSurface,
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
      clockPillBg: clockPillBg ?? this.clockPillBg,
      clockPillBorder: clockPillBorder ?? this.clockPillBorder,
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
      startSliderInactive: startSliderInactive ?? this.startSliderInactive,
      endSliderInactive: endSliderInactive ?? this.endSliderInactive,
      weekendSwitchActive: weekendSwitchActive ?? this.weekendSwitchActive,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
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
      switchInactiveTrack: Color.lerp(switchInactiveTrack, other.switchInactiveTrack, t)!,
      switchInactiveThumb: Color.lerp(switchInactiveThumb, other.switchInactiveThumb, t)!,
      sliderInactiveTrack: Color.lerp(sliderInactiveTrack, other.sliderInactiveTrack, t)!,
      sliderThumb: Color.lerp(sliderThumb, other.sliderThumb, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      clockPillBg: Color.lerp(clockPillBg, other.clockPillBg, t)!,
      clockPillBorder: Color.lerp(clockPillBorder, other.clockPillBorder, t)!,
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
      startSliderInactive: Color.lerp(startSliderInactive, other.startSliderInactive, t)!,
      endSliderInactive: Color.lerp(endSliderInactive, other.endSliderInactive, t)!,
      weekendSwitchActive: Color.lerp(weekendSwitchActive, other.weekendSwitchActive, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected: Color.lerp(navBarUnselected, other.navBarUnselected, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppColors && other.bg == bg && other.cardBg == cardBg &&
       other.textPrimary == textPrimary);

  @override
  int get hashCode => Object.hash(bg, cardBg, textPrimary);
}
