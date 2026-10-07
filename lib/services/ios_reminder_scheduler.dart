import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../l10n/app_localizations.dart';
import 'notification_l10n.dart';

/// Schedules iOS reminders as a rolling window of one-shot notifications.
///
/// iOS runs no app code when a notification fires, so unlike the Android
/// alarm chain the whole series must be registered in advance.
class IosReminderScheduler {
  /// iOS keeps only the 64 most recently scheduled notifications per app.
  /// 60 leaves room for the snooze and test notifications.
  static const maxReminders = 60;
  static const _firstId = 100;

  /// Snooze notification, scheduled by NotificationService.
  static const snoozeId = 2;

  static const categoryId = 'hourly_reminder_category';
  static const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    categoryIdentifier: categoryId,
  );

  final FlutterLocalNotificationsPlugin _plugin;

  IosReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Replaces pending reminders with [times]. A pending snooze is kept.
  ///
  /// Ids are overwritten in place (same id replaces the pending request) and
  /// only leftovers are cancelled, so an action handler that iOS suspends
  /// mid-rebuild never leaves the queue empty. Skips the rebuild entirely
  /// when the queue already matches.
  Future<void> schedule(List<DateTime> times) async {
    final kept = times.take(maxReminders).toList();
    final prefs = await SharedPreferences.getInstance();
    final l10n = await resolveNotificationLocalizations(prefs);
    final pending = await _pendingReminders();
    if (_isUpToDate(pending, kept, l10n)) return;

    for (final (index, time) in kept.indexed) {
      await _plugin.zonedSchedule(
        id: _firstId + index,
        title: l10n.notificationTitle,
        body: l10n.notificationBody,
        // tz.local is never set and defaults to UTC. Converting the instant
        // to UTC keeps the correct moment: the plugin passes the zone to
        // the iOS calendar trigger.
        scheduledDate: tz.TZDateTime.from(time, tz.UTC),
        notificationDetails: const NotificationDetails(iOS: darwinDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: encodePayload(time),
      );
    }

    for (final request in pending) {
      if (request.id >= _firstId + kept.length) {
        await _plugin.cancel(id: request.id);
      }
    }
  }

  bool _isUpToDate(
    List<PendingNotificationRequest> pending,
    List<DateTime> times,
    AppLocalizations l10n,
  ) {
    if (pending.length != times.length) return false;
    final byId = {for (final request in pending) request.id: request};
    for (final (index, time) in times.indexed) {
      final request = byId[_firstId + index];
      if (request == null ||
          request.payload != encodePayload(time) ||
          request.title != l10n.notificationTitle ||
          request.body != l10n.notificationBody) {
        return false;
      }
    }
    return true;
  }

  /// Cancels pending reminders. Delivered ones stay in Notification Center.
  Future<void> cancel() async {
    for (final request in await _pendingReminders()) {
      await _plugin.cancel(id: request.id);
    }
  }

  /// Cancels a pending snooze. iOS runs no code when it fires, so turning
  /// reminders off or taking a day off must remove it up front.
  Future<void> cancelSnooze() => _plugin.cancel(id: snoozeId);

  Future<List<DateTime>> pendingTimes() async {
    final pending = await _pendingReminders();
    return pending
        .map((request) => parsePayload(request.payload))
        .whereType<DateTime>()
        .toList();
  }

  Future<List<PendingNotificationRequest>> _pendingReminders() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending
        .where((r) => r.id >= _firstId && r.id < _firstId + maxReminders)
        .toList();
  }

  /// Payload carries the scheduled time, so the action handler can compute
  /// reaction time without code running when the notification fires.
  static String encodePayload(DateTime time) =>
      time.millisecondsSinceEpoch.toString();

  static DateTime? parsePayload(String? payload) {
    final millis = int.tryParse(payload ?? '');
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
