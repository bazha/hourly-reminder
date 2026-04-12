package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import java.util.Calendar

object ReminderScheduler {

    fun scheduleNextHourlyAlarm(context: Context) {
        val alarmManager = context.alarmManager

        val prefs = context.flutterPrefs
        val intervalMinutes = prefs.getFlutterInt(PrefsKeys.REMINDER_INTERVAL, DEFAULT_INTERVAL_MINUTES)
        val wh = prefs.readWorkHours()

        val next = nextValidAlarmTime(
            prefs, intervalMinutes, wh.startMin, wh.endMin
        ) ?: return

        alarmManager.scheduleExact(
            AlarmManager.RTC_WAKEUP,
            next.timeInMillis,
            buildHourlyPendingIntent(context)
        )
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
            val firstMin = startMin + intervalMinutes
            if (nowMin < startMin) {
                if (firstMin <= endMin) {
                    return Calendar.getInstance().apply { setTimeFromMinutes(firstMin) }
                }
            } else if (nowMin < firstMin && firstMin <= endMin) {
                return Calendar.getInstance().apply { setTimeFromMinutes(firstMin) }
            } else if (nowMin <= endMin) {
                val candidateMin = nowMin + intervalMinutes
                if (candidateMin <= endMin) {
                    return Calendar.getInstance().apply { setTimeFromMinutes(candidateMin) }
                }
            }
        }

        val candidate = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
        }
        repeat(8) {
            if (isDayEnabled(prefs, candidate)) {
                val firstMin = startMin + intervalMinutes
                if (firstMin <= endMin) {
                    return candidate.apply { setTimeFromMinutes(firstMin) }
                }
            }
            candidate.add(Calendar.DAY_OF_YEAR, 1)
        }

        return null
    }

    fun cancel(context: Context) {
        val alarmManager = context.alarmManager
        alarmManager.cancel(buildHourlyPendingIntent(context))
    }

    private fun buildHourlyPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ReminderReceiver.ACTION_HOURLY_REMINDER
        }
        return PendingIntent.getBroadcast(
            context,
            RequestCodes.HOURLY_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
