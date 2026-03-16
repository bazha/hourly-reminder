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

        val snoozeIntent = Intent(context, SnoozeReceiver::class.java).apply {
            action = SnoozeReceiver.ACTION_SNOOZE
        }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alreadyMovedIntent = Intent(context, AlreadyMovedReceiver::class.java).apply {
            action = AlreadyMovedReceiver.ACTION_ALREADY_MOVED
        }
        val alreadyMovedPendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            alreadyMovedIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Record notification sent time for reaction time calculation
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        prefs.edit()
            .putLong(
                "flutter.movement_last_notification_sent_millis",
                System.currentTimeMillis()
            )
            .apply()

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Время встать! \u23F0")
            .setContentText("Пора размяться и походить \uD83D\uDEB6")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setColor(0xFF607D8B.toInt())
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .addAction(0, "Через 10 минут", snoozePendingIntent)
            .addAction(0, "Я уже двигался", alreadyMovedPendingIntent)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
    }

    fun cancel(context: Context) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
    }
}
