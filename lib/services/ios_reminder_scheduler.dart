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
  /// iOS keeps only the 64 soonest notifications per app. 60 leaves room
  /// for the test (1), snooze (2) and paused (3) notifications.
  static const maxReminders = 60;
  static const _firstId = 100;

  /// Snooze notification, scheduled by NotificationService.
  static const snoozeId = 2;

  /// "Reminders paused" notice at the slot after the last queued reminder.
  /// The queue runs out if the app is not opened; this tells the user so.
  static const pausedId = 3;

  static const categoryId = 'hourly_reminder_category';
  static const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    categoryIdentifier: categoryId,
  );
  static const _pausedDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final FlutterLocalNotificationsPlugin _plugin;

  IosReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Replaces pending reminders with the first [maxReminders] of [times].
  /// A time past them becomes the "reminders paused" notice. A pending
  /// snooze is kept.
  ///
  /// Ids are overwritten in place (same id replaces the pending request) and
  /// only leftovers are cancelled, so an action handler that iOS suspends
  /// mid-rebuild never leaves the queue empty. Skips the rebuild entirely
  /// when the queue already matches.
  Future<void> schedule(List<DateTime> times) async {
    final kept = times.take(maxReminders).toList();
    final pausedAt = times.length > maxReminders ? times[maxReminders] : null;
    final prefs = await SharedPreferences.getInstance();
    final l10n = await resolveNotificationLocalizations(prefs);
    final all = await _plugin.pendingNotificationRequests();
    final pending = all.where((r) => _isReminderId(r.id)).toList();

    if (!_isUpToDate(pending, kept, l10n)) {
      await _scheduleReminders(pending, kept, l10n);
    }
    await _schedulePaused(
      all.where((r) => r.id == pausedId).firstOrNull,
      pausedAt,
      l10n,
    );
  }

  Future<void> _scheduleReminders(
    List<PendingNotificationRequest> pending,
    List<DateTime> kept,
    AppLocalizations l10n,
  ) async {
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

  Future<void> _schedulePaused(
    PendingNotificationRequest? pending,
    DateTime? pausedAt,
    AppLocalizations l10n,
  ) async {
    if (pausedAt == null) {
      if (pending != null) await _plugin.cancel(id: pausedId);
      return;
    }
    if (pending != null &&
        pending.payload == encodePayload(pausedAt) &&
        pending.title == l10n.notificationPausedTitle &&
        pending.body == l10n.notificationPausedBody) {
      return;
    }
    if (pending == null) {
      // The notice may have fired and still sit in Notification Center
      // although reminders run again. cancel() also removes delivered ones.
      await _plugin.cancel(id: pausedId);
    }
    await _plugin.zonedSchedule(
      id: pausedId,
      title: l10n.notificationPausedTitle,
      body: l10n.notificationPausedBody,
      scheduledDate: tz.TZDateTime.from(pausedAt, tz.UTC),
      notificationDetails: const NotificationDetails(iOS: _pausedDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: encodePayload(pausedAt),
    );
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

  /// Cancels pending reminders and the paused notice. A snooze is kept.
  /// The plugin's cancel also removes a delivered notification with the
  /// same id.
  Future<void> cancel() async {
    for (final request in await _plugin.pendingNotificationRequests()) {
      if (_isReminderId(request.id) || request.id == pausedId) {
        await _plugin.cancel(id: request.id);
      }
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
    return pending.where((r) => _isReminderId(r.id)).toList();
  }

  static bool _isReminderId(int id) =>
      id >= _firstId && id < _firstId + maxReminders;

  /// Payload carries the scheduled time, so the action handler can compute
  /// reaction time without code running when the notification fires.
  static String encodePayload(DateTime time) =>
      time.millisecondsSinceEpoch.toString();

  static DateTime? parsePayload(String? payload) {
    final millis = int.tryParse(payload ?? '');
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
