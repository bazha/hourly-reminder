# Change Plan: System Theme Adaptation (Light / Dark)

**Status**: Applied

## Problem

The app has a comprehensive `AppColors` system (`lib/core/theme/app_colors.dart`) with full light and dark palettes (32 tokens each), but it's not wired into `MaterialApp`. The `MaterialApp` only defines a light theme with no `darkTheme` or `themeMode`. The `WorkHoursClock` widget already uses `AppColors.of(context)` correctly, but `HomeScreen` has ~24 hardcoded colors ignoring `AppColors` entirely.

Goal: make the app automatically follow the device's light/dark setting with zero hardcoded colors in the widget tree.

## Approach

Convert `AppColors` to a `ThemeExtension<AppColors>`, register it in both `ThemeData` instances, and replace all hardcoded colors in `HomeScreen`.

## Files modified

### 1. `lib/core/theme/app_colors.dart` - Convert to ThemeExtension

- Made `AppColors` extend `ThemeExtension<AppColors>`
- Added `copyWith()` and `lerp()` methods (required by ThemeExtension)
- Updated `of(context)` to use `Theme.of(context).extension<AppColors>()!` instead of brightness check
- Added new tokens needed by HomeScreen:
  - `appBarBg` - AppBar background color
  - `appBarFg` - AppBar foreground/text color
  - `startSliderInactive` - light tint of start color for inactive slider track
  - `endSliderInactive` - light tint of end color for inactive slider track
  - `weekendSwitchActive` - weekend toggle switches active color

### 2. `lib/main.dart` - Wire up dual themes

- Added `themeMode: ThemeMode.system`
- Added `darkTheme` with `AppColors.dark` extension
- Registered `AppColors.light` in the light theme

### 3. `lib/screens/home_screen.dart` - Replace all hardcoded colors

Used `final colors = AppColors.of(context)` at the top of `build()` and replaced every hardcoded color:

| Hardcoded | Replacement |
|-----------|-------------|
| `Color(0xFFFAFAFA)` scaffold bg | `colors.bg` |
| `Color(0xFF90A4AE)` appbar bg | `colors.appBarBg` |
| `Colors.white` appbar fg | `colors.appBarFg` |
| `Colors.white` card bg | `colors.cardBg` |
| `Colors.grey[800]` heading text | `colors.textPrimary` |
| `Colors.grey[600]` subtext | `colors.textSecondary` |
| `Colors.grey[700]` label text | `colors.textSecondary` |
| `Color(0xFF66BB6A)` start indicators | `AppColors.startColor` |
| `Color(0xFFEF5350)` end indicators | `AppColors.endColor` |
| `Color(0xFF66BB6A)` switch active | `AppColors.startColor` |
| `Color(0xFFE8F5E9)` start slider inactive | `colors.startSliderInactive` |
| `Color(0xFFFFEBEE)` end slider inactive | `colors.endSliderInactive` |
| `Color(0xFF90A4AE)` weekend switch | `colors.weekendSwitchActive` |
| `Color(0xFF66BB6A)` snackbar bg | `AppColors.startColor` |
| `Color(0xFF90A4AE)` button bg | `colors.appBarBg` |
| `Colors.white` button fg | `colors.appBarFg` |

### 4. `lib/widgets/work_hours_clock.dart` - Fix one hardcoded color

Line 338: replaced `Colors.white` for handle time label text with `colors.buttonTextColor`.

## Tests

### Updated: `test/core/theme/app_colors_test.dart`

- Updated existing `AppColors.of` tests to use ThemeExtension-based resolution
- Added: theme switches without restart (pump with different theme)
- Added: `copyWith` produces valid instance with overridden field
- Added: `copyWith` with no args returns equivalent instance
- Added: `lerp` at 0, 1, and 0.5 produces correct values
- Added: new token completeness checks for both palettes

### Updated: `test/widgets/work_hours_clock_test.dart`

- Added `AppColors` extension to test `ThemeData` so `AppColors.of(context)` resolves correctly

## Verification

1. `flutter analyze` - no new warnings (pre-existing ones only)
2. `flutter test` - all 154 tests pass

## Rollback

Revert the 4 modified production files and 2 test files. No new production files were created.
