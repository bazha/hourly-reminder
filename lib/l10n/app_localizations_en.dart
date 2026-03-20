// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Reminder';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Statistics';

  @override
  String get toggleOn => 'ON';

  @override
  String get toggleOff => 'OFF';

  @override
  String get toggleSemanticsLabel => 'Reminders';

  @override
  String get remindersDisabled => 'Reminders disabled';

  @override
  String nextReminderToday(String time) {
    return 'Next at $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Next tomorrow at $time';
  }

  @override
  String nextReminderOnDay(String dayName, String time) {
    return 'Next on $dayName at $time';
  }

  @override
  String get todayLabel => 'TODAY';

  @override
  String goalProgressText(int goal) {
    return 'of $goal movements';
  }

  @override
  String get recordMovement => 'Record movement';

  @override
  String get movementRecorded => 'Recorded! Timer reset';

  @override
  String get permissionRequired => 'Allow notifications in settings';

  @override
  String get workHoursLabel => 'WORK HOURS';

  @override
  String get timeChipStart => 'Start';

  @override
  String get timeChipEnd => 'End';

  @override
  String get settingsLabel => 'SETTINGS';

  @override
  String get settingWorkDays => 'Work days';

  @override
  String get settingDailyGoal => 'Daily goal';

  @override
  String get settingInterval => 'Reminder interval';

  @override
  String get settingNotificationStyle => 'Notification style';

  @override
  String get settingTestNotification => 'Test notification';

  @override
  String get testNotificationSent => 'Test notification sent';

  @override
  String get workDaysMonFri => 'Mon-Fri';

  @override
  String get workDaysMonSat => 'Mon-Sat';

  @override
  String get workDaysMonSun => 'Mon-Sun';

  @override
  String get workDaysMonFriSun => 'Mon-Fri, Sun';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String nMovements(int count) {
    return '$count movements';
  }

  @override
  String nMinutes(int count) {
    return '$count min';
  }

  @override
  String get genderNeutralShort => 'Neutral';

  @override
  String get genderMaleShort => 'Masculine';

  @override
  String get genderFemaleShort => 'Feminine';

  @override
  String get genderNeutralFull => 'Neutral';

  @override
  String get genderMaleFull => 'Masculine';

  @override
  String get genderFemaleFull => 'Feminine';

  @override
  String get genderNeutralExample => 'No movement for X min.';

  @override
  String get genderMaleExample => 'You haven\'t moved for X min.';

  @override
  String get genderFemaleExample => 'You haven\'t moved for X min.';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get statsLoadError => 'Failed to load statistics';

  @override
  String get metricMovements => 'Movements';

  @override
  String get metricSedentary => 'Sedentary';

  @override
  String get metricReaction => 'Reaction';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String get noData => 'No data';

  @override
  String get goalLine => 'goal';

  @override
  String get totalMovements => 'Total movements';

  @override
  String get avgReaction => 'Avg. reaction';

  @override
  String get avgSedentary => 'Avg. sedentary';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days in a row',
      one: 'day in a row',
    );
    return '$_temp0';
  }

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String durationSeconds(int count) {
    return '${count}s';
  }

  @override
  String durationMinutes(int count) {
    return '${count}m';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String get intervalSliderMin => '15 min';

  @override
  String get intervalSliderMax => '2 h';

  @override
  String get notificationTitle => 'Time to stand up! ⏰';

  @override
  String get notificationBody => 'Stretch and walk around 🚶';

  @override
  String get notificationSnooze => 'In 10 minutes';

  @override
  String get notificationAlreadyMoved => 'Already moved';

  @override
  String get settingLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get languageBe => 'Беларуская';
}
