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

/** SharedPreferences key constants shared between Dart and native code. */
object PrefsKeys {
    // User preferences
    const val IS_ENABLED = "flutter.is_enabled"
    const val START_HOUR = "flutter.start_hour"
    const val START_MINUTE = "flutter.start_minute"
    const val END_HOUR = "flutter.end_hour"
    const val END_MINUTE = "flutter.end_minute"
    const val REMINDER_INTERVAL = "flutter.reminder_interval_minutes"
    const val NOTIFICATION_GENDER = "flutter.notification_gender"
    const val DAY_OFF_DATE = "flutter.day_off_date"
    const val APP_LOCALE = "flutter.app_locale"

    // Work day toggles
    const val WORK_ON_MONDAY = "flutter.work_on_monday"
    const val WORK_ON_TUESDAY = "flutter.work_on_tuesday"
    const val WORK_ON_WEDNESDAY = "flutter.work_on_wednesday"
    const val WORK_ON_THURSDAY = "flutter.work_on_thursday"
    const val WORK_ON_FRIDAY = "flutter.work_on_friday"
    const val WORK_ON_SATURDAY = "flutter.work_on_saturday"
    const val WORK_ON_SUNDAY = "flutter.work_on_sunday"

    // Movement tracking
    const val SEDENTARY_START_MILLIS = "flutter.movement_sedentary_start_millis"
    const val LAST_NOTIFICATION_SENT_MILLIS = "flutter.movement_last_notification_sent_millis"
    const val MOVEMENT_EVENTS = "flutter.movement_events"
    const val LAST_NOTIFIED_MILLIS = "flutter.last_notified_millis"

    // Exercise notifications
    const val NOTIFICATIONS_SHOWN_DATE = "flutter.notifications_shown_date"
    const val NOTIFICATIONS_SHOWN_COUNT = "flutter.notifications_shown_count"
    const val EXERCISE_INDEX = "flutter.exercise_index"
}

object RequestCodes {
    const val HOURLY_ALARM = 100
    const val SETTLING_ALARM = 150
    const val SNOOZE_ALARM = 200
    // Notification action PendingIntents
    const val NOTIF_SNOOZE = 0
    const val NOTIF_ALREADY_MOVED = 1
    const val NOTIF_OPEN_APP = 2
    const val NOTIF_DISMISS = 3
}

val Context.flutterPrefs: SharedPreferences
    get() = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

val Context.alarmManager: AlarmManager
    get() = getSystemService(Context.ALARM_SERVICE) as AlarmManager

val Context.notificationManager: NotificationManager
    get() = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

data class WorkHours(val startMin: Int, val endMin: Int)

fun SharedPreferences.readWorkHours(): WorkHours {
    val startHour = getFlutterInt(PrefsKeys.START_HOUR, 9)
    val startMinute = getFlutterInt(PrefsKeys.START_MINUTE, 0)
    val endHour = getFlutterInt(PrefsKeys.END_HOUR, 18)
    val endMinute = getFlutterInt(PrefsKeys.END_MINUTE, 0)
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

/** Sets this Calendar's time-of-day fields from a total-minutes value (e.g. 600 = 10:00). */
fun Calendar.setTimeFromMinutes(totalMinutes: Int) {
    set(Calendar.HOUR_OF_DAY, totalMinutes / 60)
    set(Calendar.MINUTE, totalMinutes % 60)
    set(Calendar.SECOND, 0)
    set(Calendar.MILLISECOND, 0)
}

/** Returns true if both Calendars represent the same date (year, month, day). */
fun Calendar.isSameDay(other: Calendar): Boolean =
    get(Calendar.YEAR) == other.get(Calendar.YEAR) &&
    get(Calendar.MONTH) == other.get(Calendar.MONTH) &&
    get(Calendar.DAY_OF_MONTH) == other.get(Calendar.DAY_OF_MONTH)

/**
 * Checks whether the given calendar day is an enabled work day.
 * Reads per-day booleans from SharedPreferences (Mon-Fri default true, Sat-Sun default false).
 * Calendar uses 1=Sun, 2=Mon, ..., 7=Sat.
 */
fun isDayEnabled(prefs: SharedPreferences, cal: Calendar): Boolean {
    val dow = cal.get(Calendar.DAY_OF_WEEK)
    return when (dow) {
        Calendar.MONDAY    -> prefs.getBoolean(PrefsKeys.WORK_ON_MONDAY, true)
        Calendar.TUESDAY   -> prefs.getBoolean(PrefsKeys.WORK_ON_TUESDAY, true)
        Calendar.WEDNESDAY -> prefs.getBoolean(PrefsKeys.WORK_ON_WEDNESDAY, true)
        Calendar.THURSDAY  -> prefs.getBoolean(PrefsKeys.WORK_ON_THURSDAY, true)
        Calendar.FRIDAY    -> prefs.getBoolean(PrefsKeys.WORK_ON_FRIDAY, true)
        Calendar.SATURDAY  -> prefs.getBoolean(PrefsKeys.WORK_ON_SATURDAY, false)
        Calendar.SUNDAY    -> prefs.getBoolean(PrefsKeys.WORK_ON_SUNDAY, false)
        else -> false
    }
}
