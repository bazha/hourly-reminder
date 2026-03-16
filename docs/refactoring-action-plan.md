# Refactoring Action Plan

_Generated: 2026-02-18_

Findings from four parallel analyses: duplicate code, dead code, error handling, security.  
Each item has a priority, effort estimate, and links to affected files.

---

## Priority 1 — Critical / High Impact

### SEC-1: Release build signed with debug keystore
**File:** [android/app/build.gradle.kts](android/app/build.gradle.kts)  
**Category:** Security  
**Effort:** S (30 min)  
Any APK/AAB built `--release` is signed with `signingConfigs.getByName("debug")`. Distributing this allows silent replacement.  
**Action:** Create a release signing config; store keystore credentials outside source control (env vars or `local.properties`).

---

### ERR-1: `main.dart` rethrow causes blank crash screen on init failure
**File:** [lib/main.dart](lib/main.dart) ~L19  
**Category:** Error Handling  
**Effort:** S (1 hour)  
`rethrow` after `appLogger.e()` propagates past `main()` → unhandled exception → native crash or Flutter red screen with no user message.  
**Action:** Replace `rethrow` with a fallback `runApp` that shows a localized error screen, or register `FlutterError.onError` / `PlatformDispatcher.instance.onError` before re-throwing.

---

## Priority 2 — Medium Impact / Technical Debt

### DEAD-1: `interactive_work_hours.dart` — entire file is dead code
**File:** [lib/widgets/interactive_work_hours.dart](lib/widgets/interactive_work_hours.dart)  
**Category:** Dead Code  
**Effort:** XS (10 min)  
`InteractiveWorkHoursClock` is never imported or instantiated anywhere. `ClockPainter.paint()` is an empty stub with a comment saying "copy paint method from WorkHoursClock". The app uses `WorkHoursClock` exclusively.  
**Action:** Delete the file.

---

### DUP-2: Double-to-time formatting duplicated 8+ times
**Files:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart), [lib/widgets/work_hours_clock.dart](lib/widgets/work_hours_clock.dart)  
**Category:** Duplicate Code  
**Effort:** S (1–2 hours)  
The expression `'$hour:${minute.toString().padLeft(2, '0')}'` and the preceding decomposition `hour = time.floor(); minute = ((time - hour) * 60).round()` appear 8+ times across two files.  
**Action:** Add `static String formatTime(double time)` to `UserPreferences` or a new `lib/core/utils/time_utils.dart`, replace all call sites.

---

### DUP-3: `_updateStartTime` / `_updateEndTime` — identical bodies
**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart)  
**Category:** Duplicate Code  
**Effort:** S (30 min)  
Both methods decompose a double, call `copyWith`, save preferences, and conditionally reschedule — identical except for which field is updated.  
**Action:** Extract `_updateTime(double time, {required bool isStart})` and branch only on the `copyWith` argument.  
**Note:** Implement together with ERR-2 (missing `mounted` check in the same methods).

---

### DUP-4: SharedPreferences key strings repeated 2–3 times each
**File:** [lib/services/storage_service.dart](lib/services/storage_service.dart)  
**Category:** Duplicate Code  
**Effort:** XS (20 min)  
`'is_enabled'`, `'start_hour'`, `'start_minute'`, `'end_hour'`, `'end_minute'`, `'exclude_weekends'` each appear in `loadPreferences`, `savePreferences`, and sync getters with no central constant.  
**Action:** Define `static const _keyIsEnabled = 'is_enabled'` etc. at the top of `StorageService`.

---

### DUP-5: `StorageService` sync getter boilerplate repeated 4 times
**File:** [lib/services/storage_service.dart](lib/services/storage_service.dart)  
**Category:** Duplicate Code  
**Effort:** S (30 min)  
Each sync getter (`isEnabled`, `startHour`, `endHour`, `excludeWeekends`) has the same 4-line `_initialized` guard + try/fallback structure.  
**Action:** Extract `static T _safeGet<T>(T Function() getter, T fallback)` private helper.

---

### SEC-2: `USE_EXACT_ALARM` permission — Play Store violation
**File:** [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)  
**Category:** Security / Compliance  
**Effort:** XS (15 min)  
`USE_EXACT_ALARM` is a restricted permission reserved for calendar/alarm-clock apps. Google Play will reject/flag a movement reminder app using it. Both `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` are declared simultaneously.  
**Action:** Remove `USE_EXACT_ALARM`; rely on `SCHEDULE_EXACT_ALARM` with a runtime check prompting the user to grant exact alarm access in system settings.

---

### ERR-2: Missing `mounted` check between sequential `await`s in `_updateStartTime` / `_updateEndTime`
**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart) ~L103, ~L117  
**Category:** Error Handling  
**Effort:** XS (10 min)  
No `mounted` check between `await StorageService.savePreferences(...)` and `await AlarmService.scheduleHourlyAlarm()`. Widget unmounting between the two calls will trigger unnecessary alarm scheduling.  
**Action:** Add `if (!mounted) return;` after `await StorageService.savePreferences(_prefs)` in both methods.

---

### ERR-3: iOS permission result silently discarded in `requestPermissions`
**File:** [lib/services/notification_service.dart](lib/services/notification_service.dart) ~L56  
**Category:** Error Handling  
**Effort:** XS (15 min)  
The `bool?` returned by `ios?.requestPermissions(...)` is discarded. Method always returns `true` on iOS even when the user denies all permissions.  
**Action:** Capture iOS result and combine with Android result: `return (iosGranted ?? true) && (androidGranted ?? true)`.

---

### DEAD-2: `permission_handler` dependency — never used in `lib/`
**File:** [pubspec.yaml](pubspec.yaml)  
**Category:** Dead Code  
**Effort:** XS (10 min)  
`permission_handler: ^11.3.1` is listed but no file in `lib/` imports it. Notifications permissions are handled via `flutter_local_notifications` platform implementations directly.  
**Action:** Remove from `pubspec.yaml` and run `flutter pub get`.

---

### DEAD-3: `startMinute` / `endMinute` unused in alarm boundary logic
**File:** [lib/services/alarm_service.dart](lib/services/alarm_service.dart) + [lib/services/storage_service.dart](lib/services/storage_service.dart)  
**Category:** Dead Code  
**Effort:** M (2–3 hours)  
The alarm callback checks `hour < startHour || hour > endHour` but never uses `startMinute`/`endMinute` stored in preferences. Minute-granularity is entirely dead in the alarm path; alarms fire at exact hour boundaries so sub-hour precision has no effect on scheduling.  
**Action:** Remove `startMinute`/`endMinute` from `UserPreferences`, `StorageService`, and the UI sliders — simplify to hour-only granularity.

---

### ERR-4: `_toggleWeekends` does not reschedule alarm
**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart) ~L120  
**Category:** Logic Bug  
**Effort:** XS (15 min)  
Weekend-exclusion changes take effect only after the next alarm fires, not immediately. Inconsistent with `_updateStartTime`/`_updateEndTime` which always reschedule.  
**Action:** Add `if (_prefs.isEnabled) await AlarmService.scheduleHourlyAlarm();` (with mounted check) inside `_toggleWeekends`.

---

## Priority 3 — Low Priority / Polish

### SEC-3: `RebootBroadcastReceiver` exported without permission restriction
**File:** [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)  
**Category:** Security  
**Effort:** XS (10 min)  
`android:exported="true"` with no `android:permission`; any app on device can send an arbitrary intent to it.  
**Action:** Add `android:permission="android.permission.RECEIVE_BOOT_COMPLETED"` to the receiver declaration.

---

### DUP-6: `Platform.isAndroid` guard repeated in all `AlarmService` methods
**File:** [lib/services/alarm_service.dart](lib/services/alarm_service.dart)  
**Category:** Duplicate Code  
**Effort:** XS (20 min)  
The `if (!Platform.isAndroid) { ...; return; }` pattern appears in every public method.  
**Action:** Extract a private `static bool get _isAndroid => Platform.isAndroid` or a `static void _requireAndroid()` that throws, to unify the guard.

---

### DUP-7: Notification channel ID and name literals duplicated
**File:** [lib/services/notification_service.dart](lib/services/notification_service.dart)  
**Category:** Duplicate Code  
**Effort:** XS (10 min)  
`'hourly_reminder_channel'` and `'Hourly Reminders'` appear in both `initialize()` and `showHourlyNotification()`.  
**Action:** Define `static const _channelId = 'hourly_reminder_channel'` and `static const _channelName = 'Hourly Reminders'`.

---

### DUP-8: Duplicated `AppBar` definition in error and main scaffolds
**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart)  
**Category:** Duplicate Code  
**Effort:** XS (10 min)  
The same `AppBar(title, backgroundColor, foregroundColor, elevation)` is copy-pasted into both the error-state scaffold and the main scaffold.  
**Action:** Extract `Widget _buildAppBar()` helper method.

---

### ERR-5: `StorageService` sync getters use bare `catch (_)` with no diagnostic output
**File:** [lib/services/storage_service.dart](lib/services/storage_service.dart) ~L72  
**Category:** Error Handling  
**Effort:** XS (15 min)  
Errors from `SharedPreferences` in sync getters are entirely silenced — no `debugPrint`, no logging.  
**Action:** Add `debugPrint('StorageService: error reading key: $e')` inside each `catch (_)` to aid debugging in alarm isolate context.

---

### SEC-4: `debugPrint` in alarm callback emits stack traces to logcat in release
**File:** [lib/services/alarm_service.dart](lib/services/alarm_service.dart) ~L32  
**Category:** Security  
**Effort:** S (30 min)  
Stack traces with potential preference state are emitted to logcat even in release builds (readable on rooted devices).  
**Action:** Wrap `debugPrint` calls in `assert(() { debugPrint(...); return true; }())` to suppress in release mode.

---

### DEAD-4: `cupertino_icons` dependency — never used
**File:** [pubspec.yaml](pubspec.yaml)  
**Category:** Dead Code  
**Effort:** XS (5 min)  
`CupertinoIcons` never referenced anywhere in `lib/`.  
**Action:** Remove from `pubspec.yaml`.

---

### DEAD-5: `timezone` package — `initializeTimeZones()` called but no scheduled notifications use it
**File:** [lib/services/notification_service.dart](lib/services/notification_service.dart) + [pubspec.yaml](pubspec.yaml)  
**Category:** Dead Code  
**Effort:** XS (10 min)  
`tz.initializeTimeZones()` is called at init but only `_notifications.show()` (fire-now) is ever used — no `zonedSchedule`.  
**Action:** First verify `timezone` is not a transitive requirement of `flutter_local_notifications` by running `flutter pub deps`. If confirmed unused, remove `tz.initializeTimeZones()`, the `timezone` import, and the pubspec entry.

---

### SEC-5: Notification ID using `millisecondsSinceEpoch.remainder(100000)` causes collisions
**File:** [lib/services/notification_service.dart](lib/services/notification_service.dart) ~L95  
**Category:** Correctness  
**Effort:** XS (10 min)  
IDs cycle every ~100 seconds; concurrent reminders silently replace each other.  
**Action:** Use a fixed `const int _notificationId = 1` — only one active reminder notification is needed at any time.

---

## Summary Table

| ID | Category | Severity | Effort | Description |
|----|----------|----------|--------|-------------|
| SEC-1 | Security | HIGH | S | Release build uses debug keystore |
| ERR-1 | Error Handling | HIGH | S | `main.dart` rethrow → blank crash screen |
| DEAD-1 | Dead Code | HIGH | XS | Delete `interactive_work_hours.dart` entirely |
| DUP-2 | Duplicate | MEDIUM | S | Extract `formatTime()` helper |
| DUP-3 | Duplicate | MEDIUM | S | Merge `_updateStartTime`/`_updateEndTime` |
| DUP-4 | Duplicate | MEDIUM | XS | SharedPreferences key constants |
| DUP-5 | Duplicate | MEDIUM | S | `_safeGet<T>` helper in StorageService |
| SEC-2 | Security | MEDIUM | XS | Remove `USE_EXACT_ALARM` permission |
| ERR-2 | Error Handling | MEDIUM | XS | `mounted` check between awaits in update methods |
| ERR-3 | Error Handling | MEDIUM | XS | iOS permission result discarded |
| DEAD-2 | Dead Code | MEDIUM | XS | Remove `permission_handler` from pubspec |
| DEAD-3 | Dead Code | MEDIUM | M | Clarify `startMinute`/`endMinute` usage in alarm |
| ERR-4 | Logic Bug | LOW | XS | `_toggleWeekends` should reschedule alarm |
| SEC-3 | Security | LOW | XS | `RebootBroadcastReceiver` exported without permission |
| DUP-6 | Duplicate | LOW | XS | Extract Android guard in `AlarmService` |
| DUP-7 | Duplicate | LOW | XS | Notification channel ID/name constants |
| DUP-8 | Duplicate | LOW | XS | Extract `_buildAppBar()` |
| ERR-5 | Error Handling | LOW | XS | Add `debugPrint` to silenced storage getters |
| SEC-4 | Security | LOW | S | Suppress `debugPrint` in alarm callback for release |
| DEAD-4 | Dead Code | LOW | XS | Remove `cupertino_icons` from pubspec |
| DEAD-5 | Dead Code | LOW | XS | Remove unused `timezone` init / dependency |
| SEC-5 | Correctness | LOW | XS | Fix notification ID collision |

**Effort key:** XS < 30 min · S = 30 min–2 hrs · M = 2–4 hrs
