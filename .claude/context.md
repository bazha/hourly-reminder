# Project Context

## Current State (2026-03-24)

Main branch up to date through PR #25. PR #26 (home screen redesign) is open.

Flutter 3.41.5 (Dart 3.11.3).

## Recent Changes

### Home Screen Redesign (PR #26, open)
- Circular progress ring (Apple Fitness style) replaces linear progress bar
- Filled amber action button, quick stats row (streak + activity %), settings rows with icons
- Motivational card with full-width image background
- Warm cream light theme (`#F5F0E8`, Scandinavian cosy feel)
- `WidgetsBindingObserver` for lifecycle-aware refresh
- `SharedPreferences.reload()` fix for native event visibility
- WorkHoursClock widget removed, replaced with card-based time display

### Settings Screen (PR #24, merged)
- Dedicated Settings screen as 3rd tab in bottom nav
- Work days, daily goal, reminder interval, notification gender, theme mode, language
- Work days range formatting (Mon-Fri instead of listing all days)

### Already Moved Fix (PR #25, merged)
- Android `AlreadyMovedReceiver` now persists `MovementEvent` to SharedPreferences
- `appendToFlutterStringList` extension in `PrefsExt.kt`

### Earlier PRs (merged)
- PR #23: Dead code cleanup, hardcoded string fixes, deduplication
- PR #12: Test cleanup (181 -> 86 tests consolidated)
- PR #11: Next reminder indicator, manual movement, daily goal, notification tap navigation
- PR #10: UI redesign with card-based design, bottom nav, AppTypography

## Architecture Notes

### Two coexisting patterns

The codebase is in gradual migration from flat services to feature-first Clean Architecture:
- Old: `lib/services/`, `lib/models/`, `lib/screens/` - static singletons, no injection
- New: `lib/features/<name>/` with domain/data/presentation layers and constructor injection

New features should follow the feature-first pattern. Domain layer must stay pure Dart (no Flutter imports).

### Navigation structure

`MainShell` (lib/screens/main_shell.dart) owns the Scaffold and bottom NavigationBar. Child screens (HomeScreen, StatsScreen, SettingsScreen) return body-only widgets (no AppBar/Scaffold of their own).

Navigation channel `com.bazhanau.hourly_reminder/navigation` handles notification tap routing:
- Android cold start: `getAndClearInitialTab` method
- Android warm start: `navigateToTab` pushed from `onNewIntent`
- iOS: `NotificationService.tabNotifier` ValueNotifier

### Feature modules

- `lib/features/movement/` - movement event tracking (confirm movement, save events, interval calculation). Supports both `MovementSource.notification` and `MovementSource.manual`.
- `lib/features/movement_stats/` - statistics screen (reads movement_events, computes daily/weekly/streak stats, includes dailyGoal)

### SharedPreferences keys

Flutter stores keys with `flutter.` prefix natively. Android native code must use `flutter.<key>` to read values written by Dart. `MovementLocalDatasource.getEvents()` calls `_prefs.reload()` before reading to pick up native writes.

Key categories:
- User prefs: `is_enabled`, `start_hour`, `start_minute`, `end_hour`, `end_minute`, `work_on_saturday`, `work_on_sunday`, `notification_gender`, `daily_goal`
- Movement: `movement_events` (JSON StringList), `movement_sedentary_start_millis`, `movement_last_notification_sent_millis`
- Exercise: `exercise_index`, `notifications_shown_count`, `last_notification_date`
- Dedup: `last_notified_millis`

### Custom reminder interval

Reminder interval is user-configurable (15-120 min, default 60). Stored in `flutter.reminder_interval_minutes`. Reminders are **not clock-aligned** - they fire at `now + interval`. Adaptive intervals after "I already moved" scale proportionally: fast reaction = base * 0.5, slow = base * 0.75, minimum 10 min.

### iOS reminder scheduling (plan 000022, 2026-10-06)

iOS runs no app code when a notification fires. Reminders are pre-scheduled by `IosReminderScheduler` as up to 60 one-shot `zonedSchedule` notifications (ids 100-159, payload = scheduled time in millis). iOS keeps only the 64 most recent, so never exceed 60.

- `AlarmService.scheduleHourlyAlarm({firstDelay})` = reset from now (hours/interval change, toggle on, manual move, "already moved" with adaptive `firstDelay`, day off).
- `AlarmService.refillReminders()` = extend from the earliest pending reminder (`anchor`) without shifting (app start, resume, locale change, work day toggled). The anchor is dropped if an earlier day became available. No-op on Android.
- Both read prefs from storage (after `reload()`), so save prefs **before** calling them.
- `IosReminderScheduler.schedule()` overwrites ids in place and cancels only leftovers (never leaves the queue empty), and skips the rebuild when pending ids, times, title and body already match.
- Times come from pure `AlarmService.upcomingNotificationTimes()`, which loops over `nextNotificationTime()` and skips `day_off_date`.
- `tz.local` is never set (UTC). Times are converted with `tz.TZDateTime.from(dt, tz.UTC)`; the plugin keeps the instant.
- Action buttons are `.plain`, so the plugin always runs them in a background engine via top-level `onBackgroundNotificationResponse` (needs `setPluginRegistrantCallback` in `AppDelegate`). Reaction time comes from the payload.
- Turning on a day off reschedules instead of cancelling, on both platforms.
- Manual iOS device testing for 000022 was still pending at the time of writing.
- Plan 000024: `_scheduleIos` asks for 61 times. The 61st becomes a "reminders paused" notice (id 3, no actions), rebuilt independently from the reminders. If it already fired, it is cancelled first (plugin `cancel` also removes delivered notifications), so no stale notice stays in Notification Center. `cancel()` removes reminders and the notice, keeps the snooze. `cancelSnooze()` (id 2) runs on disable and on a day off. `_snoozeForIos` skips scheduling when `StorageService.remindersActiveToday` is false (iOS has no fire-time check).
- iOS ids: 1 test, 2 snooze, 3 paused notice, 100-159 reminders (63 of 64).

### Android exact alarms (plan 000023)

All native alarms go through `AlarmManager.scheduleExact()` in `PrefsExt.kt`. It checks `canScheduleExactAlarms()` (Android 12+) and catches `SecurityException`, falling back to `setAndAllowWhileIdle()`. Use this helper for any new alarm, never call `setExact*` directly.

### Android cancel and fire-time checks (plan 000024)

- `ReminderScheduler.cancel()` cancels the hourly (100), settling (150) and snooze (200) alarms. PendingIntents come from shared builders (`ReminderScheduler.hourlyPendingIntent/settlingPendingIntent`, `SnoozeReceiver.snoozePendingIntent`); build any new one there, or `AlarmManager.cancel` won't match.
- `ReminderReceiver` checks `is_enabled` **before** rescheduling, so a stray alarm ends the chain instead of reviving it.
- `SnoozeReceiver` shows the snoozed notification only if reminders are on and today is not the day off. Work hours are deliberately not checked.
- Day off is read with `SharedPreferences.isDayOffToday()` (`LocalDate`, ASCII in any locale).

### Date arithmetic rule (plan 000024)

Never step days or build wall-clock times with `Duration` (`midnight.add(Duration(minutes: n))`, `subtract(Duration(days: 1))`): on DST switch days it lands an hour off or on 23:00/01:00. Use the `DateTime` constructor (`DateTime(y, m, d - 1)`, `DateTime(y, m, d, 0, minutes)`) and UTC dates for day differences. Minsk has no DST, so run `TZ=Europe/Berlin flutter test` to catch these.

### First notification delay

The first notification of the day fires at `workStart + interval` (not immediately). For the default 60-min interval, that means 10:00 if work starts at 9:00. Implemented in both:
- Dart: `AlarmService.nextNotificationTime()` uses `startMin + intervalMinutes`
- Android: `ReminderReceiver` skips notifications within the first interval and schedules a settling alarm
- Android: `ReminderScheduler.nextValidAlarmTime()` jumps to `startMin + interval` on the next work day

## Dependencies (pubspec.yaml)

```
flutter_local_notifications: ^21.0.0
shared_preferences: ^2.3.4
timezone: ^0.11.0
fl_chart: ^1.2.0
url_launcher: ^6.3.2
```

All direct dependencies at latest compatible versions as of 2026-03-24. `cupertino_icons` and `permission_handler` removed as unused (plan 000021, 2026-10-06). Android alarms are native `AlarmManager` (no alarm plugin).

## Tests

15 test files, 97 tests (as of 2026-10-07, after plan 000024 and removing 11 redundant tests). Coverage is good across services, domain logic, utilities, and models. Widget coverage: `test/screens/home_screen_test.dart` pumps the whole app (it replaced the smoke test) and checks the home banner and the work-hours warning. The DST group in the stats test also covers the basic streak and weekly cases. DST tests only fail under a DST time zone: run `TZ=Europe/Berlin flutter test` too. No Kotlin unit tests (no Android test setup).

Test files map to:
- `test/services/` - alarm and storage services
- `test/models/` - user preferences
- `test/features/movement/` - domain + data layer tests
- `test/features/movement_stats/` - use case + repository tests
- `test/core/` - theme, time utils (formatDuration, formatNextReminder)

## Change Plans

Completed plans in `docs/01_change_plans/`:
- 000001: Daily notification count tracking
- 000004: "I already moved" action
- 000005: System theme adaptation
- 000006: Exercise notifications
- 000007: HomeScreen widget extraction
- 000008: Static singleton to instance injection
- 000009: Fix ignored notification no follow-up
- 000010: Movement statistics screen
- 000011: Next reminder, manual movement, daily goal
- 000015: Home screen redesign (PR #26)
- 000021: Dead AppColors fields, unused deps, locale/theme key constants, unused l10n key
- 000022: iOS recurring reminders (rolling window, background actions, day-off fix)
- 000023: Android exact alarm fallback (`scheduleExact` uses an inexact alarm when exact access is missing)
- 000024: Reminder reliability (cancel/snooze checks on both platforms, DST-safe date arithmetic, reload before saving events, iOS "reminders paused" notice, work-hours warning)

Partial: 000002 (refactoring opportunities), 000003 (test refactoring)

## Known Tech Debt

- `StorageService` and `AlarmService` use constructor injection. `NotificationService` remains static (platform-bridging glue code). Full migration deemed not worth it.
- No Riverpod/Bloc - StatefulWidget + SharedPreferences for all state. Fine for current app size.
- iOS support exists but is less tested than Android. Exercise notifications and swipe-dismiss sedentary reset are Android-only. iOS reminder queue runs out if the app is never opened (no Background App Refresh); since 000024 the user gets a "reminders paused" notice. Movement events are a read-modify-write list shared by Dart and Kotlin: `saveEvent` reloads first, but the race is only narrowed, not closed.
- Movement events stored as JSON StringList in SharedPreferences. Fine for current scale (~2,500 events/year). Consider SQLite if data grows.

## MethodChannels

- `com.bazhanau.hourly_reminder/alarm` - Schedule/cancel alarms
- `com.bazhanau.hourly_reminder/notification` - Show notification from Flutter
- `com.bazhanau.hourly_reminder/battery` - Battery optimization checks
- `com.bazhanau.hourly_reminder/navigation` - Notification tap routing (stats tab)
