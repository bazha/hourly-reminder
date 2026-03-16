package com.bazhanau.hourly_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        val isEnabled = prefs.getBoolean("flutter.is_enabled", false)
        if (isEnabled) {
            ReminderScheduler.scheduleNextHourlyAlarm(context)
        }
    }
}
