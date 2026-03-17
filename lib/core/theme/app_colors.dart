import 'package:flutter/material.dart';

/// Centralized design-token palette for light and dark themes.
///
/// Usage: `final c = AppColors.of(context);`
class AppColors extends ThemeExtension<AppColors> {
  // ─── Background ──────────────────────────────────────────────────────────
  final Color bg;
  final Color bgGradientStart;
  final Color bgGradientEnd;

  // ─── Blobs (decorative background circles) ───────────────────────────────
  final Color blobPurple;
  final double blobPurpleOpacity;
  final Color blobBlue;
  final double blobBlueOpacity;
  final Color blobAccent;
  final double blobAccentOpacity;

  // ─── Cards (glassmorphism) ───────────────────────────────────────────────
  final Color cardBg;
  final Color cardBorder;
  final Color cardShadow;

  // ─── Text ────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ─── Controls ────────────────────────────────────────────────────────────
  final Color switchInactiveTrack;
  final Color switchInactiveThumb;
  final Color sliderInactiveTrack;
  final Color sliderThumb;
  final Color divider;
  final Color clockPillBg;
  final Color clockPillBorder;

  // ─── Clock face ──────────────────────────────────────────────────────────
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

  // ─── Time picker dialog ──────────────────────────────────────────────────
  final Color pickerBg;
  final Color pickerInputBg;
  final Color pickerText;

  // ─── Gradient button ─────────────────────────────────────────────────────
  final Color buttonTextColor;

  // ─── AppBar ──────────────────────────────────────────────────────────────
  final Color appBarBg;
  final Color appBarFg;

  // ─── Slider inactive tints ───────────────────────────────────────────────
  final Color startSliderInactive;
  final Color endSliderInactive;

  // ─── Weekend switch ──────────────────────────────────────────────────────
  final Color weekendSwitchActive;

  const AppColors._({
    required this.bg,
    required this.bgGradientStart,
    required this.bgGradientEnd,
    required this.blobPurple,
    required this.blobPurpleOpacity,
    required this.blobBlue,
    required this.blobBlueOpacity,
    required this.blobAccent,
    required this.blobAccentOpacity,
    required this.cardBg,
    required this.cardBorder,
    required this.cardShadow,
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
    required this.appBarBg,
    required this.appBarFg,
    required this.startSliderInactive,
    required this.endSliderInactive,
    required this.weekendSwitchActive,
  });

  /// Dark glassmorphism theme (current design).
  static const dark = AppColors._(
    bg:              Color(0xFF060B18),
    bgGradientStart: Color(0xFF060812),
    bgGradientEnd:   Color(0xFF0E0B24),
    blobPurple:       Color(0xFF6D28D9),
    blobPurpleOpacity: 0.28,
    blobBlue:         Color(0xFF1D4ED8),
    blobBlueOpacity:   0.22,
    blobAccent:       Color(0xFF7C3AED),
    blobAccentOpacity: 0.14,
    cardBg:          Color(0x0DFFFFFF),  // 5% white
    cardBorder:      Color(0x1AFFFFFF),  // 10% white
    cardShadow:      Colors.black,
    textPrimary:     Colors.white,
    textSecondary:   Color(0x99FFFFFF),  // 60% white
    textMuted:       Color(0x4DFFFFFF),  // 30% white
    switchInactiveTrack: Color(0xFF94A3B8),
    switchInactiveThumb: Color(0xDEFFFFFF), // 87% white
    sliderInactiveTrack: Color(0x14FFFFFF), // 8% white
    sliderThumb:     Colors.white,
    divider:         Color(0x14FFFFFF),  // 8% white
    clockPillBg:     Color(0x12FFFFFF),  // 7% white
    clockPillBorder: Color(0x1AFFFFFF),  // 10% white
    clockFaceInner:  Color(0xFF152040),
    clockFaceOuter:  Color(0xFF080D1A),
    clockRing:       Color(0x0FFFFFFF),  // 6% white
    clockBorder:     Color(0x14FFFFFF),  // 8% white
    clockTickKey:    Color(0xA6FFFFFF),  // 65% white
    clockTickHalf:   Color(0x4DFFFFFF),  // 30% white
    clockTickMinor:  Color(0x1FFFFFFF),  // 12% white
    clockLabelColor: Color(0x66FFFFFF),  // 40% white
    clockCenterDot:  Colors.white,
    clockCenterGlow: Color(0x33FFFFFF),
    clockHandleRing: Color(0x2EFFFFFF),  // 18% white
    pickerBg:        Color(0xFF101828),
    pickerInputBg:   Color(0x26818CF8),  // 15% primary
    pickerText:      Colors.white,
    buttonTextColor: Colors.white,
    appBarBg:        Color(0xFF1A2233),
    appBarFg:        Colors.white,
    startSliderInactive: Color(0x2634D399), // 15% emerald
    endSliderInactive:   Color(0x26FB7185), // 15% rose
    weekendSwitchActive: Color(0xFF64748B),
  );

  /// Light theme — soft white background, subtle blobs, dark text.
  static const light = AppColors._(
    bg:              Color(0xFFF5F6FA),
    bgGradientStart: Color(0xFFF7F7FC),
    bgGradientEnd:   Color(0xFFEDE9FE),
    blobPurple:       Color(0xFFC4B5FD),
    blobPurpleOpacity: 0.35,
    blobBlue:         Color(0xFF93C5FD),
    blobBlueOpacity:   0.25,
    blobAccent:       Color(0xFFA78BFA),
    blobAccentOpacity: 0.18,
    cardBg:          Color(0xC0FFFFFF),  // 75% white
    cardBorder:      Color(0x1A000000),  // 10% black
    cardShadow:      Color(0x14000000),  // 8% black
    textPrimary:     Color(0xFF1E1B4B),  // deep indigo
    textSecondary:   Color(0x993C3560),  // 60% muted
    textMuted:       Color(0x4D3C3560),  // 30% muted
    switchInactiveTrack: Color(0xFFCBD5E1),
    switchInactiveThumb: Color(0xFF64748B),
    sliderInactiveTrack: Color(0x1A000000), // 10% black
    sliderThumb:     Color(0xFF1E1B4B),
    divider:         Color(0x14000000),  // 8% black
    clockPillBg:     Color(0x0A000000),  // 4% black
    clockPillBorder: Color(0x14000000),  // 8% black
    clockFaceInner:  Color(0xFFE8E5F5),
    clockFaceOuter:  Color(0xFFD6D1EC),
    clockRing:       Color(0x1A000000),  // 10% black
    clockBorder:     Color(0x14000000),  // 8% black
    clockTickKey:    Color(0xA6302050),  // 65% dark
    clockTickHalf:   Color(0x4D302050),  // 30% dark
    clockTickMinor:  Color(0x1F302050),  // 12% dark
    clockLabelColor: Color(0x66302050),  // 40% dark
    clockCenterDot:  Color(0xFF1E1B4B),
    clockCenterGlow: Color(0x33302050),
    clockHandleRing: Color(0x2E000000),  // 18% black
    pickerBg:        Color(0xFFF5F6FA),
    pickerInputBg:   Color(0x1A818CF8),  // 10% primary
    pickerText:      Color(0xFF1E1B4B),
    buttonTextColor: Colors.white,
    appBarBg:        Color(0xFF90A4AE),
    appBarFg:        Colors.white,
    startSliderInactive: Color(0xFFE8F5E9),
    endSliderInactive:   Color(0xFFFFEBEE),
    weekendSwitchActive: Color(0xFF90A4AE),
  );

  /// Resolves the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  bool get isDark => bg == dark.bg;

  // ─── Shared accent colours (same in both themes) ──────────────────────────
  static const startColor = Color(0xFF34D399);   // Emerald
  static const endColor   = Color(0xFFFB7185);   // Rose
  static const primary    = Color(0xFF818CF8);   // Indigo
  static const nowColor   = Color(0xFFFBBF24);   // Amber (clock "now" hand)

  // ─── ThemeExtension overrides ─────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? bg,
    Color? bgGradientStart,
    Color? bgGradientEnd,
    Color? blobPurple,
    double? blobPurpleOpacity,
    Color? blobBlue,
    double? blobBlueOpacity,
    Color? blobAccent,
    double? blobAccentOpacity,
    Color? cardBg,
    Color? cardBorder,
    Color? cardShadow,
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
    Color? appBarBg,
    Color? appBarFg,
    Color? startSliderInactive,
    Color? endSliderInactive,
    Color? weekendSwitchActive,
  }) {
    return AppColors._(
      bg: bg ?? this.bg,
      bgGradientStart: bgGradientStart ?? this.bgGradientStart,
      bgGradientEnd: bgGradientEnd ?? this.bgGradientEnd,
      blobPurple: blobPurple ?? this.blobPurple,
      blobPurpleOpacity: blobPurpleOpacity ?? this.blobPurpleOpacity,
      blobBlue: blobBlue ?? this.blobBlue,
      blobBlueOpacity: blobBlueOpacity ?? this.blobBlueOpacity,
      blobAccent: blobAccent ?? this.blobAccent,
      blobAccentOpacity: blobAccentOpacity ?? this.blobAccentOpacity,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
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
      appBarBg: appBarBg ?? this.appBarBg,
      appBarFg: appBarFg ?? this.appBarFg,
      startSliderInactive: startSliderInactive ?? this.startSliderInactive,
      endSliderInactive: endSliderInactive ?? this.endSliderInactive,
      weekendSwitchActive: weekendSwitchActive ?? this.weekendSwitchActive,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors._(
      bg: Color.lerp(bg, other.bg, t)!,
      bgGradientStart: Color.lerp(bgGradientStart, other.bgGradientStart, t)!,
      bgGradientEnd: Color.lerp(bgGradientEnd, other.bgGradientEnd, t)!,
      blobPurple: Color.lerp(blobPurple, other.blobPurple, t)!,
      blobPurpleOpacity: blobPurpleOpacity + (other.blobPurpleOpacity - blobPurpleOpacity) * t,
      blobBlue: Color.lerp(blobBlue, other.blobBlue, t)!,
      blobBlueOpacity: blobBlueOpacity + (other.blobBlueOpacity - blobBlueOpacity) * t,
      blobAccent: Color.lerp(blobAccent, other.blobAccent, t)!,
      blobAccentOpacity: blobAccentOpacity + (other.blobAccentOpacity - blobAccentOpacity) * t,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
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
      appBarBg: Color.lerp(appBarBg, other.appBarBg, t)!,
      appBarFg: Color.lerp(appBarFg, other.appBarFg, t)!,
      startSliderInactive: Color.lerp(startSliderInactive, other.startSliderInactive, t)!,
      endSliderInactive: Color.lerp(endSliderInactive, other.endSliderInactive, t)!,
      weekendSwitchActive: Color.lerp(weekendSwitchActive, other.weekendSwitchActive, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppColors && other.bg == bg);

  @override
  int get hashCode => bg.hashCode;
}
