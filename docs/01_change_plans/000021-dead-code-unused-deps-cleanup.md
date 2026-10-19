# 000021 - Dead Code, Unused Dependencies, and Key Constants Cleanup

## Status: APPLIED

See [000021-dead-code-unused-deps-cleanup-report.md](000021-dead-code-unused-deps-cleanup-report.md).

## Background

Final deep analysis after 7 rounds of cleanup. Found 12 dead `AppColors` fields from the removed `WorkHoursClock` widget (PR #26), 2 unused pubspec dependencies, 1 unused l10n key, and hardcoded prefs key strings on the Dart side.

## Batch 1: Remove dead `AppColors` clock fields (highest impact)

The `WorkHoursClock` widget was removed in PR #26 (home screen redesign), but its 12 dedicated color fields remain in `AppColors`. They appear only in `app_colors.dart` itself (constructor, light/dark constants, copyWith, lerp). No other file references them.

**Dead fields (12):**
`clockFaceInner`, `clockFaceOuter`, `clockRing`, `clockBorder`, `clockTickKey`, `clockTickHalf`, `clockTickMinor`, `clockLabelColor`, `clockCenterDot`, `clockCenterGlow`, `clockHandleRing`, `pickerInputBg`

| File | Change |
|------|--------|
| `lib/core/theme/app_colors.dart` | Remove 12 fields, their constructor params, their values in `light`/`dark` constants, their entries in `copyWith`, and their entries in `lerp` |

## Batch 2: Remove unused dependencies

### 2.1 Remove `cupertino_icons`

No file in `lib/` references `CupertinoIcons`. The app uses Material Icons exclusively.

| File | Change |
|------|--------|
| `pubspec.yaml` | Remove `cupertino_icons: ^1.0.8` |

### 2.2 Remove `permission_handler`

No Dart file imports `permission_handler`. Notification permissions are requested via `flutter_local_notifications` plugin directly (`requestNotificationsPermission()` on Android, `requestPermissions()` on iOS).

| File | Change |
|------|--------|
| `pubspec.yaml` | Remove `permission_handler: ^12.0.1` |

## Batch 3: Extract Dart-side prefs key constants

### 3.1 Extract `app_locale` and `app_theme_mode` to constants

`'app_locale'` appears 4 times across `main.dart` and `notification_service.dart`. `'app_theme_mode'` appears 3 times in `main.dart`. These should be constants to match the Kotlin-side `PrefsKeys` pattern.

| File | Change |
|------|--------|
| `lib/main.dart` | Add private constants `_kAppLocale` and `_kAppThemeMode`, replace all string literals |
| `lib/services/notification_service.dart` | Import and use the locale constant (or duplicate as private const since it's a single usage) |

## Batch 4: Remove unused l10n key

`todayLabel` is defined in all 3 localization files and the abstract class but never referenced in any `lib/` file.

| File | Change |
|------|--------|
| `lib/l10n/app_en.arb` | Remove `todayLabel` entry |
| `lib/l10n/app_ru.arb` | Remove `todayLabel` entry |
| `lib/l10n/app_be.arb` | Remove `todayLabel` entry |

Then run `flutter gen-l10n` to regenerate the Dart l10n files.

## Out of scope

- **Dart-side full `PrefsKeys` mirror**: StorageService keys like `'is_enabled'`, `'start_hour'` etc. work correctly because the Flutter SharedPreferences plugin adds the `flutter.` prefix automatically. Extracting them to constants is valid refactoring but lower priority since there's no cross-layer sync risk.
- **`flutter_lints` vs `lints` upgrade**: Works fine, not worth the churn.

## Testing

- Run `flutter analyze` and `flutter test` after each batch
- Run `flutter pub get` after dependency removal
- Run `flutter gen-l10n` after ARB changes
- Build Android APK to verify no Kotlin compilation errors

## Implementation order

1. Batch 1: Dead AppColors fields (largest change, reduces class size by ~30%)
2. Batch 2: Unused dependencies
3. Batch 3: Dart prefs key constants
4. Batch 4: Unused l10n key
