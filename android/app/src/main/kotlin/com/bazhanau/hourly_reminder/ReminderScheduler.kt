package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import java.util.Calendar

object ReminderScheduler {
    private const val HOURLY_REQUEST_CODE = 100
    private const val DEFAULT_INTERVAL_MINUTES = 60

    fun scheduleNextHourlyAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        val intervalMinutes = prefs.getFlutterInt("flutter.reminder_interval_minutes", DEFAULT_INTERVAL_MINUTES)
        val startHour = prefs.getFlutterInt("flutter.start_hour", 9)
        val startMinute = prefs.getFlutterInt("flutter.start_minute", 0)
        val endHour = prefs.getFlutterInt("flutter.end_hour", 18)
        val endMinute = prefs.getFlutterInt("flutter.end_minute", 0)

        val startMin = startHour * 60 + startMinute
        val endMin = endHour * 60 + endMinute

        val next = nextValidAlarmTime(
            prefs, intervalMinutes, startMin, endMin
        ) ?: return

        val pendingIntent = buildHourlyPendingIntent(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                next.timeInMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                next.timeInMillis,
                pendingIntent
            )
        }
    }

    private fun nextValidAlarmTime(
        prefs: SharedPreferences,
        intervalMinutes: Int,
        startMin: Int,
        endMin: Int,
    ): Calendar? {
        val now = Calendar.getInstance()
        val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

        if (isDayEnabled(prefs, now)) {
            val candidateMin = nowMin + intervalMinutes
            if (candidateMin <= endMin && nowMin >= startMin) {
                return Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, candidateMin / 60)
                    set(Calendar.MINUTE, candidateMin % 60)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
            }
        }

        val candidate = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
        }
        for (i in 0 until 8) {
            if (isDayEnabled(prefs, candidate)) {
                val firstMin = startMin + intervalMinutes
                val targetMin = if (firstMin <= endMin) firstMin else startMin
                return candidate.apply {
                    set(Calendar.HOUR_OF_DAY, targetMin / 60)
                    set(Calendar.MINUTE, targetMin % 60)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
            }
            candidate.add(Calendar.DAY_OF_YEAR, 1)
        }

        return null
    }

    fun cancel(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(buildHourlyPendingIntent(context))
    }

    private fun buildHourlyPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ReminderReceiver.ACTION_HOURLY_REMINDER
        }
        return PendingIntent.getBroadcast(
            context,
            HOURLY_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
