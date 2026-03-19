import 'package:flutter/material.dart';

/// Text style constants for the redesigned UI.
///
/// Usage: `AppTypography.heading`, `AppTypography.cardTitle`, etc.
/// Colors are NOT baked in - apply color at the call site via `.copyWith(color:)`.
class AppTypography {
  AppTypography._();

  static const heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const statNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static const clockLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );
}
