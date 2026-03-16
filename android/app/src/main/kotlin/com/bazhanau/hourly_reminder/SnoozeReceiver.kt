package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock

class SnoozeReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_SNOOZE = "com.bazhanau.hourly_reminder.ACTION_SNOOZE"
        const val ACTION_SHOW_SNOOZED = "com.bazhanau.hourly_reminder.ACTION_SHOW_SNOOZED"
        private const val SNOOZE_DELAY_MS = 10 * 60 * 1000L // 10 minutes
        private const val SNOOZE_REQUEST_CODE = 200
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
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, SnoozeReceiver::class.java).apply {
            action = ACTION_SHOW_SNOOZED
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            SNOOZE_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val triggerAt = SystemClock.elapsedRealtime() + SNOOZE_DELAY_MS

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAt,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAt,
                pendingIntent
            )
        }
    }
}
