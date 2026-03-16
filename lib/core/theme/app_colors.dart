import 'package:flutter/material.dart';

/// Centralized design-token palette for light and dark themes.
///
/// Usage: `final c = AppColors.of(context);`
class AppColors {
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
  );

  /// Resolves the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
  }

  bool get isDark => bg == dark.bg;

  // ─── Shared accent colours (same in both themes) ──────────────────────────
  static const startColor = Color(0xFF34D399);   // Emerald
  static const endColor   = Color(0xFFFB7185);   // Rose
  static const primary    = Color(0xFF818CF8);   // Indigo
  static const nowColor   = Color(0xFFFBBF24);   // Amber (clock "now" hand)

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppColors && other.bg == bg);

  @override
  int get hashCode => bg.hashCode;
}
