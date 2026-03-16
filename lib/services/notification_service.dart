import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _nativeChannel =
      MethodChannel('com.bazhanau.hourly_reminder/notification');

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  static Future<bool> requestPermissions() async {
    // Request permissions for iOS
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    // Request permissions for Android 13+
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();

    return granted ?? true;
  }

  static Future<void> showHourlyNotification() async {
    if (Platform.isAndroid) {
      // On Android, show notification natively (with snooze button handled
      // entirely on the native side via BroadcastReceiver + AlarmManager).
      await _nativeChannel.invokeMethod('showReminder');
      return;
    }

    // iOS path: use flutter_local_notifications (no snooze action on iOS)
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(iOS: iosDetails);

    await _notifications.show(
      1,
      'Время встать! ⏰',
      'Пора размяться и походить 🚶',
      notificationDetails,
      payload: 'hourly_reminder',
    );
  }
}
