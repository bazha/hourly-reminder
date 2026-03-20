package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

class AlreadyMovedReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_ALREADY_MOVED = "com.bazhanau.hourly_reminder.ACTION_ALREADY_MOVED"
        private const val REQUEST_CODE = 300
        private const val FAST_REACTION_THRESHOLD_MS = 3 * 60 * 1000L  // 3 minutes
        private const val DEFAULT_INTERVAL_MINUTES = 60
        private const val MINIMUM_INTERVAL_MS = 10 * 60 * 1000L        // 10 minutes
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_ALREADY_MOVED) return

        NotificationHelper.cancel(context)

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )

        val now = System.currentTimeMillis()

        // Compute reaction time
        val notificationSentMillis = prefs.getLong(
            "flutter.movement_last_notification_sent_millis", 0L
        )
        val reactionTimeMs = if (notificationSentMillis > 0) {
            now - notificationSentMillis
        } else {
            0L
        }

        // Read base interval from preferences
        val baseIntervalMinutes = prefs.getInt(
            "flutter.reminder_interval_minutes", DEFAULT_INTERVAL_MINUTES
        )

        // Proportional adaptive rule (matches IntervalCalculator in Dart)
        val factor = if (reactionTimeMs <= FAST_REACTION_THRESHOLD_MS) 0.5 else 0.75
        val nextIntervalMs = maxOf(
            (baseIntervalMinutes * factor * 60 * 1000).toLong(),
            MINIMUM_INTERVAL_MS
        )

        // Record sedentary start time = now
        prefs.edit()
            .putLong("flutter.movement_sedentary_start_millis", now)
            .apply()

        // Schedule next reminder after the computed interval
        scheduleNextReminder(context, nextIntervalMs)
    }

    private fun scheduleNextReminder(context: Context, delayMs: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ReminderReceiver.ACTION_HOURLY_REMINDER
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val triggerAt = System.currentTimeMillis() + delayMs

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent
            )
        }
    }
}
