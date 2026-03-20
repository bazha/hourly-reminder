import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../features/movement/presentation/movement_action_handler.dart';
import '../features/movement/data/datasources/movement_local_datasource.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _nativeChannel =
      MethodChannel('com.bazhanau.hourly_reminder/notification');

  static const _alreadyMovedActionId = 'already_moved';
  static const _snoozeActionId = 'snooze';
  static const _snoozeNotificationId = 2;

  /// Notifies listeners when a notification tap requests a specific tab.
  /// Value is the tab index (1 = stats).
  static final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final l10n = await _resolveLocalizations();

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'hourly_reminder_category',
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
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    if (response.actionId == _alreadyMovedActionId) {
      await MovementActionHandler.handle();
    } else if (response.actionId == _snoozeActionId) {
      await _snoozeForIos();
    } else if (response.actionId == null) {
      // Body tap (not an action button) - open stats screen
      tabNotifier.value = 1;
    }
  }

  static Future<void> _snoozeForIos() async {
    final l10n = await _resolveLocalizations();

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'hourly_reminder_category',
    );

    await _notifications.zonedSchedule(
      _snoozeNotificationId,
      l10n.notificationTitle,
      l10n.notificationBody,
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10)),
      const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
    final l10n = await _resolveLocalizations();

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'hourly_reminder_category',
    );

    const notificationDetails = NotificationDetails(iOS: iosDetails);

    await _notifications.show(
      1,
      l10n.notificationTitle,
      l10n.notificationBody,
      notificationDetails,
      payload: 'hourly_reminder',
    );
  }

  static Future<void> _recordNotificationSentTime() async {
    final prefs = await SharedPreferences.getInstance();
    final datasource = MovementLocalDatasource(prefs);
    await datasource.setLastNotificationSentTime(DateTime.now());
  }

  /// Resolves AppLocalizations using the app_locale preference.
  /// Falls back to system locale, then to Russian.
  static Future<AppLocalizations> _resolveLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final appLocale = prefs.getString('app_locale');
    final locale = appLocale != null
        ? ui.Locale(appLocale)
        : ui.PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales;
    final match = supported.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => const ui.Locale('ru'),
    );
    return AppLocalizations.delegate.load(match);
  }
}
