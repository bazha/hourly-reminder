package com.bazhanau.hourly_reminder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {
    const val CHANNEL_ID = "hourly_reminder_channel"
    const val NOTIFICATION_ID = 1

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Hourly Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Напоминания встать и размяться"
                enableVibration(true)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    fun showReminder(context: Context) {
        ensureChannel(context)

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )

        val isFirst = ExerciseRepository.isFirstNotificationToday(prefs)

        // On first notification of the day, reset sedentary start to now.
        // This prevents stale overnight duration from showing.
        if (isFirst) {
            prefs.edit()
                .putLong("flutter.movement_sedentary_start_millis", System.currentTimeMillis())
                .apply()
        }

        val startMillis = prefs.getLong("flutter.movement_sedentary_start_millis", 0L)
        val minutes = if (startMillis > 0L) {
            (System.currentTimeMillis() - startMillis) / 60_000L
        } else 0L

        val contentTitle = ExerciseRepository.buildTitle(prefs, minutes)

        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, 0,
            Intent(context, SnoozeReceiver::class.java).apply {
                action = SnoozeReceiver.ACTION_SNOOZE
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alreadyMovedPendingIntent = PendingIntent.getBroadcast(
            context, 1,
            Intent(context, AlreadyMovedReceiver::class.java).apply {
                action = AlreadyMovedReceiver.ACTION_ALREADY_MOVED
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val openAppPendingIntent = PendingIntent.getActivity(
            context, 2,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissPendingIntent = PendingIntent.getBroadcast(
            context, 3,
            Intent(context, NotificationDismissReceiver::class.java).apply {
                action = NotificationDismissReceiver.ACTION_DISMISS
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(contentTitle)
            .setContentText(
                if (isFirst) "Время сделать перерыв \uD83D\uDEB6"
                else "Время упражнения! \uD83D\uDCAA"
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setColor(0xFF607D8B.toInt())
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setContentIntent(openAppPendingIntent)
            .setDeleteIntent(dismissPendingIntent)
            .addAction(0, "Через 10 минут", snoozePendingIntent)
            .addAction(0, "Я уже двигался", alreadyMovedPendingIntent)

        if (!isFirst) {
            val exercise = ExerciseRepository.getNextExercise(prefs)
            builder.setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(
                        "${exercise.name}\n" +
                        "${exercise.description}\n" +
                        "\u23F1 ${exercise.durationSeconds} секунд"
                    )
            )
        }

        // Record sent time for reaction time calculation
        prefs.edit()
            .putLong(
                "flutter.movement_last_notification_sent_millis",
                System.currentTimeMillis()
            )
            .apply()

        // Record notification shown AFTER checking isFirst
        ExerciseRepository.recordNotificationShown(prefs)

        // Cancel existing notification so Android treats the new one as fresh
        // (full sound, vibration, heads-up) instead of silently replacing it.
        cancel(context)

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
    }
}
