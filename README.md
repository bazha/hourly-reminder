# Hourly Reminder — Напоминалка

An Android app that sends hourly notifications during your configured work hours to remind you to stand up and move.

---

## Features

- **Hourly notifications** during a configurable work window
- **Interactive 24-hour clock** — drag handles to set start and end times (15-minute precision)
- **Work hour sliders** — alternative fine-grained time adjustment
- **Saturday / Sunday toggles** — include or exclude each weekend day independently
- **Notification deduplication** — prevents spam when the device wakes from Doze mode
- **Test notification button** — verify notifications work immediately
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
│   └── home_screen.dart          # Main UI
├── widgets/
│   └── work_hours_clock.dart     # Custom 24h analog clock (CustomPaint)
└── core/
    ├── theme/app_colors.dart     # Design tokens — light & dark palettes
    └── utils/time_utils.dart     # Time formatting helpers
```

**Key design decisions:**

- `AlarmService.shouldSendReminder()` and `nextNotificationTime()` are pure static functions with no side effects — easy to unit-test without mocks.
- `alarmCallback()` runs in a fresh background isolate (Android Doze). It re-initialises `StorageService` and deduplicates by checking the last-notified calendar hour before firing.
- `UserPreferences` is an immutable value object (`==` + `hashCode` via `Object.hash`).
- `AppColors.of(context)` resolves the correct light/dark palette at runtime.

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
