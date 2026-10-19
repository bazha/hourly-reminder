import 'dart:io' show Platform;
import 'dart:ui' show DartPluginRegistrant;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../features/movement/presentation/movement_action_handler.dart';
import '../features/movement/data/datasources/movement_local_datasource.dart';
import 'ios_reminder_scheduler.dart';
import 'notification_l10n.dart';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry point for iOS notification actions. Actions without the foreground
/// option always run in a separate background engine, where main() and
/// NotificationService.initialize() never ran.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
    NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  // The background engine may outlive several actions; drop its stale cache.
  await (await SharedPreferences.getInstance()).reload();
  await NotificationService.initialize(requestPermissions: false);
  await NotificationService.handleResponse(response);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _nativeChannel =
      MethodChannel('com.bazhanau.hourly_reminder/notification');

  static const _alreadyMovedActionId = 'already_moved';
  static const _snoozeActionId = 'snooze';

  /// Notifies listeners when a notification tap requests a specific tab.
  /// Value is the tab index (1 = stats).
  static final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  /// Both the main and the background engine call this, so they register
  /// identical notification categories. Only the main engine asks for
  /// permissions.
  static Future<void> initialize({bool requestPermissions = true}) async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    final prefs = await SharedPreferences.getInstance();
    final l10n = await resolveNotificationLocalizations(prefs);

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: requestPermissions,
      requestBadgePermission: requestPermissions,
      requestSoundPermission: requestPermissions,
      notificationCategories: [
        DarwinNotificationCategory(
          IosReminderScheduler.categoryId,
          actions: [
            DarwinNotificationAction.plain(
              _snoozeActionId,
              l10n.notificationSnooze,
            ),
            DarwinNotificationAction.plain(
              _alreadyMovedActionId,
              l10n.notificationAlreadyMoved,
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
      settings: initSettings,
      onDidReceiveNotificationResponse: handleResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  static Future<void> handleResponse(NotificationResponse response) async {
    if (response.actionId == _alreadyMovedActionId) {
      await _recordScheduledTimeAsSent(response.payload);
      await MovementActionHandler.handle();
    } else if (response.actionId == _snoozeActionId) {
      await _snoozeForIos();
    } else if (response.actionId == null) {
      // Body tap (not an action button) - open stats screen
      tabNotifier.value = 1;
    }
  }

  /// iOS can't record the send time when a scheduled notification fires,
  /// so the payload carries it. Reaction time is computed from this value.
  static Future<void> _recordScheduledTimeAsSent(String? payload) async {
    final sentAt = IosReminderScheduler.parsePayload(payload);
    if (sentAt == null) return;
    final prefs = await SharedPreferences.getInstance();
    await MovementLocalDatasource(prefs).setLastNotificationSentTime(sentAt);
  }

  static Future<void> _snoozeForIos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    // iOS runs no code when the snooze fires, so check now. Covers a snooze
    // tapped on an old notification after reminders were turned off or the
    // day off was turned on.
    if (!StorageService(prefs).remindersActiveToday) return;
    final l10n = await resolveNotificationLocalizations(prefs);
    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));

    await _notifications.zonedSchedule(
      id: IosReminderScheduler.snoozeId,
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      scheduledDate: scheduledDate,
      notificationDetails:
          const NotificationDetails(iOS: IosReminderScheduler.darwinDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: IosReminderScheduler.encodePayload(scheduledDate),
    );
  }

  static Future<bool> requestPermissions() async {
    // iOS: requestPermissions returns whether the user granted access.
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? true;
    }

    // Android 13+
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  static Future<void> showHourlyNotification() async {
    final prefs = await SharedPreferences.getInstance();

    // Record when this notification was sent so the movement feature
    // can compute reaction time later.
    await _recordNotificationSentTime(prefs);

    if (Platform.isAndroid) {
      // On Android, show notification natively (with snooze button handled
      // entirely on the native side via BroadcastReceiver + AlarmManager).
      await _nativeChannel.invokeMethod('showReminder');
      return;
    }

    // iOS path: use flutter_local_notifications with "I already moved" action
    final l10n = await resolveNotificationLocalizations(prefs);

    await _notifications.show(
      id: 1,
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      notificationDetails:
          const NotificationDetails(iOS: IosReminderScheduler.darwinDetails),
      payload: IosReminderScheduler.encodePayload(DateTime.now()),
    );
  }

  static Future<void> _recordNotificationSentTime(
      SharedPreferences prefs) async {
    final datasource = MovementLocalDatasource(prefs);
    await datasource.setLastNotificationSentTime(DateTime.now());
  }
}
