# Change Plan: Codebase Refactoring + Test Coverage

## Summary
Fix all code quality issues found during review and add comprehensive unit, widget, and integration tests.

## Changes Made

### Phase 1 — Code Fixes

1. **Consolidated duplicate accent colors** — Moved `startColor`, `endColor`, `primary`, `nowColor` to `AppColors` as shared static constants. Removed duplicates from `home_screen.dart` and `work_hours_clock.dart`.

2. **Fixed deprecated `MediaQueryData.fromView`** — Replaced with `MediaQuery.sizeOf(context).height` in `_Background` widget.

3. **Migrated 36× `withOpacity()` → `withValues(alpha:)`** — All calls in `home_screen.dart` and `work_hours_clock.dart` updated to use the non-deprecated API.

4. **Consolidated `TimeUtils` methods** — `formatTime(double)` now delegates to `formatHourMinute(int, int)`. Removed dead `formatHour()` method.

5. **Removed dead `pulse` parameter** — Inlined as `_pulse = 0.7` constant inside `_ClockPainter`. Removed from constructor and caller.

6. **Added `==`/`hashCode` to `AppColors`** — Compares on `bg` field for correct `shouldRepaint` behavior.

### Phase 2 — Unit Tests (44 new tests)

- `test/core/utils/time_utils_test.dart` — 13 tests covering `formatTime`, `formatHourMinute`, edge cases, delegation equivalence
- `test/core/theme/app_colors_test.dart` — 13 tests covering dark/light palettes, equality, `of(context)`, shared accent constants, token completeness
- `test/widgets/work_hours_clock_test.dart` — 6 tests covering rendering (dark/light/edge values), size, gesture callbacks
- `test/widget_test.dart` — 12 expanded tests (was 2) covering theme support, UI elements, toggles, sliders, time pills

### Phase 3 — Integration Tests

- `integration_test/app_test.dart` — 7 integration tests covering full user flow
- Added `integration_test` SDK dependency to `pubspec.yaml`

## Results
- **0 analyzer issues** (down from 43)
- **117/117 tests pass** (up from 73)
- **7 integration tests** ready for device execution
