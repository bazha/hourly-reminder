# Change Plan: Fix Ignored Notification Stops Follow-up Notifications

**Status**: Applied

## Problem

When a user ignores a notification (doesn't tap any action button), subsequent notifications are not noticed. The root cause: `NotificationHelper` posts every notification with the same `NOTIFICATION_ID = 1`. When the old notification is still in the drawer, Android silently replaces it without sound, vibration, or heads-up popup. The user thinks no new notification arrived.

Secondary issues found during investigation:
- No `setDeleteIntent` - dismissing a notification triggers no code
- No `setContentIntent` - tapping the notification body does nothing useful
- No protection against OEM battery optimization killing the alarm chain

## Goal

1. Ensure every hourly notification produces a full alert (sound, vibration, heads-up) even if a previous notification is still in the drawer
2. Add a delete intent so dismissed notifications reset sedentary tracking
3. Add a content intent so tapping the notification body opens the app

## Affected Files

### Android native
- `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/NotificationHelper.kt` - cancel before show, add delete/content intents
- `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/NotificationDismissReceiver.kt` - **new file**, handles notification dismiss

### Android manifest
- `android/app/src/main/AndroidManifest.xml` - register `NotificationDismissReceiver`

### Tests
- `test/` - unit tests for any Dart-side changes if needed

## Implementation Steps

### Step 1: Cancel before showing new notification

In `NotificationHelper.showReminder()`, call `cancel(context)` before `nm.notify(...)`. This forces Android to treat the next `notify()` as a brand-new notification with full alert behavior.

```kotlin
// In showReminder(), before nm.notify():
cancel(context)
nm.notify(NOTIFICATION_ID, builder.build())
```

### Step 2: Add content intent (open app on tap)

Add a `setContentIntent` to the notification builder so tapping the notification body opens `MainActivity`.

```kotlin
val openAppIntent = PendingIntent.getActivity(
    context, 2,
    Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    },
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)
builder.setContentIntent(openAppIntent)
```

### Step 3: Create NotificationDismissReceiver

Create a new `NotificationDismissReceiver` that handles notification swipe-dismiss. On dismiss, reset `movement_sedentary_start_millis` to current time so the next notification shows accurate sedentary duration.

```kotlin
class NotificationDismissReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_DISMISS = "com.bazhanau.hourly_reminder.ACTION_NOTIFICATION_DISMISSED"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_DISMISS) return
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        prefs.edit()
            .putLong("flutter.movement_sedentary_start_millis", System.currentTimeMillis())
            .apply()
    }
}
```

### Step 4: Add delete intent to notification

Wire `NotificationDismissReceiver` as the delete intent in `NotificationHelper`.

```kotlin
val dismissPendingIntent = PendingIntent.getBroadcast(
    context, 3,
    Intent(context, NotificationDismissReceiver::class.java).apply {
        action = NotificationDismissReceiver.ACTION_DISMISS
    },
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)
builder.setDeleteIntent(dismissPendingIntent)
```

### Step 5: Register receiver in AndroidManifest.xml

```xml
<receiver
    android:name=".NotificationDismissReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="com.bazhanau.hourly_reminder.ACTION_NOTIFICATION_DISMISSED" />
    </intent-filter>
</receiver>
```

### Step 6: Test

- Build debug APK and install on device
- Wait for a notification, do NOT interact with it
- Verify next hourly notification produces full alert (sound, vibration, heads-up)
- Swipe away a notification, verify sedentary timer resets
- Tap notification body, verify app opens
- Tap "Snooze" and "Already moved" buttons, verify they still work

## Rollback Plan

Revert the changes to `NotificationHelper.kt`, `AndroidManifest.xml`, and delete `NotificationDismissReceiver.kt`. No data migration needed since we only write to existing SharedPreferences keys.

## Benefits

- Users will always notice new notifications even if they ignored the previous one
- Tapping notification body now opens the app (was a no-op before)
- Dismissing a notification resets sedentary tracking for accurate duration display

## Estimated Scope

Small change. 1 new file, 2 modified files. All Android native, no Dart changes.
