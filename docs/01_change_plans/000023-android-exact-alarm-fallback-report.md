# 000023 - Android Exact Alarm Fallback: Completion Report

## Summary

`AlarmManager.scheduleExact()` in `PrefsExt.kt` now falls back to `setAndAllowWhileIdle()` when exact alarm access is missing (`canScheduleExactAlarms()` is false on Android 12+) or when `setExactAndAllowWhileIdle()` throws `SecurityException`. All 4 native alarm call sites use this helper, so none of them can crash the receiver and stop the reminder chain any more.

## Verification

| Check | Result |
|---|---|
| `flutter build apk --debug` | Builds. The compiled `PrefsExtKt.class` contains `canScheduleExactAlarms`, `setAndAllowWhileIdle` and the `SecurityException` handler |
| `flutter analyze`, `flutter test` | Clean, 86/86 pass |
| Manual test on Android 12 with "Alarms & reminders" revoked | **Not done** |
| Kotlin unit tests | None (no Android test setup in the project) |

## Notes

- With `USE_EXACT_ALARM` still declared, Android 13+ always has exact access. The fallback matters on Android 12 today, and on all versions if `USE_EXACT_ALARM` is removed for Google Play.
- No UI asks the user to restore exact access. Reminders may come a few minutes late until access is granted again.
