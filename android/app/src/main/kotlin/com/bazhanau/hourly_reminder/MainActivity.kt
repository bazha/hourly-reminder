package com.bazhanau.hourly_reminder

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val batteryChannel = "com.bazhanau.hourly_reminder/battery"
    private val alarmChannel = "com.bazhanau.hourly_reminder/alarm"
    private val notificationChannel = "com.bazhanau.hourly_reminder/notification"
    private val navigationChannel = "com.bazhanau.hourly_reminder/navigation"

    private var navigationMethodChannel: MethodChannel? = null
    private var pendingOpenStats = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Check if launched from notification tap
        pendingOpenStats = intent?.getBooleanExtra("open_stats", false) == true

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, batteryChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, alarmChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleHourlyAlarm" -> {
                        ReminderScheduler.scheduleNextHourlyAlarm(applicationContext)
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        ReminderScheduler.cancel(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showReminder" -> {
                        NotificationHelper.showReminder(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        navigationMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, navigationChannel
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAndClearInitialTab" -> {
                        val tab = if (pendingOpenStats) 1 else 0
                        pendingOpenStats = false
                        result.success(tab)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("open_stats", false)) {
            navigationMethodChannel?.invokeMethod("navigateToTab", 1)
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        if (isIgnoringBatteryOptimizations()) return
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:$packageName")
        }
        startActivity(intent)
    }
}
