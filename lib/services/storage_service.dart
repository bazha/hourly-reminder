import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<UserPreferences> loadPreferences() async {
    return UserPreferences(
      isEnabled:          _prefs.getBool('is_enabled')       ?? false,
      startHour:          _prefs.getInt('start_hour')        ?? 9,
      startMinute:        _prefs.getInt('start_minute')      ?? 0,
      endHour:            _prefs.getInt('end_hour')          ?? 18,
      endMinute:          _prefs.getInt('end_minute')        ?? 0,
      workOnSaturday:     _prefs.getBool('work_on_saturday') ?? false,
      workOnSunday:       _prefs.getBool('work_on_sunday')   ?? false,
      notificationGender: _genderFromString(
          _prefs.getString('notification_gender') ?? 'neutral'),
      dailyGoal:          _prefs.getInt('daily_goal') ?? 8,
    );
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await _prefs.setBool('is_enabled',          prefs.isEnabled);
    await _prefs.setInt('start_hour',           prefs.startHour);
    await _prefs.setInt('start_minute',         prefs.startMinute);
    await _prefs.setInt('end_hour',             prefs.endHour);
    await _prefs.setInt('end_minute',           prefs.endMinute);
    await _prefs.setBool('work_on_saturday',    prefs.workOnSaturday);
    await _prefs.setBool('work_on_sunday',      prefs.workOnSunday);
    await _prefs.setString('notification_gender', prefs.notificationGender.name);
    await _prefs.setInt('daily_goal',              prefs.dailyGoal);
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool('is_enabled', value);
  }

  // Synchronous getters used by AlarmService.alarmCallback (runs in isolate).
  bool get isEnabled      => _prefs.getBool('is_enabled')       ?? false;
  int  get startHour      => _prefs.getInt('start_hour')        ?? 9;
  int  get startMinute    => _prefs.getInt('start_minute')      ?? 0;
  int  get endHour        => _prefs.getInt('end_hour')          ?? 18;
  int  get endMinute      => _prefs.getInt('end_minute')        ?? 0;
  bool get workOnSaturday => _prefs.getBool('work_on_saturday') ?? false;
  bool get workOnSunday   => _prefs.getBool('work_on_sunday')   ?? false;
  int  get dailyGoal      => _prefs.getInt('daily_goal')        ?? 8;

  NotificationGender _genderFromString(String value) {
    return NotificationGender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationGender.neutral,
    );
  }

  // Deduplication - tracks the last time a notification was actually sent.
  DateTime? get lastNotifiedAt {
    final millis = _prefs.getInt('last_notified_millis');
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> recordNotificationSent(DateTime at) =>
      _prefs.setInt('last_notified_millis', at.millisecondsSinceEpoch);
}
