# Android 16 Hourly Notifications Fix — Report

## Result: ✅ Complete — 58/58 tests pass

## Root Causes Fixed

| # | Cause | Fix applied |
|---|---|---|
| 1 | `allowWhileIdle: false` (default) caused exact alarms to be deferred by Doze mode on Android 14+ | Added `allowWhileIdle: true` to `AndroidAlarmManager.periodic` |
| 2 | Only `SCHEDULE_EXACT_ALARM` declared — requires manual user grant on API 31+, often silently denied on API 36 | Added `USE_EXACT_ALARM` permission (auto-granted on API 33+ for reminder apps) |
| 3 | No fallback when exact alarm is deferred/killed by battery optimisation | Added `workmanager: 0.5.2` periodic task (≈hourly) as resilience layer |
| 4 | Pre-existing: `DarwinFlutterLocalNotificationsPlugin` does not exist in `flutter_local_notifications` v18 — broke test compilation | Fixed to `IOSFlutterLocalNotificationsPlugin` |

## Files Changed

| File | Change |
|---|---|
| `pubspec.yaml` | Added `workmanager: ^0.5.2` |
| `android/app/src/main/AndroidManifest.xml` | Added `USE_EXACT_ALARM` permission |
| `lib/services/alarm_service.dart` | Full rewrite: `allowWhileIdle: true`, WorkManager scheduling, `workmanagerCallbackDispatcher` top-level fn |
| `lib/services/notification_service.dart` | Fixed `DarwinFlutterLocalNotificationsPlugin` → `IOSFlutterLocalNotificationsPlugin` |
| `lib/main.dart` | Added `Workmanager().initialize(workmanagerCallbackDispatcher)` on Android |
| `test/services/alarm_service_test.dart` | Added WorkManager task identifier sanity tests |
| `docs/01_change_plans/260305-android16-hourly-notifications.md` | Change plan |

## Architecture After Change

```
Enable reminders
  └─► scheduleHourlyAlarm()
        ├─► AndroidAlarmManager.periodic(exact, wakeup, allowWhileIdle, rescheduleOnReboot)
        │     └─► alarmCallback() [isolate]  ──► shouldSendReminder() ──► showNotification()
        └─► Workmanager().registerPeriodicTask(hourly, replace)
              └─► workmanagerCallbackDispatcher() [isolate] ──► shouldSendReminder() ──► showNotification()
```

Both paths use the same `shouldSendReminder()` pure function. Notification ID is fixed at `1` so near-simultaneous fires replace each other without duplicates.
