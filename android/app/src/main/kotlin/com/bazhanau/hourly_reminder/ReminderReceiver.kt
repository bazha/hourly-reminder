package com.bazhanau.hourly_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.Calendar

class ReminderReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_HOURLY_REMINDER = "com.bazhanau.hourly_reminder.ACTION_HOURLY_REMINDER"
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

        val now = Calendar.getInstance()
        val dayOfWeek = now.get(Calendar.DAY_OF_WEEK) // 1=Sun, 2=Mon, ..., 7=Sat
        val workOnSaturday = prefs.getBoolean("flutter.work_on_saturday", false)
        val workOnSunday = prefs.getBoolean("flutter.work_on_sunday", false)

        if (dayOfWeek == Calendar.SATURDAY && !workOnSaturday) return
        if (dayOfWeek == Calendar.SUNDAY && !workOnSunday) return

        val startHour = prefs.getInt("flutter.start_hour", 9)
        val startMinute = prefs.getInt("flutter.start_minute", 0)
        val endHour = prefs.getInt("flutter.end_hour", 18)
        val endMinute = prefs.getInt("flutter.end_minute", 0)

        val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val startMin = startHour * 60 + startMinute
        val endMin = endHour * 60 + endMinute

        if (nowMin < startMin || nowMin > endMin) return

        // Deduplication: only one notification per calendar hour
        val lastNotifiedMillis = prefs.getLong("flutter.last_notified_millis", 0L)
        if (lastNotifiedMillis > 0) {
            val lastNotified = Calendar.getInstance().apply { timeInMillis = lastNotifiedMillis }
            if (lastNotified.get(Calendar.YEAR) == now.get(Calendar.YEAR) &&
                lastNotified.get(Calendar.MONTH) == now.get(Calendar.MONTH) &&
                lastNotified.get(Calendar.DAY_OF_MONTH) == now.get(Calendar.DAY_OF_MONTH) &&
                lastNotified.get(Calendar.HOUR_OF_DAY) == now.get(Calendar.HOUR_OF_DAY)
            ) {
                return
            }
        }

        // Record notification sent
        prefs.edit().putLong("flutter.last_notified_millis", now.timeInMillis).apply()

        // Show notification
        NotificationHelper.showReminder(context)
    }
}
