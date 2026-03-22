package com.bazhanau.hourly_reminder

import android.content.SharedPreferences
import java.util.Calendar

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
