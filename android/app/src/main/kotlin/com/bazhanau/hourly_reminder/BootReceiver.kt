package com.bazhanau.hourly_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.flutterPrefs
        val isEnabled = prefs.getBoolean(PrefsKeys.IS_ENABLED, false)
        if (isEnabled) {
            ReminderScheduler.scheduleNextHourlyAlarm(context)
        }
    }
}
