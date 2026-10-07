# Hourly Reminder

A movement reminder app for Android and iOS. Sends notifications during work hours to remind you to stand up and move.

## Features

- **Movement reminders** during configurable work hours with adjustable interval (15-120 min)
- **Circular progress ring** showing daily movement goal (Apple Fitness style)
- **"I already moved" action** on notifications with semi-adaptive rescheduling
- **Manual movement recording** with optimistic UI updates
- **Movement statistics** with weekly chart, streak tracking, and activity percentage
- **Exercise suggestions** in notifications (office-friendly, round-robin order)
- **Gender-aware text** (neutral, male, or female notification wording)
- **Per-day work schedule** (toggle each day independently)
- **Snooze** notification action (reschedules in 10 min)
- **Light / dark theme** following system, with warm cosy light theme
- **3 languages**: Russian, English, Belarusian
- **Persistent settings** surviving app restarts and device reboots

## Screenshots

> _Add screenshots here_

## Requirements

| Tool | Version |
|---|---|
| Flutter | 3.41+ |
| Dart | 3.11+ |
| Android SDK | API 21+ |
| iOS | 13+ |

## Getting Started

```bash
flutter pub get
flutter run

# Build release
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

## Running Tests

```bash
flutter test                        # All tests (97)
TZ=Europe/Berlin flutter test       # Same, in a time zone with DST
flutter analyze                     # Static analysis
```

## Architecture

### Dart side

```
lib/
├── main.dart
├── models/
│   └── user_preferences.dart     # Immutable settings model
├── services/
│   ├── alarm_service.dart         # Alarm scheduling + next notification times
│   ├── ios_reminder_scheduler.dart # iOS rolling window of pre-scheduled reminders
│   ├── notification_l10n.dart     # Localized notification text
│   ├── notification_service.dart  # flutter_local_notifications wrapper + action handling
│   └── storage_service.dart       # SharedPreferences wrapper
├── screens/
│   ├── main_shell.dart            # Bottom nav (Home, Stats, Settings)
│   ├── home_screen.dart           # Goal ring, quick stats, work hours
│   ├── settings_screen.dart       # All user preferences
│   └── widgets/
│       ├── goal_ring_painter.dart # Circular progress ring
│       └── work_hours_card.dart   # Time display with picker
├── features/
│   ├── movement/                  # Movement event tracking (domain/data)
│   └── movement_stats/            # Statistics screen (weekly/streak/goal)
├── l10n/                          # Localization (ru, en, be)
└── core/
    ├── theme/app_colors.dart      # Design tokens (light & dark)
    ├── theme/app_typography.dart   # Text styles
    └── utils/time_utils.dart      # Time formatting
```

### Native Android (Kotlin)

```
android/.../com/bazhanau/hourly_reminder/
├── MainActivity.kt           # MethodChannel handlers
├── NotificationHelper.kt     # Builds notifications with actions
├── ReminderScheduler.kt      # Exact alarm scheduling
├── ReminderReceiver.kt       # Alarm callback, work hours check
├── SnoozeReceiver.kt         # Snooze action (10 min)
├── AlreadyMovedReceiver.kt   # "I already moved" + event persistence
├── BootReceiver.kt           # Re-registers alarms after reboot
├── PrefsExt.kt               # SharedPreferences extensions
├── Exercise.kt               # Exercise data class
└── ExerciseRepository.kt     # Exercise list, round-robin
```

### Dual notification pipeline

- **Android**: Entirely native Kotlin. Alarms fire BroadcastReceivers that build and show notifications. No FlutterEngine running. Action buttons handled by native receivers.
- **iOS**: Uses `flutter_local_notifications` from Dart side. iOS runs no app code when a notification fires, so reminders are pre-scheduled as a rolling window of up to 60 one-shot notifications (iOS keeps at most 64). The queue is refilled on app start, on resume and on every notification action. If the app is never opened, the queue runs out (about 1.7 work days at a 15-min interval, about 9 calendar days at 60 min). A "Reminders paused" notification at the next slot then asks the user to open the app. Actions (`DarwinNotificationCategory`) run in a background Flutter engine.

Both read/write SharedPreferences (native key prefix: `flutter.`).

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_local_notifications` | 21.0 | Notifications (iOS), notification permission requests |
| `shared_preferences` | 2.3 | Persistent storage |
| `timezone` | 0.11 | Timezone utilities |
| `fl_chart` | 1.2 | Weekly stats chart |
| `url_launcher` | 6.3 | External links |

## Android Permissions

| Permission | Purpose |
|---|---|
| `POST_NOTIFICATIONS` | Show notifications (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Exact alarm scheduling |
| `RECEIVE_BOOT_COMPLETED` | Re-schedule alarms after reboot |
| `WAKE_LOCK` | Keep CPU awake during alarm callback |
| `VIBRATE` | Notification vibration |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Reliable delivery |

## License

MIT
