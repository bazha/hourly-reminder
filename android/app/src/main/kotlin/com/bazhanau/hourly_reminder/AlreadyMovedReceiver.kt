package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject

class AlreadyMovedReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_ALREADY_MOVED = "com.bazhanau.hourly_reminder.ACTION_ALREADY_MOVED"
        private const val FAST_REACTION_THRESHOLD_MS = 3 * 60 * 1000L  // 3 minutes
        private const val MINIMUM_INTERVAL_MS = 10 * 60 * 1000L        // 10 minutes
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_ALREADY_MOVED) return

        NotificationHelper.cancel(context)

        val prefs = context.flutterPrefs

        // Day-off check: skip scheduling if today is a day off.
        if (prefs.isDayOffToday()) return

        val now = System.currentTimeMillis()

        // Compute reaction time
        val notificationSentMillis = prefs.getLong(
            PrefsKeys.LAST_NOTIFICATION_SENT_MILLIS, 0L
        )
        val reactionTimeMs = if (notificationSentMillis > 0) {
            now - notificationSentMillis
        } else {
            0L
        }

        // Read base interval from preferences
        val baseIntervalMinutes = prefs.getFlutterInt(
            PrefsKeys.REMINDER_INTERVAL, DEFAULT_INTERVAL_MINUTES)


        // Proportional adaptive rule (matches IntervalCalculator in Dart)
        val factor = if (reactionTimeMs <= FAST_REACTION_THRESHOLD_MS) 0.5 else 0.75
        val nextIntervalMs = maxOf(
            (baseIntervalMinutes * factor * 60 * 1000).toLong(),
            MINIMUM_INTERVAL_MS
        )

        // Compute sedentary duration
        val sedentaryStartMillis = prefs.getLong(
            PrefsKeys.SEDENTARY_START_MILLIS, 0L
        )
        val sedentaryDurationMs = if (sedentaryStartMillis > 0) {
            now - sedentaryStartMillis
        } else {
            0L
        }

        // Persist movement event (matches Dart MovementEventModel JSON format)
        val event = JSONObject().apply {
            put("id", now.toString())
            put("timestampMillis", now)
            put("sedentaryDurationMillis", sedentaryDurationMs)
            put("reactionTimeMillis", reactionTimeMs)
            put("source", "notification")
        }
        prefs.appendToFlutterStringList(PrefsKeys.MOVEMENT_EVENTS, event.toString())

        // Record sedentary start time = now
        prefs.edit()
            .putLong(PrefsKeys.SEDENTARY_START_MILLIS, now)
            .apply()

        // Reminders turned off while the notification was shown: keep the
        // event, but don't restart the alarm chain.
        if (!prefs.getBoolean(PrefsKeys.IS_ENABLED, false)) return

        // Schedule next reminder after the computed interval,
        // but only if it falls within work hours. Otherwise use ReminderScheduler
        // to jump to the next valid work time.
        val wh = prefs.readWorkHours()
        val cal = java.util.Calendar.getInstance()
        val triggerAt = now + nextIntervalMs
        cal.timeInMillis = triggerAt
        val triggerMin = cal.get(java.util.Calendar.HOUR_OF_DAY) * 60 + cal.get(java.util.Calendar.MINUTE)
        if (triggerMin in wh.startMin..wh.endMin) {
            scheduleNextReminder(context, triggerAt)
        } else {
            // Adaptive interval lands outside work hours. Let scheduler find next valid time.
            ReminderScheduler.scheduleNextHourlyAlarm(context)
        }
    }

    private fun scheduleNextReminder(context: Context, triggerAtMillis: Long) {
        context.alarmManager.scheduleExact(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            ReminderScheduler.hourlyPendingIntent(context)
        )
    }
}
