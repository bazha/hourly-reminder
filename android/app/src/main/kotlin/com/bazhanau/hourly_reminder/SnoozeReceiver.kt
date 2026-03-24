package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock

class SnoozeReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_SNOOZE = "com.bazhanau.hourly_reminder.ACTION_SNOOZE"
        const val ACTION_SHOW_SNOOZED = "com.bazhanau.hourly_reminder.ACTION_SHOW_SNOOZED"
        private const val SNOOZE_DELAY_MS = 10 * 60 * 1000L // 10 minutes
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_SNOOZE -> {
                // Cancel current notification
                NotificationHelper.cancel(context)
                // Schedule alarm to show notification in 10 minutes
                scheduleSnoozeAlarm(context)
            }
            ACTION_SHOW_SNOOZED -> {
                // Show the notification again (snooze alarm fired)
                NotificationHelper.showReminder(context)
            }
        }
    }

    private fun scheduleSnoozeAlarm(context: Context) {
        val alarmManager = context.alarmManager
        val intent = Intent(context, SnoozeReceiver::class.java).apply {
            action = ACTION_SHOW_SNOOZED
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            RequestCodes.SNOOZE_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Uses ELAPSED_REALTIME_WAKEUP (not RTC_WAKEUP) because snooze is a short
        // relative delay. Elapsed time is immune to wall-clock changes.
        alarmManager.scheduleExact(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            SystemClock.elapsedRealtime() + SNOOZE_DELAY_MS,
            pendingIntent
        )
    }
}
