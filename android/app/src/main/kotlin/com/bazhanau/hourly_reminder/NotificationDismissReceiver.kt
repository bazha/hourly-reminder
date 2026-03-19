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

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        prefs.edit()
            .putLong("flutter.movement_sedentary_start_millis", System.currentTimeMillis())
            .apply()
    }
}
