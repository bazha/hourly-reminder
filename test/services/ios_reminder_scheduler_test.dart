import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hourly_reminder/services/ios_reminder_scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// In-memory stand-in for the plugin's pending notification queue.
class _FakeNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  final pending = <int, PendingNotificationRequest>{};
  final scheduledIds = <int>[];
  final cancelledIds = <int>[];

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduledIds.add(id);
    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelledIds.add(id);
    pending.remove(id);
  }

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => pending.values.toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reminder payload', () {
    test('round-trips the scheduled time', () {
      final time = DateTime(2026, 2, 16, 10, 0);
      final payload = IosReminderScheduler.encodePayload(time);
      expect(IosReminderScheduler.parsePayload(payload), time);
    });

    test('returns null for missing or non-numeric payload', () {
      expect(IosReminderScheduler.parsePayload(null), isNull);
      expect(IosReminderScheduler.parsePayload(''), isNull);
      expect(IosReminderScheduler.parsePayload('hourly_reminder'), isNull);
    });
  });

  group('IosReminderScheduler.schedule', () {
    late _FakeNotificationsPlugin plugin;
    late IosReminderScheduler scheduler;
    final times = [
      DateTime(2026, 2, 16, 10),
      DateTime(2026, 2, 16, 11),
      DateTime(2026, 2, 16, 12),
    ];

    setUp(() {
      SharedPreferences.setMockInitialValues({'app_locale': 'ru'});
      plugin = _FakeNotificationsPlugin();
      scheduler = IosReminderScheduler(plugin: plugin);
    });

    test('skips rebuild when the pending queue already matches', () async {
      await scheduler.schedule(times);
      plugin.scheduledIds.clear();

      await scheduler.schedule(times);

      expect(plugin.scheduledIds, isEmpty);
    });

    test('rebuilds when the notification text changed', () async {
      await scheduler.schedule(times);
      plugin.scheduledIds.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', 'en');

      await scheduler.schedule(times);

      expect(plugin.scheduledIds, [100, 101, 102]);
    });

    test('overwrites in place and cancels only leftover reminders', () async {
      await scheduler.schedule(times);
      final newTimes = [DateTime(2026, 2, 16, 13), DateTime(2026, 2, 16, 14)];

      await scheduler.schedule(newTimes);

      expect(plugin.cancelledIds, [102]);
      expect(plugin.pending.keys, unorderedEquals([100, 101]));
      expect(plugin.pending[100]!.payload,
          IosReminderScheduler.encodePayload(newTimes.first));
    });

    test('cancel keeps a pending snooze', () async {
      plugin.pending[2] = const PendingNotificationRequest(2, 't', 'b', null);
      await scheduler.schedule(times);

      await scheduler.cancel();

      expect(plugin.pending.keys, [2]);
    });
  });
}
