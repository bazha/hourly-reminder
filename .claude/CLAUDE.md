# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Documentation

Read these files in `.claude/` before starting work:

- `.claude/workflow.md` - Development workflow and change process
- `.claude/context.md` - Additional project context
- `.claude/credentials.md` - Additional service credentials info
- `.claude/rules/*.md` - All the files from the rules folder
- `.claude/skills/flutter-senior/SKILL.md` - Skills for flutter and dart tasks

## Key Rules

1. **Never implement without confirmation** - Create change plan first at `docs/01_change_plans/######-<title>.md`
2. **Don't modify `.claude/` files** without explicit request (except `context.md`), but feel free to modify `.claude/context.md` file anytime you want.

## Build & Test Commands

```bash
flutter pub get                          # Install dependencies
flutter test                             # Run all tests
flutter test test/path/to/file_test.dart # Run a single test file
flutter test --name "test name"          # Run tests matching name
flutter build apk --debug               # Build Android debug APK
flutter build apk --release             # Build Android release APK
flutter build ios --release              # Build iOS release
flutter analyze                          # Run static analysis
```

## Architecture

Flutter app (Dart 3.5+, no backend) that sends hourly movement reminders during configured work hours. UI is in Russian.

### Dual notification pipeline

This is the most important architectural detail. Notifications work differently per platform:

- **Android**: Entirely native Kotlin. `ReminderScheduler` sets exact alarms -> `ReminderReceiver` fires -> `NotificationHelper` builds and shows the notification. Action buttons (snooze, "I already moved") are handled by native `BroadcastReceiver` classes (`SnoozeReceiver`, `AlreadyMovedReceiver`). No FlutterEngine is running when these fire.
- **iOS**: Uses `flutter_local_notifications` plugin from Dart side. Actions are configured via `DarwinNotificationCategory`.

Both sides read/write SharedPreferences (native key prefix: `flutter.`). Changes to notification behavior must be made in both pipelines.

### Project structure

Two coexisting patterns:

- **Flat services** (`lib/services/`, `lib/models/`, `lib/screens/`) - Original code. Static singleton services (`StorageService`, `NotificationService`, `AlarmService`) with pure functions for testable logic.
- **Feature-first layers** (`lib/features/<feature>/`) - Newer code. Domain/data/presentation layers with constructor injection. Domain layer is pure Dart (no Flutter imports).

### Key native files (Android)

All under `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/`:

- `MainActivity.kt` - MethodChannel handlers bridging Flutter to native
- `NotificationHelper.kt` - Builds and shows notifications with action buttons
- `ReminderScheduler.kt` - Schedules one-shot exact alarms for next hour
- `ReminderReceiver.kt` - Alarm callback; checks work hours from SharedPreferences
- `SnoozeReceiver.kt` - Snooze action: reschedules in 10 min
- `AlreadyMovedReceiver.kt` - "I already moved" action: semi-adaptive rescheduling
- `BootReceiver.kt` - Re-registers alarms after device reboot

### State management

No frameworks (no Riverpod, no Bloc). `StatefulWidget` + `StorageService` (SharedPreferences wrapper). All state persists through `SharedPreferences`.

### MethodChannels

- `com.bazhanau.hourly_reminder/alarm` - Schedule/cancel alarms
- `com.bazhanau.hourly_reminder/notification` - Show notification from Flutter
- `com.bazhanau.hourly_reminder/battery` - Battery optimization checks
