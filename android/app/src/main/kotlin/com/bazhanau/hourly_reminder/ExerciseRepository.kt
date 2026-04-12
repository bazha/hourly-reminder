package com.bazhanau.hourly_reminder

import android.content.Context
import android.content.SharedPreferences
import java.time.LocalDate

object ExerciseRepository {

    private fun exercises(context: Context) = listOf(
        Exercise(context.getString(R.string.exercise_neck),      context.getString(R.string.exercise_neck_desc),      30),
        Exercise(context.getString(R.string.exercise_shoulder),   context.getString(R.string.exercise_shoulder_desc),  30),
        Exercise(context.getString(R.string.exercise_wrist),      context.getString(R.string.exercise_wrist_desc),     30),
        Exercise(context.getString(R.string.exercise_calf),       context.getString(R.string.exercise_calf_desc),      30),
        Exercise(context.getString(R.string.exercise_torso),      context.getString(R.string.exercise_torso_desc),     30),
        Exercise(context.getString(R.string.exercise_back),       context.getString(R.string.exercise_back_desc),      30),
        Exercise(context.getString(R.string.exercise_scapula),    context.getString(R.string.exercise_scapula_desc),   30),
        Exercise(context.getString(R.string.exercise_head_tilt),  context.getString(R.string.exercise_head_tilt_desc), 20),
    )

    fun isFirstNotificationToday(prefs: SharedPreferences): Boolean {
        val savedDate = prefs.getString(PrefsKeys.NOTIFICATIONS_SHOWN_DATE, null)
        val today = LocalDate.now().toString()
        if (savedDate != today) return true
        return prefs.getFlutterInt(PrefsKeys.NOTIFICATIONS_SHOWN_COUNT, 0) == 0
    }

    fun recordNotificationShown(prefs: SharedPreferences) {
        val today = LocalDate.now().toString()
        val savedDate = prefs.getString(PrefsKeys.NOTIFICATIONS_SHOWN_DATE, null)
        val isNewDay = savedDate != today
        val currentCount = if (!isNewDay) {
            prefs.getFlutterInt(PrefsKeys.NOTIFICATIONS_SHOWN_COUNT, 0)
        } else {
            0
        }
        val editor = prefs.edit()
            .putString(PrefsKeys.NOTIFICATIONS_SHOWN_DATE, today)
            .putLong(PrefsKeys.NOTIFICATIONS_SHOWN_COUNT, (currentCount + 1).toLong())
        if (isNewDay) {
            editor.putLong(PrefsKeys.EXERCISE_INDEX, 0L)
        }
        editor.apply()
    }

    fun getNextExercise(context: Context, prefs: SharedPreferences): Exercise {
        val list = exercises(context)
        val index = prefs.getFlutterInt(PrefsKeys.EXERCISE_INDEX, 0)
        val exercise = list[index % list.size]
        // commit() is synchronous: ensures the incremented index is visible
        // before another BroadcastReceiver could read it.
        prefs.edit()
            .putLong(PrefsKeys.EXERCISE_INDEX, ((index + 1) % list.size).toLong())
            .commit()
        return exercise
    }

    fun buildTitle(context: Context, prefs: SharedPreferences, minutes: Long): String {
        if (minutes <= 0L) return context.getString(R.string.notif_title_first)

        val gender = prefs.getString(PrefsKeys.NOTIFICATION_GENDER, "neutral")
        val resId = when (gender) {
            "male"   -> R.string.notif_title_male
            "female" -> R.string.notif_title_female
            else     -> R.string.notif_title_neutral
        }
        return context.getString(resId, minutes.toInt())
    }
}
