import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movement_event_model.dart';

class MovementLocalDatasource {
  static const _sedentaryStartKey = 'movement_sedentary_start_millis';
  static const _lastNotificationSentKey =
      'movement_last_notification_sent_millis';
  static const _eventsKey = 'movement_events';

  final SharedPreferences _prefs;

  MovementLocalDatasource(this._prefs);

  DateTime? getSedentaryStartTime() => _getMillisAsDateTime(_sedentaryStartKey);

  Future<void> setSedentaryStartTime(DateTime time) =>
      _prefs.setInt(_sedentaryStartKey, time.millisecondsSinceEpoch);

  DateTime? getLastNotificationSentTime() =>
      _getMillisAsDateTime(_lastNotificationSentKey);

  Future<void> setLastNotificationSentTime(DateTime time) =>
      _prefs.setInt(_lastNotificationSentKey, time.millisecondsSinceEpoch);

  /// Reads a millis timestamp that may have been written as Int (Dart) or
  /// Long (Android native putLong). _prefs.getInt() returns null if the
  /// underlying value is a Long, so we use _prefs.get() and cast safely.
  DateTime? _getMillisAsDateTime(String key) {
    final raw = _prefs.get(key);
    if (raw is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
  }

  Future<void> saveEvent(MovementEventModel model) async {
    final existing = _prefs.getStringList(_eventsKey) ?? [];
    existing.add(jsonEncode(model.toJson()));
    await _prefs.setStringList(_eventsKey, existing);
  }

  Future<List<MovementEventModel>> getEvents() async {
    // reload() is required: the Android native pipeline (AlreadyMovedReceiver)
    // writes events directly to SharedPreferences while the Flutter engine may
    // not be running, so the in-memory cache can be stale.
    await _prefs.reload();
    final raw = _prefs.getStringList(_eventsKey) ?? [];
    return raw
        .map((s) =>
            MovementEventModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
