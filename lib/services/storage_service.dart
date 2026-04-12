import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/time_utils.dart';
import '../models/user_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  UserPreferences loadPreferences() {
    return UserPreferences(
      isEnabled: _prefs.getBool('is_enabled') ?? false,
      startHour: _prefs.getInt('start_hour') ?? 9,
      startMinute: _prefs.getInt('start_minute') ?? 0,
      endHour: _prefs.getInt('end_hour') ?? 18,
      endMinute: _prefs.getInt('end_minute') ?? 0,
      workOnMonday: _prefs.getBool('work_on_monday') ?? true,
      workOnTuesday: _prefs.getBool('work_on_tuesday') ?? true,
      workOnWednesday: _prefs.getBool('work_on_wednesday') ?? true,
      workOnThursday: _prefs.getBool('work_on_thursday') ?? true,
      workOnFriday: _prefs.getBool('work_on_friday') ?? true,
      workOnSaturday: _prefs.getBool('work_on_saturday') ?? false,
      workOnSunday: _prefs.getBool('work_on_sunday') ?? false,
      notificationGender: _genderFromString(
          _prefs.getString('notification_gender') ?? 'neutral'),
      dailyGoal: _prefs.getInt('daily_goal') ?? 8,
      reminderIntervalMinutes: _prefs.getInt('reminder_interval_minutes') ?? 60,
    );
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await Future.wait([
      _prefs.setBool('is_enabled', prefs.isEnabled),
      _prefs.setInt('start_hour', prefs.startHour),
      _prefs.setInt('start_minute', prefs.startMinute),
      _prefs.setInt('end_hour', prefs.endHour),
      _prefs.setInt('end_minute', prefs.endMinute),
      _prefs.setBool('work_on_monday', prefs.workOnMonday),
      _prefs.setBool('work_on_tuesday', prefs.workOnTuesday),
      _prefs.setBool('work_on_wednesday', prefs.workOnWednesday),
      _prefs.setBool('work_on_thursday', prefs.workOnThursday),
      _prefs.setBool('work_on_friday', prefs.workOnFriday),
      _prefs.setBool('work_on_saturday', prefs.workOnSaturday),
      _prefs.setBool('work_on_sunday', prefs.workOnSunday),
      _prefs.setString('notification_gender', prefs.notificationGender.name),
      _prefs.setInt('daily_goal', prefs.dailyGoal),
      _prefs.setInt('reminder_interval_minutes', prefs.reminderIntervalMinutes),
    ]);
  }

  NotificationGender _genderFromString(String value) {
    return NotificationGender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationGender.neutral,
    );
  }

  /// Day-off: stores today's date string to suppress notifications for the day.
  String? get dayOffDate => _prefs.getString('day_off_date');

  Future<void> setDayOff(String? date) async {
    if (date == null) {
      await _prefs.remove('day_off_date');
    } else {
      await _prefs.setString('day_off_date', date);
    }
  }

  bool get isDayOff {
    final saved = dayOffDate;
    if (saved == null) return false;
    return saved == TimeUtils.formatDate(DateTime.now());
  }
}
