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
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val today = LocalDate.now().toString()
        if (savedDate != today) return true
        return prefs.getFlutterInt("flutter.notifications_shown_count", 0) == 0
    }

    fun recordNotificationShown(prefs: SharedPreferences) {
        val today = LocalDate.now().toString()
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val isNewDay = savedDate != today
        val currentCount = if (!isNewDay) {
            prefs.getFlutterInt("flutter.notifications_shown_count", 0)
        } else {
            0
        }
        val editor = prefs.edit()
            .putString("flutter.notifications_shown_date", today)
            .putInt("flutter.notifications_shown_count", currentCount + 1)
        if (isNewDay) {
            editor.putInt("flutter.exercise_index", 0)
        }
        editor.apply()
    }

    fun getNextExercise(context: Context, prefs: SharedPreferences): Exercise {
        val list = exercises(context)
        val index = prefs.getFlutterInt("flutter.exercise_index", 0)
        val exercise = list[index % list.size]
        prefs.edit()
            .putInt("flutter.exercise_index", (index + 1) % list.size)
            .apply()
        return exercise
    }

    fun buildTitle(context: Context, prefs: SharedPreferences, minutes: Long): String {
        if (minutes <= 0L) return context.getString(R.string.notif_title_first)

        val gender = prefs.getString("flutter.notification_gender", "neutral")
        val resId = when (gender) {
            "male"   -> R.string.notif_title_male
            "female" -> R.string.notif_title_female
            else     -> R.string.notif_title_neutral
        }
        return context.getString(resId, minutes.toInt())
    }
}
