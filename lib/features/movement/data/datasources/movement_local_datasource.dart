import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movement_event_model.dart';

class MovementLocalDatasource {
  static const _sedentaryStartKey = 'movement_sedentary_start_millis';
  static const _lastNotificationSentKey = 'movement_last_notification_sent_millis';
  static const _eventsKey = 'movement_events';

  final SharedPreferences _prefs;

  MovementLocalDatasource(this._prefs);

  DateTime? getSedentaryStartTime() {
    final millis = _prefs.getInt(_sedentaryStartKey);
    return millis != null
        ? DateTime.fromMillisecondsSinceEpoch(millis)
        : null;
  }

  Future<void> setSedentaryStartTime(DateTime time) =>
      _prefs.setInt(_sedentaryStartKey, time.millisecondsSinceEpoch);

  DateTime? getLastNotificationSentTime() {
    final millis = _prefs.getInt(_lastNotificationSentKey);
    return millis != null
        ? DateTime.fromMillisecondsSinceEpoch(millis)
        : null;
  }

  Future<void> setLastNotificationSentTime(DateTime time) =>
      _prefs.setInt(_lastNotificationSentKey, time.millisecondsSinceEpoch);

  Future<void> saveEvent(MovementEventModel model) async {
    final existing = _prefs.getStringList(_eventsKey) ?? [];
    existing.add(jsonEncode(model.toJson()));
    await _prefs.setStringList(_eventsKey, existing);
  }

  List<MovementEventModel> getEvents() {
    final raw = _prefs.getStringList(_eventsKey) ?? [];
    return raw
        .map((s) => MovementEventModel.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
