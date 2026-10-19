package com.bazhanau.hourly_reminder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Locale

object NotificationHelper {
    const val CHANNEL_ID = "hourly_reminder_channel"
    const val NOTIFICATION_ID = 1

    /**
     * Returns a Context configured with the locale from app_locale preference.
     * Falls back to the system locale if no override is set.
     */
    fun localizedContext(context: Context): Context {
        val prefs = context.flutterPrefs
        val appLocale = prefs.getString(PrefsKeys.APP_LOCALE, null) ?: return context
        val locale = Locale(appLocale)
        val config = android.content.res.Configuration(context.resources.configuration)
        config.setLocale(locale)
        return context.createConfigurationContext(config)
    }

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val lc = localizedContext(context)
            val channel = NotificationChannel(
                CHANNEL_ID,
                lc.getString(R.string.channel_name),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = lc.getString(R.string.channel_description)
                enableVibration(true)
            }
            val nm = context.notificationManager
            nm.createNotificationChannel(channel)
        }
    }

    fun showReminder(context: Context) {
        ensureChannel(context)

        val prefs = context.flutterPrefs
        val lc = localizedContext(context)

        val isFirst = ExerciseRepository.isFirstNotificationToday(prefs)

        // On first notification of the day, reset sedentary start to now.
        // This prevents stale overnight duration from showing.
        if (isFirst) {
            prefs.edit()
                .putLong(PrefsKeys.SEDENTARY_START_MILLIS, System.currentTimeMillis())
                .apply()
        }

        val startMillis = prefs.getLong(PrefsKeys.SEDENTARY_START_MILLIS, 0L)
        val minutes = if (startMillis > 0L) {
            (System.currentTimeMillis() - startMillis) / 60_000L
        } else 0L

        val contentTitle = ExerciseRepository.buildTitle(lc, prefs, minutes)

        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, RequestCodes.NOTIF_SNOOZE,
            Intent(context, SnoozeReceiver::class.java).apply {
                action = SnoozeReceiver.ACTION_SNOOZE
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alreadyMovedPendingIntent = PendingIntent.getBroadcast(
            context, RequestCodes.NOTIF_ALREADY_MOVED,
            Intent(context, AlreadyMovedReceiver::class.java).apply {
                action = AlreadyMovedReceiver.ACTION_ALREADY_MOVED
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val openAppPendingIntent = PendingIntent.getActivity(
            context, RequestCodes.NOTIF_OPEN_APP,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_stats", true)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissPendingIntent = PendingIntent.getBroadcast(
            context, RequestCodes.NOTIF_DISMISS,
            Intent(context, NotificationDismissReceiver::class.java).apply {
                action = NotificationDismissReceiver.ACTION_DISMISS
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_notification)
            .setContentTitle(contentTitle)
            .setContentText(
                if (isFirst) lc.getString(R.string.notif_body_first)
                else lc.getString(R.string.notif_body_exercise)
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setColor(0xFFE09040.toInt())
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setContentIntent(openAppPendingIntent)
            .setDeleteIntent(dismissPendingIntent)
            .addAction(0, lc.getString(R.string.action_snooze), snoozePendingIntent)
            .addAction(0, lc.getString(R.string.action_already_moved), alreadyMovedPendingIntent)

        if (!isFirst) {
            val exercise = ExerciseRepository.getNextExercise(lc, prefs)
            builder.setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(
                        "${exercise.name}\n" +
                        "${exercise.description}\n" +
                        "\u23F1 ${lc.getString(R.string.notif_duration_seconds, exercise.durationSeconds)}"
                    )
            )
        }

        // Record sent time for reaction time calculation in Dart.
        // NOTE: ReminderReceiver also writes flutter.last_notified_millis for
        // deduplication. Both keys record notification time but serve different
        // purposes. Keep them in sync when changing notification timing logic.
        prefs.edit()
            .putLong(
                PrefsKeys.LAST_NOTIFICATION_SENT_MILLIS,
                System.currentTimeMillis()
            )
            .apply()

        // Record notification shown AFTER checking isFirst
        ExerciseRepository.recordNotificationShown(prefs)

        val nm = context.notificationManager
        nm.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) {
        val nm = context.notificationManager
        nm.cancel(NOTIFICATION_ID)
    }
}
