import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../features/movement/presentation/movement_action_handler.dart';
import '../features/movement/data/datasources/movement_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _nativeChannel =
      MethodChannel('com.bazhanau.hourly_reminder/notification');

  static const _alreadyMovedActionId = 'already_moved';

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'hourly_reminder_category',
          actions: [
            DarwinNotificationAction.plain(
              'already_moved',
              'Я уже двигался',
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    if (response.actionId == _alreadyMovedActionId) {
      await MovementActionHandler.handle();
    }
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
    // Record when this notification was sent so the movement feature
    // can compute reaction time later.
    await _recordNotificationSentTime();

    if (Platform.isAndroid) {
      // On Android, show notification natively (with snooze button handled
      // entirely on the native side via BroadcastReceiver + AlarmManager).
      await _nativeChannel.invokeMethod('showReminder');
      return;
    }

    // iOS path: use flutter_local_notifications with "I already moved" action
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'hourly_reminder_category',
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

  static Future<void> _recordNotificationSentTime() async {
    final prefs = await SharedPreferences.getInstance();
    final datasource = MovementLocalDatasource(prefs);
    await datasource.setLastNotificationSentTime(DateTime.now());
  }
}
