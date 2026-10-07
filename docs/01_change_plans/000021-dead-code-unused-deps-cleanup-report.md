# 000021 - Dead Code, Unused Dependencies, and Key Constants Cleanup: Completion Report

## Summary

All 4 batches of [000021-dead-code-unused-deps-cleanup.md](000021-dead-code-unused-deps-cleanup.md) are applied. Before each removal the code was re-checked: nothing had started using the removed items since the plan was written.

## Changes Made

| Batch | Change |
|---|---|
| 1 | `lib/core/theme/app_colors.dart`: removed 12 dead fields (`clock*`, `pickerInputBg`) from the field list, constructor, both palettes, `copyWith` and `lerp` (86 lines) |
| 2 | `pubspec.yaml`: removed `cupertino_icons` and `permission_handler`. `flutter pub get` removed 7 packages from `pubspec.lock` (no other version changes) and the `permission_handler_windows` registration from the generated Windows plugin files |
| 3 | `StorageService.appLocaleKey` and `StorageService.appThemeModeKey` replace the `'app_locale'` / `'app_theme_mode'` literals in `main.dart` and `notification_l10n.dart` |
| 4 | Removed `todayLabel` from the 3 ARB files, regenerated l10n with `flutter gen-l10n` (only `todayLabel` removed from the generated files) |

## Deviations from the plan

- **Batch 3:** the plan proposed private constants in `main.dart` plus a copy in `notification_service.dart`. Since plan 000022 the locale lookup lives in `notification_l10n.dart`, so the key is needed in two files. One public constant in `StorageService` (the SharedPreferences wrapper) avoids the copy.
- **`ios/Podfile.lock` not updated.** It still lists `permission_handler_apple`. The next `pod install` (run automatically by `flutter build ios` / `flutter run`) removes it.

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` | 86/86 pass |
| `dart format` | Clean |
| `flutter build apk --debug` | Builds |
| iOS build | Not run (iOS 26.5 platform not installed in Xcode) |

## Not done (out of plan scope)

Other hardcoded prefs keys remain as string literals: `'day_off_date'` and `'reminder_interval_minutes'` (also read in `movement_action_handler.dart`), plus all `StorageService` keys. The plan lists these as out of scope.
