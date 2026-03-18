# Hourly Reminder — Напоминалка

An Android app that sends hourly notifications during your configured work hours to remind you to stand up and move.

---

## Features

- **Hourly notifications** during a configurable work window
- **Sedentary duration** in notification title (e.g. "Без движения 60 мин.")
- **Exercise suggestions** — office-friendly exercises shown in round-robin order starting from the second notification of the day
- **Gender-aware text** — neutral, male, or female notification wording
- **Interactive 24-hour clock** — drag handles to set start and end times (15-minute precision)
- **Work hour sliders** — alternative fine-grained time adjustment
- **Saturday / Sunday toggles** — include or exclude each weekend day independently
- **Snooze and "I already moved"** — notification action buttons with semi-adaptive rescheduling
- **Notification deduplication** — prevents spam when the device wakes from Doze mode
- **Test notification button** — verify notifications work immediately
- **Light / dark theme** — follows system theme automatically
- **Persistent settings** — all preferences survive app restarts and device reboots

---

## Screenshots

> _Add screenshots here_

---

## Requirements

| Tool | Version |
|---|---|
| Flutter | ≥ 3.5.0 |
| Dart | ≥ 3.5.0 |
| Android SDK | API 21+ |

> iOS is not currently supported (alarm scheduling is Android-only).

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on a connected Android device or emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## Running Tests

```bash
# All tests
flutter test

# Single test file
flutter test test/services/alarm_service_test.dart

# Static analysis
flutter analyze
```

---

## Architecture

### Dart side

```
lib/
├── main.dart                     # Entry point — service initialisation
├── models/
│   └── user_preferences.dart    # Immutable settings model (copyWith, equality)
├── services/
│   ├── alarm_service.dart        # AndroidAlarmManager scheduling + callback
│   ├── notification_service.dart # flutter_local_notifications wrapper
│   └── storage_service.dart      # SharedPreferences wrapper (async + sync)
├── screens/
│   └── home_screen.dart          # Main UI (clock, settings, gender selector)
├── widgets/
│   └── work_hours_clock.dart     # Custom 24h analog clock (CustomPaint)
├── features/
│   └── movement/                 # Feature-first module (domain/data layers)
└── core/
    ├── theme/app_colors.dart     # Design tokens — light & dark palettes
    └── utils/time_utils.dart     # Time formatting helpers
```

### Native Android (Kotlin)

```
android/app/src/main/kotlin/com/bazhanau/hourly_reminder/
├── MainActivity.kt          # MethodChannel handlers bridging Flutter to native
├── NotificationHelper.kt    # Builds notifications (sedentary duration, exercises)
├── ReminderScheduler.kt     # Schedules one-shot exact alarms for next hour
├── ReminderReceiver.kt      # Alarm callback — checks work hours, shows notification
├── SnoozeReceiver.kt        # Snooze action — reschedules in 10 min
├── AlreadyMovedReceiver.kt  # "I already moved" — semi-adaptive rescheduling
├── BootReceiver.kt          # Re-registers alarms after device reboot
├── Exercise.kt              # Exercise data class
└── ExerciseRepository.kt    # Exercise list, round-robin, notification counting
```

**Key design decisions:**

- Notifications are built entirely on the native Android side (no FlutterEngine running). `NotificationHelper` reads SharedPreferences directly for sedentary duration, gender, and exercise state.
- `AlarmService.shouldSendReminder()` and `nextNotificationTime()` are pure static functions with no side effects — easy to unit-test without mocks.
- `alarmCallback()` runs in a fresh background isolate (Android Doze). It re-initialises `StorageService` and deduplicates by checking the last-notified calendar hour before firing.
- `UserPreferences` is an immutable value object (`==` + `hashCode` via `Object.hash`).
- `AppColors.of(context)` resolves the correct light/dark palette at runtime.
- Exercises cycle in round-robin order. The first notification each day shows no exercise (sedentary tracking resets). Subsequent notifications include an exercise in the expanded view.

---

## Android Permissions

| Permission | Purpose |
|---|---|
| `POST_NOTIFICATIONS` | Show notifications (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Fire alarms at exact hour boundaries |
| `RECEIVE_BOOT_COMPLETED` | Re-schedule alarms after reboot |
| `WAKE_LOCK` | Keep CPU awake during alarm callback |
| `VIBRATE` | Vibration on notification |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Bypass battery saver for reliable delivery |

---

## Dependencies

| Package | Purpose |
|---|---|
| `android_alarm_manager_plus` | Periodic background alarms |
| `flutter_local_notifications` | Display notifications |
| `shared_preferences` | Persistent key-value storage |
| `permission_handler` | Runtime permission requests |
| `timezone` | Timezone utilities |

---

## License

MIT
