# 000023 - Android Exact Alarm Fallback

## Status: APPLIED

## Background

All native alarms (`ReminderScheduler`, `ReminderReceiver` settling alarm, `AlreadyMovedReceiver`, `SnoozeReceiver`) go through one helper, `AlarmManager.scheduleExact()` in `PrefsExt.kt`. It calls `setExactAndAllowWhileIdle()` without checking `canScheduleExactAlarms()`.

On Android 12+ the app needs exact alarm access. The manifest declares both `SCHEDULE_EXACT_ALARM` (revocable by the user in "Alarms & reminders") and `USE_EXACT_ALARM` (Android 13+, not revocable). On Android 12 (API 31-32) only `SCHEDULE_EXACT_ALARM` applies. If the user revokes it, `setExactAndAllowWhileIdle()` throws `SecurityException` inside a `BroadcastReceiver`, the receiver crashes and the reminder chain stops. If `USE_EXACT_ALARM` is later removed (Google Play policy), the same applies to Android 14+, where `SCHEDULE_EXACT_ALARM` is denied by default for new installs.

Found by code reading (no `canScheduleExactAlarms` or `SecurityException` handling anywhere in `android/`). Not reproduced on a device.

## Design

In `scheduleExact()`:
1. Below Android 6 (API 23): `setExact()` as before.
2. If exact alarms are allowed (below Android 12, or `canScheduleExactAlarms()` is true): `setExactAndAllowWhileIdle()`. A `SecurityException` (access revoked between the check and the call) falls through to step 3.
3. Otherwise: `setAndAllowWhileIdle()`. The reminder may come a few minutes late, but the chain survives.

Each alarm re-checks access, so once the user grants it again the next alarm is exact again. No receiver for `ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED` is needed for that.

## Affected Files

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/PrefsExt.kt` | Fallback logic in `scheduleExact()` |

## Out of scope

- UI that asks the user to grant exact alarm access.
- Removing `USE_EXACT_ALARM` from the manifest (Google Play policy decision).
- Kotlin unit tests: the project has no Android test setup, and adding test dependencies needs a separate discussion.

## Testing

- [x] `flutter build apk --debug` compiles
- [x] `flutter analyze`, `flutter test` pass
- [ ] Manual, Android 12 device or emulator: revoke "Alarms & reminders" for the app, enable reminders, wait for an alarm: no crash, reminder arrives (possibly late), the next one is scheduled
- [ ] Manual: grant access again, next reminder is on time

## Rollback

Revert `scheduleExact()` in `PrefsExt.kt`.
