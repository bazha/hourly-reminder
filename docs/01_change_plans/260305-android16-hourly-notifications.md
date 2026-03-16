# Android 16 Hourly Notifications Fix

## Problem

Hourly notifications don't fire on Android 16 (API 36). Root causes:

1. **Missing `allowWhileIdle: true`** – Without it, `AndroidAlarmManager.periodic` defers alarms during Doze mode. Android 14+ (and especially 16) applies Doze far more aggressively.
2. **Missing `USE_EXACT_ALARM` permission** – `SCHEDULE_EXACT_ALARM` requires a manual user grant on API 31+. `USE_EXACT_ALARM` (API 33+) is auto-granted for reminder/alarm apps with no user interaction needed.
3. **No resilience layer** – When exact alarms are deferred or cancelled by battery optimisation there is no recovery mechanism.

## Approach

Stack: `flutter_local_notifications` + `android_alarm_manager_plus` (primary, exact) + `workmanager` (fallback, ~hourly).

Both the exact-alarm callback and the WorkManager callback call the same pure `shouldSendReminder()` guard. The notification ID is fixed at `1`, so near-simultaneous fires just replace each other.

## Changes

| File | Change |
|---|---|
| `pubspec.yaml` | Add `workmanager: ^0.5.2` |
| `AndroidManifest.xml` | Add `USE_EXACT_ALARM` permission |
| `lib/services/alarm_service.dart` | Add `allowWhileIdle: true`; add WorkManager scheduling/cancellation; add `workmanagerCallbackDispatcher` top-level fn |
| `lib/main.dart` | Initialize Workmanager with the dispatcher |
| `test/services/alarm_service_test.dart` | Verify existing tests still pass; add WorkManager constant sanity tests |
