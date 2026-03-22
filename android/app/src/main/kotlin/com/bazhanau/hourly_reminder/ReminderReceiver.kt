package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

class ReminderReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_HOURLY_REMINDER = "com.bazhanau.hourly_reminder.ACTION_HOURLY_REMINDER"
        private const val DEFAULT_INTERVAL_MINUTES = 60
        private const val SETTLING_REQUEST_CODE = 150
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_HOURLY_REMINDER) return

        // Schedule the NEXT hourly alarm (we use one-shot for exactness)
        ReminderScheduler.scheduleNextHourlyAlarm(context)

        // Check conditions from SharedPreferences
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )

        val isEnabled = prefs.getBoolean("flutter.is_enabled", false)
        if (!isEnabled) return

        // Day-off check: skip if today matches the stored day-off date.
        val dayOffDate = prefs.getString("flutter.day_off_date", null)
        if (dayOffDate != null) {
            val now = Calendar.getInstance()
            val today = String.format(
                "%04d-%02d-%02d",
                now.get(Calendar.YEAR),
                now.get(Calendar.MONTH) + 1,
                now.get(Calendar.DAY_OF_MONTH)
            )
            if (dayOffDate == today) return
        }

        val now = Calendar.getInstance()
        if (!isDayEnabled(prefs, now)) return

        val startHour = prefs.getFlutterInt("flutter.start_hour", 9)
        val startMinute = prefs.getFlutterInt("flutter.start_minute", 0)
        val endHour = prefs.getFlutterInt("flutter.end_hour", 18)
        val endMinute = prefs.getFlutterInt("flutter.end_minute", 0)

        val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val startMin = startHour * 60 + startMinute
        val endMin = endHour * 60 + endMinute

        if (nowMin < startMin || nowMin > endMin) return

        // First notification delay: skip the first interval of the work day.
        val intervalMinutes = prefs.getFlutterInt("flutter.reminder_interval_minutes", DEFAULT_INTERVAL_MINUTES)
        val firstNotifMin = startMin + intervalMinutes
        if (nowMin < firstNotifMin && firstNotifMin <= endMin) {
            // Only schedule the settling alarm if no notification was sent today yet
            val lastNotifiedMillis = prefs.getLong("flutter.last_notified_millis", 0L)
            val sentToday = if (lastNotifiedMillis > 0) {
                val lastNotified = Calendar.getInstance().apply { timeInMillis = lastNotifiedMillis }
                lastNotified.get(Calendar.YEAR) == now.get(Calendar.YEAR) &&
                    lastNotified.get(Calendar.MONTH) == now.get(Calendar.MONTH) &&
                    lastNotified.get(Calendar.DAY_OF_MONTH) == now.get(Calendar.DAY_OF_MONTH)
            } else false

            if (!sentToday) {
                scheduleSettlingAlarm(context, now, firstNotifMin)
                return
            }
        }

        // Deduplication: suppress if last notification was less than half the interval ago
        val dedupeThresholdMs = intervalMinutes * 60 * 1000L / 2
        val lastNotifiedMillis = prefs.getLong("flutter.last_notified_millis", 0L)
        if (lastNotifiedMillis > 0) {
            val elapsed = now.timeInMillis - lastNotifiedMillis
            if (elapsed < dedupeThresholdMs) {
                return
            }
        }

        // Record notification sent
        prefs.edit().putLong("flutter.last_notified_millis", now.timeInMillis).apply()

        // Show notification
        NotificationHelper.showReminder(context)
    }

    private fun scheduleSettlingAlarm(context: Context, now: Calendar, targetMin: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAt = Calendar.getInstance().apply {
            set(Calendar.YEAR, now.get(Calendar.YEAR))
            set(Calendar.MONTH, now.get(Calendar.MONTH))
            set(Calendar.DAY_OF_MONTH, now.get(Calendar.DAY_OF_MONTH))
            set(Calendar.HOUR_OF_DAY, targetMin / 60)
            set(Calendar.MINUTE, targetMin % 60)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ACTION_HOURLY_REMINDER
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            SETTLING_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt.timeInMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAt.timeInMillis,
                pendingIntent
            )
        }
    }
}
