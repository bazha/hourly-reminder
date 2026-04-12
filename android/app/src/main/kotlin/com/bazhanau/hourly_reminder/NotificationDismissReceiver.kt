package com.bazhanau.hourly_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationDismissReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_DISMISS = "com.bazhanau.hourly_reminder.ACTION_NOTIFICATION_DISMISSED"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_DISMISS) return

        // Reset sedentary start on dismiss to avoid stale overnight durations
        // accumulating. This does NOT record a movement event.
        val prefs = context.flutterPrefs
        prefs.edit()
            .putLong(PrefsKeys.SEDENTARY_START_MILLIS, System.currentTimeMillis())
            .apply()
    }
}
