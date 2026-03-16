# Hourly Notification Feature — Review & Work Done

**Date:** 2026-02-18  
**Status:** Complete — 49/49 unit tests passing

---

## Feature Overview

The app sends an hourly push notification ("Время встать! ⏰ — Пора размяться и походить 🚶") reminding the user to stand up and move during work hours. The user can configure:

- Enable / disable reminders
- Work window start and end hour (default 09:00–18:00)
- Whether to skip weekends (default: skip)

---

## How It Works — End-to-End Flow

```
App launch
  └── main.dart
        ├── AndroidAlarmManager.initialize()
        ├── NotificationService.initialize()
        └── StorageService.initialize()

User enables reminders
  └── HomeScreen → AlarmService.scheduleHourlyAlarm()
        └── AndroidAlarmManager.periodic(
              duration: 1 hour,
              startAt: next full hour,
              exact: true, wakeup: true, rescheduleOnReboot: true
            )

Every hour (OS fires alarm in a fresh isolate)
  └── AlarmService.alarmCallback()
        ├── StorageService.initialize()       ← must re-init in isolate
        ├── AlarmService.shouldSendReminder() ← pure decision check
        │     ├── isEnabled?
        │     ├── now.hour in [startHour, endHour]?
        │     └── not a weekend when excludeWeekends=true?
        ├── NotificationService.initialize()
        └── NotificationService.showHourlyNotification()
```

---

## Files Involved

| File | Role |
|---|---|
| [lib/services/alarm_service.dart](../lib/services/alarm_service.dart) | Schedules/cancels the periodic alarm; owns `shouldSendReminder` and `alarmCallback` |
| [lib/services/notification_service.dart](../lib/services/notification_service.dart) | Creates the Android notification channel and posts the notification |
| [lib/services/storage_service.dart](../lib/services/storage_service.dart) | Persists user preferences; provides both async (UI) and sync (isolate) accessors |
| [lib/models/user_preferences.dart](../lib/models/user_preferences.dart) | Immutable value object for all user settings |
| [lib/main.dart](../lib/main.dart) | Sequential service initialisation on startup |

---

## Bugs Found and Fixed

### Bug 1 — `RangeError` crash at 23:xx

**File:** `lib/services/alarm_service.dart` — `_getNextHourStart()`

```dart
// Before — crashes when now.hour == 23 (hour 24 is invalid)
return DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

// After — Duration arithmetic rolls over midnight correctly
final next = now.add(const Duration(hours: 1));
return DateTime(next.year, next.month, next.day, next.hour, 0, 0);
```

---

### Bug 2 — Notifications never sent (isolate has no shared memory)

**File:** `lib/services/alarm_service.dart` — `alarmCallback()`

`AndroidAlarmManager` fires the callback in a **fresh Dart isolate**. Static fields (`_prefs`, `_initialized`) are not shared across isolates — they start as `null`/`false`. The old code read `StorageService.isEnabled` before initialising, which silently returned the fallback `false`, so `shouldSendReminder` always returned `false` and no notification was ever sent.

```dart
// Fix: initialise StorageService and NotificationService inside the callback
static Future<void> alarmCallback() async {
  await StorageService.initialize();
  // ... check shouldSendReminder ...
  await NotificationService.initialize();
  await NotificationService.showHourlyNotification();
}
```

---

### Bug 3 — `void` callback prevents awaiting notification

**File:** `lib/services/alarm_service.dart` — `alarmCallback()`

`AndroidAlarmManager` requires `Future<void>`. A `void` return type meant the OS could kill the isolate before `showHourlyNotification()` completed. Changed the signature to `Future<void>` and made it `async`.

---

## Refactoring Done

### Extracted `shouldSendReminder` pure function

The notification-firing decision was extracted from `alarmCallback` into a standalone static method:

```dart
static bool shouldSendReminder({
  required DateTime now,
  required bool isEnabled,
  required int startHour,
  required int endHour,
  required bool excludeWeekends,
})
```

This has no platform or plugin dependencies, making it fully unit-testable without mocking.

---

## Unit Tests Created

### `test/models/user_preferences_test.dart` — 13 tests

| Group | Tests |
|---|---|
| defaults | Correct default values |
| copyWith | No args, override each field independently |
| time getters | `startTime` and `endTime` as `double` |
| equality | Identical instances equal, each field difference breaks equality, hashCode consistency |

### `test/services/alarm_service_test.dart` — 23 tests

| Group | Tests |
|---|---|
| disabled reminders | Returns false regardless of time/day |
| enabled — work window | Start, middle, end fire; before and after do not |
| custom hours | Narrow window (12–13), early morning (6–8) |
| weekend exclusion | Sat/Sun blocked when flag set; allowed when unset; weekdays always pass |
| boundary conditions | Exactly at startHour/endHour, single-hour window, Friday is not a weekend |
| regression: midnight roll-over | No throw at 23:30, correct firing/suppression around midnight |

### `test/services/storage_service_test.dart` — 13 tests

| Group | Tests |
|---|---|
| initialize | Succeeds, safe to call multiple times |
| loadPreferences | Defaults when empty, round-trip after save, each field persisted independently |
| savePreferences | Overwrites previous values |
| sync getters (alarm isolate) | All four getters return defaults; reflect saved values after write |

---

## Test Results

```
flutter test test/models/user_preferences_test.dart \
             test/services/alarm_service_test.dart \
             test/services/storage_service_test.dart

49 tests — All passed ✓
```

---

## Dependency Added

`mockito: ^5.4.4` and `build_runner: ^2.4.13` added to `dev_dependencies` in `pubspec.yaml` for future mock-based tests.
