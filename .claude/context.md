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

### First notification delay

The first notification of the day fires at `workStart + interval` (not immediately). For the default 60-min interval, that means 10:00 if work starts at 9:00. Implemented in both:
- Dart: `AlarmService.nextNotificationTime()` uses `startMin + intervalMinutes`
- Android: `ReminderReceiver` skips notifications within the first interval and schedules a settling alarm
- Android: `ReminderScheduler.nextValidAlarmTime()` jumps to `startMin + interval` on the next work day

## Dependencies (pubspec.yaml)

```
flutter_local_notifications: ^21.0.0
android_alarm_manager_plus: ^4.0.8
shared_preferences: ^2.3.4
permission_handler: ^12.0.1
timezone: ^0.11.0
fl_chart: ^1.2.0
url_launcher: ^6.3.2
```

All direct dependencies at latest compatible versions as of 2026-03-24.

## Tests

12 test files, 81 tests. Coverage is good across services, domain logic, utilities, and models. Widget/integration coverage is minimal (smoke test only).

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

Partial: 000002 (refactoring opportunities), 000003 (test refactoring)

## Known Tech Debt

- `StorageService` and `AlarmService` use constructor injection. `NotificationService` remains static (platform-bridging glue code). Full migration deemed not worth it.
- No Riverpod/Bloc - StatefulWidget + SharedPreferences for all state. Fine for current app size.
- iOS support exists but is less tested than Android. Exercise notifications are Android-only.
- Movement events stored as JSON StringList in SharedPreferences. Fine for current scale (~2,500 events/year). Consider SQLite if data grows.

## MethodChannels

- `com.bazhanau.hourly_reminder/alarm` - Schedule/cancel alarms
- `com.bazhanau.hourly_reminder/notification` - Show notification from Flutter
- `com.bazhanau.hourly_reminder/battery` - Battery optimization checks
- `com.bazhanau.hourly_reminder/navigation` - Notification tap routing (stats tab)
