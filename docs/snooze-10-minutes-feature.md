# "In 10 Minutes" Snooze Button — Native Android Implementation

## Summary

Adds a **"Через 10 минут"** action button to every hourly notification. Tapping it dismisses the current notification and schedules a one-shot alarm to fire exactly 10 minutes later — even if the app is killed or the device is in Doze mode.

The entire snooze flow (dismiss → schedule → re-show) runs on the **native Android side** via `BroadcastReceiver` + `AlarmManager`. No Dart isolates are involved in handling the button tap, which eliminates the reliability issues with `flutter_local_notifications`' background callback mechanism.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Dart (Flutter)                                         │
│  ┌────────────────┐  ┌──────────────────────────────┐   │
│  │ AlarmService    │  │ NotificationService           │   │
│  │ schedule/cancel │  │ showHourlyNotification()      │   │
│  │ via MethodChan. │  │ → MethodChannel on Android    │   │
│  └───────┬────────┘  └──────────────┬───────────────┘   │
│          │                          │                    │
├──────────┼──────────────────────────┼────────────────────┤
│  Native Android (Kotlin)            │                    │
│          ▼                          ▼                    │
│  ┌────────────────┐  ┌──────────────────────────────┐   │
│  │ ReminderScheduler│ │ NotificationHelper            │   │
│  │ AlarmManager     │ │ NotificationCompat.Builder    │   │
│  │ setExact...()    │ │ + snooze PendingIntent        │   │
│  └───────┬────────┘  └──────────────┬───────────────┘   │
│          │                          │                    │
│          ▼                          │                    │
│  ┌────────────────┐                 │                    │
│  │ ReminderReceiver│ ◄──────────────┘                    │
│  │ checks prefs    │                                     │
│  │ shows notif.    │                                     │
│  └────────────────┘                                      │
│                                                          │
│  ┌────────────────┐  ┌──────────────────────────────┐   │
│  │ SnoozeReceiver  │  │ BootReceiver                  │   │
│  │ ACTION_SNOOZE:  │  │ re-schedules alarm on reboot  │   │
│  │   cancel notif  │  └──────────────────────────────┘   │
│  │   schedule 10m  │                                     │
│  │ ACTION_SHOW:    │                                     │
│  │   show notif    │                                     │
│  └────────────────┘                                      │
└─────────────────────────────────────────────────────────┘
```

---

## Files

| File | Role |
|---|---|
| `android/.../NotificationHelper.kt` | Builds and shows notification with native `NotificationCompat.Builder`; includes snooze `PendingIntent` pointing to `SnoozeReceiver` |
| `android/.../SnoozeReceiver.kt` | `BroadcastReceiver` handling `ACTION_SNOOZE` (cancel + schedule 10-min alarm) and `ACTION_SHOW_SNOOZED` (show notification again) |
| `android/.../ReminderReceiver.kt` | `BroadcastReceiver` for hourly alarm; reads conditions from `SharedPreferences`; shows notification if within work window |
| `android/.../ReminderScheduler.kt` | Schedules/cancels hourly one-shot alarms via native `AlarmManager.setExactAndAllowWhileIdle()` |
| `android/.../BootReceiver.kt` | Re-schedules hourly alarm after device reboot if reminders are enabled |
| `android/.../MainActivity.kt` | `MethodChannel` handlers for `scheduleHourlyAlarm`, `cancelAlarm`, and `showReminder` |
| `lib/services/alarm_service.dart` | Dart API — delegates to native via `MethodChannel`; keeps pure functions for unit tests |
| `lib/services/notification_service.dart` | On Android: calls native `showReminder` via `MethodChannel`; on iOS: uses `flutter_local_notifications` |

---

## How It Works

### Notification display (native)

`NotificationHelper.showReminder()` builds the notification using `NotificationCompat.Builder`:

```kotlin
NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.mipmap.ic_launcher)
    .setContentTitle("Время встать! ⏰")
    .setContentText("Пора размяться и походить 🚶")
    .setPriority(NotificationCompat.PRIORITY_HIGH)
    .addAction(0, "Через 10 минут", snoozePendingIntent)
    .build()
```

The snooze action's `PendingIntent` points directly to `SnoozeReceiver` with `ACTION_SNOOZE`. No Dart callback involved.

### Snooze button tap

When the user taps "Через 10 минут":

1. Android delivers the broadcast to `SnoozeReceiver.onReceive()`
2. The receiver cancels the notification via `NotificationHelper.cancel()`
3. The receiver schedules a one-shot alarm 10 minutes in the future:

```kotlin
alarmManager.setExactAndAllowWhileIdle(
    AlarmManager.ELAPSED_REALTIME_WAKEUP,
    SystemClock.elapsedRealtime() + 10 * 60 * 1000L,
    pendingIntent  // → SnoozeReceiver with ACTION_SHOW_SNOOZED
)
```

4. When the alarm fires, `SnoozeReceiver` receives `ACTION_SHOW_SNOOZED` and calls `NotificationHelper.showReminder()` — the notification reappears with the snooze button, allowing infinite snooze chains.

### Hourly alarm scheduling

`ReminderScheduler` uses one-shot exact alarms (`setExactAndAllowWhileIdle`) instead of repeating alarms for maximum reliability. Each time `ReminderReceiver` fires, it schedules the next alarm before checking conditions and showing the notification.

### Condition checking (native)

`ReminderReceiver.onReceive()` reads settings from `FlutterSharedPreferences` (the same file Flutter's `shared_preferences` plugin uses):

- `flutter.is_enabled` — master toggle
- `flutter.start_hour`, `flutter.start_minute` — work window start
- `flutter.end_hour`, `flutter.end_minute` — work window end
- `flutter.work_on_saturday`, `flutter.work_on_sunday` — weekend toggles
- `flutter.last_notified_millis` — deduplication (one notification per calendar hour)

### Boot persistence

`BootReceiver` listens for `ACTION_BOOT_COMPLETED` and re-schedules the hourly alarm if `is_enabled` is true in SharedPreferences.

---

## Why Native Instead of Dart Callbacks

The previous implementation used `flutter_local_notifications`' `AndroidNotificationAction` with Dart background callbacks. This approach failed because:

1. **Background Dart isolate unreliability**: When the app is killed, the plugin must spawn a new Dart isolate to invoke the callback. This is unreliable across Android OEMs and Doze states.
2. **Callback handle overwrite**: Every `NotificationService.initialize()` call stores the callback handle. If any call passes `null` for `onBackground`, the stored handle is wiped.
3. **Uninitialized plugin instances**: `FlutterLocalNotificationsPlugin().cancel()` on a fresh instance in a background isolate silently fails because the method channel isn't connected.

The native approach avoids all of these issues — `BroadcastReceiver.onReceive()` is a first-class Android mechanism that works regardless of the app's lifecycle state.

---

## Manual Verification

1. Tap **"Тест уведомления"** → notification appears with **"Через 10 минут"** button
2. Tap the button → notification is dismissed immediately
3. Wait 10 minutes → a new notification fires (with the snooze button again)
4. Repeat with the app fully killed to verify background path
5. Reboot device → verify hourly alarm resumes automatically
6. Confirm the regular hourly alarm schedule is unaffected
