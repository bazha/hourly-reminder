import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static Future<UserPreferences> loadPreferences() async {
    return UserPreferences(
      isEnabled:       _prefs.getBool('is_enabled')       ?? false,
      startHour:       _prefs.getInt('start_hour')        ?? 9,
      startMinute:     _prefs.getInt('start_minute')      ?? 0,
      endHour:         _prefs.getInt('end_hour')          ?? 18,
      endMinute:       _prefs.getInt('end_minute')        ?? 0,
      workOnSaturday:  _prefs.getBool('work_on_saturday') ?? false,
      workOnSunday:    _prefs.getBool('work_on_sunday')   ?? false,
    );
  }

  static Future<void> savePreferences(UserPreferences prefs) async {
    await _prefs.setBool('is_enabled',       prefs.isEnabled);
    await _prefs.setInt('start_hour',        prefs.startHour);
    await _prefs.setInt('start_minute',      prefs.startMinute);
    await _prefs.setInt('end_hour',          prefs.endHour);
    await _prefs.setInt('end_minute',        prefs.endMinute);
    await _prefs.setBool('work_on_saturday', prefs.workOnSaturday);
    await _prefs.setBool('work_on_sunday',   prefs.workOnSunday);
  }

  static Future<void> setEnabled(bool value) async {
    await _prefs.setBool('is_enabled', value);
  }

  // Synchronous getters used by AlarmService.alarmCallback (runs in isolate).
  static bool get isEnabled      => _prefs.getBool('is_enabled')       ?? false;
  static int  get startHour      => _prefs.getInt('start_hour')        ?? 9;
  static int  get startMinute    => _prefs.getInt('start_minute')      ?? 0;
  static int  get endHour        => _prefs.getInt('end_hour')          ?? 18;
  static int  get endMinute      => _prefs.getInt('end_minute')        ?? 0;
  static bool get workOnSaturday => _prefs.getBool('work_on_saturday') ?? false;
  static bool get workOnSunday   => _prefs.getBool('work_on_sunday')   ?? false;

  // Deduplication — tracks the last time a notification was actually sent.
  static DateTime? get lastNotifiedAt {
    final millis = _prefs.getInt('last_notified_millis');
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static Future<void> recordNotificationSent(DateTime at) =>
      _prefs.setInt('last_notified_millis', at.millisecondsSinceEpoch);
}
