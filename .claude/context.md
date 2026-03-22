# Project Context

## Current State (2026-03-20)

Main branch has PR #10 (UI redesign) merged. PR #11 (new features bundle) is open.

Flutter 3.41.5 (Dart 3.11.3), upgraded from 3.38.8 on 2026-03-19.

## Recent Changes

### UI Redesign (PR #10, merged)
- Replaced glassmorphism with clean card-based design (teal/coral/amber palette)
- Bottom navigation bar (Home + Stats tabs) via `MainShell` widget
- `AppTypography` system for consistent text styles
- Cards: flat (elevation 0) with borders, 20px radius
- Light: warm off-white `#F5F3EE`. Dark: charcoal `#15181E`

### New Features Bundle (PR #11, open)
- **Next reminder indicator**: "Следующее в 15:00" on home screen, uses `AlarmService.nextNotificationTime()`
- **Manual "I moved" button**: records `MovementSource.manual` event, resets sedentary timer
- **Daily movement goal**: configurable (1-15, default 8), progress bar on home, "5/8" in stats
- **Notification tap -> stats**: tapping notification body opens stats tab (Android intent extras + iOS ValueNotifier)
- **First notification delay**: 45 min after work start (both Dart and Android native)

## Architecture Notes

### Two coexisting patterns

The codebase is in a gradual migration from flat services to feature-first Clean Architecture:
- Old: `lib/services/`, `lib/models/`, `lib/screens/` - static singletons, no injection
- New: `lib/features/<name>/` with domain/data/presentation layers and constructor injection

New features should follow the feature-first pattern. Domain layer must stay pure Dart (no Flutter imports).

### Navigation structure

`MainShell` (lib/screens/main_shell.dart) owns the Scaffold and bottom NavigationBar. Child screens (HomeScreen, StatsScreen) return body-only widgets (no AppBar/Scaffold of their own).

Navigation channel `com.bazhanau.hourly_reminder/navigation` handles notification tap routing:
- Android cold start: `getAndClearInitialTab` method
- Android warm start: `navigateToTab` pushed from `onNewIntent`
- iOS: `NotificationService.tabNotifier` ValueNotifier

### Feature modules

- `lib/features/movement/` - movement event tracking (confirm movement, save events, interval calculation). Supports both `MovementSource.notification` and `MovementSource.manual`.
- `lib/features/movement_stats/` - statistics screen (reads movement_events, computes daily/weekly/streak stats, includes dailyGoal)

### SharedPreferences keys

Flutter stores keys with `flutter.` prefix natively. Android native code must use `flutter.<key>` to read values written by Dart. Mismatch causes silent fallback to defaults - this was the root cause of the `getLong` vs `getInt` bug.

Key categories:
- User prefs: `is_enabled`, `start_hour`, `start_minute`, `end_hour`, `end_minute`, `work_on_saturday`, `work_on_sunday`, `notification_gender`, `daily_goal`
- Movement: `movement_events` (JSON StringList), `movement_sedentary_start_millis`, `movement_last_notification_sent_millis`
- Exercise: `exercise_index`, `notifications_shown_count`, `last_notification_date`
- Dedup: `last_notified_millis`

### Exercise system

`ExerciseRepository.kt` (Android only) tracks exercise index and daily notification count. Both must reset together on new day detection.

### Custom reminder interval

Reminder interval is user-configurable (15-120 min, default 60). Stored in `flutter.reminder_interval_minutes`. Reminders are **not clock-aligned** - they fire at `now + interval`, so they drift over time (e.g. 10:01 -> 11:01 -> 12:01). Adaptive intervals after "I already moved" scale proportionally: fast reaction = base * 0.5, slow = base * 0.75, minimum 10 min.

### First notification delay

The first notification of the day fires at `workStart + interval` (not immediately). For the default 60-min interval, that means 10:00 if work starts at 9:00. Implemented in both:
- Dart: `AlarmService.nextNotificationTime()` uses `startMin + intervalMinutes`
- Android: `ReminderReceiver` skips notifications within the first interval and schedules a settling alarm
- Android: `ReminderScheduler.nextValidAlarmTime()` jumps to `startMin + interval` on the next work day

## Dependencies (pubspec.yaml)

```
flutter_local_notifications: ^18.0.1  (latest: 21.0.0)
android_alarm_manager_plus: ^4.0.3    (latest: 5.0.0)
shared_preferences: ^2.3.4
permission_handler: ^11.3.1           (latest: 12.0.1)
timezone: ^0.9.4                      (latest: 0.11.0)
fl_chart: ^0.70.2
```

Several deps are behind. Not blocking but worth a maintenance pass.

## Tests

13 test files, 181 tests. Coverage is good across services, domain logic, utilities, and models. Widget/integration coverage is minimal.

Test files map to:
- `test/services/` - alarm and storage services
- `test/models/` - user preferences
- `test/features/movement/` - domain + data layer tests
- `test/features/movement_stats/` - use case + repository tests
- `test/core/` - theme, time utils (formatDuration, formatNextReminder)
- `test/widgets/` - work hours clock

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
- 000011: Next reminder, manual movement, daily goal (PR #11)

Partial: 000002 (refactoring opportunities), 000003 (test refactoring)

## Known Tech Debt

- `StorageService` and `AlarmService` use constructor injection. `NotificationService` remains static (platform-bridging glue code). Full migration deemed not worth it.
- No Riverpod/Bloc - StatefulWidget + SharedPreferences for all state. Fine for current app size.
- iOS support exists but is less tested than Android. Exercise notifications are Android-only.
- Movement events stored as JSON StringList in SharedPreferences. Fine for current scale (~2,500 events/year). Consider SQLite if data grows.
- Several dependencies behind latest versions.

## MethodChannels

- `com.bazhanau.hourly_reminder/alarm` - Schedule/cancel alarms
- `com.bazhanau.hourly_reminder/notification` - Show notification from Flutter
- `com.bazhanau.hourly_reminder/battery` - Battery optimization checks
- `com.bazhanau.hourly_reminder/navigation` - Notification tap routing (stats tab)
