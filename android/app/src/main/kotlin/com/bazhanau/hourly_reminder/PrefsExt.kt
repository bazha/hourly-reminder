package com.bazhanau.hourly_reminder

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import org.json.JSONArray
import java.util.Calendar

const val DEFAULT_INTERVAL_MINUTES = 60

object RequestCodes {
    const val HOURLY_ALARM = 100
    const val SETTLING_ALARM = 150
    const val SNOOZE_ALARM = 200
}

val Context.flutterPrefs: SharedPreferences
    get() = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

val Context.alarmManager: AlarmManager
    get() = getSystemService(Context.ALARM_SERVICE) as AlarmManager

val Context.notificationManager: NotificationManager
    get() = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

data class WorkHours(val startMin: Int, val endMin: Int)

fun SharedPreferences.readWorkHours(): WorkHours {
    val startHour = getFlutterInt("flutter.start_hour", 9)
    val startMinute = getFlutterInt("flutter.start_minute", 0)
    val endHour = getFlutterInt("flutter.end_hour", 18)
    val endMinute = getFlutterInt("flutter.end_minute", 0)
    return WorkHours(
        startMin = startHour * 60 + startMinute,
        endMin = endHour * 60 + endMinute,
    )
}

fun AlarmManager.scheduleExact(type: Int, triggerAtMillis: Long, intent: PendingIntent) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        setExactAndAllowWhileIdle(type, triggerAtMillis, intent)
    } else {
        setExact(type, triggerAtMillis, intent)
    }
}

/** Prefix used by Flutter's shared_preferences plugin for StringList values. */
private const val FLUTTER_LIST_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!"

/**
 * Appends a string to a Flutter StringList stored in SharedPreferences.
 * Flutter's shared_preferences plugin stores StringList as a regular string
 * with a Base64 prefix followed by a JSON array.
 */
fun SharedPreferences.appendToFlutterStringList(key: String, value: String) {
    val stored = getString(key, null)
    val array = if (stored != null && stored.startsWith(FLUTTER_LIST_PREFIX)) {
        JSONArray(stored.removePrefix(FLUTTER_LIST_PREFIX))
    } else {
        JSONArray()
    }
    array.put(value)

    edit()
        .putString(key, FLUTTER_LIST_PREFIX + array.toString())
        .apply()
}

/**
 * Flutter's SharedPreferences plugin stores Dart `int` values as Java Long.
 * Native Android `getInt()` throws ClassCastException when reading these.
 * This extension safely reads them as Long and converts to Int.
 */
fun SharedPreferences.getFlutterInt(key: String, defValue: Int): Int {
    return try {
        getLong(key, defValue.toLong()).toInt()
    } catch (e: ClassCastException) {
        getInt(key, defValue)
    }
}

/**
 * Checks whether the given calendar day is an enabled work day.
 * Reads per-day booleans from SharedPreferences (Mon-Fri default true, Sat-Sun default false).
 * Calendar uses 1=Sun, 2=Mon, ..., 7=Sat.
 */
fun isDayEnabled(prefs: SharedPreferences, cal: Calendar): Boolean {
    val dow = cal.get(Calendar.DAY_OF_WEEK)
    return when (dow) {
        Calendar.MONDAY    -> prefs.getBoolean("flutter.work_on_monday", true)
        Calendar.TUESDAY   -> prefs.getBoolean("flutter.work_on_tuesday", true)
        Calendar.WEDNESDAY -> prefs.getBoolean("flutter.work_on_wednesday", true)
        Calendar.THURSDAY  -> prefs.getBoolean("flutter.work_on_thursday", true)
        Calendar.FRIDAY    -> prefs.getBoolean("flutter.work_on_friday", true)
        Calendar.SATURDAY  -> prefs.getBoolean("flutter.work_on_saturday", false)
        Calendar.SUNDAY    -> prefs.getBoolean("flutter.work_on_sunday", false)
        else -> false
    }
}
