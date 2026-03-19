package com.bazhanau.hourly_reminder

import android.content.SharedPreferences
import java.time.LocalDate

object ExerciseRepository {

    private val exercises = listOf(
        Exercise("Повороты шеи",      "Медленно поворачивай голову влево-вправо",           30),
        Exercise("Растяжка плеч",     "Потяни руку через грудь, держи 15 сек",              30),
        Exercise("Растяжка запястий", "Вращай запястья по 10 раз в каждую сторону",         30),
        Exercise("Подъём на носки",   "Встань и поднимись на носки 15 раз",                 30),
        Exercise("Повороты корпуса",  "Сидя, повернись влево-вправо 10 раз",                30),
        Exercise("Растяжка спины",    "Потянись руками вверх, держи 15 сек",                30),
        Exercise("Сжатие плеч",       "Сведи лопатки вместе, держи 5 сек, повтори 10 раз", 30),
        Exercise("Наклоны головы",    "Наклони голову к плечу, держи 10 сек",               20),
    )

    fun isFirstNotificationToday(prefs: SharedPreferences): Boolean {
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val today = LocalDate.now().toString()
        if (savedDate != today) return true
        return prefs.getInt("flutter.notifications_shown_count", 0) == 0
    }

    fun recordNotificationShown(prefs: SharedPreferences) {
        val today = LocalDate.now().toString()
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val isNewDay = savedDate != today
        val currentCount = if (!isNewDay) {
            prefs.getInt("flutter.notifications_shown_count", 0)
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

    fun getNextExercise(prefs: SharedPreferences): Exercise {
        val index = prefs.getInt("flutter.exercise_index", 0)
        val exercise = exercises[index % exercises.size]
        prefs.edit()
            .putInt("flutter.exercise_index", (index + 1) % exercises.size)
            .apply()
        return exercise
    }

    fun buildTitle(prefs: SharedPreferences, minutes: Long): String {
        if (minutes <= 0L) return "Пора размяться"

        val gender = prefs.getString("flutter.notification_gender", "neutral")
        return when (gender) {
            "male"   -> "Ты не двигался $minutes мин."
            "female" -> "Ты не двигалась $minutes мин."
            else     -> "Без движения $minutes мин."
        }
    }
}
