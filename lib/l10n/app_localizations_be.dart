// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get appTitle => 'Нагадвалка';

  @override
  String get navHome => 'Галоўная';

  @override
  String get navStats => 'Статыстыка';

  @override
  String get toggleOn => 'УКЛ';

  @override
  String get toggleOff => 'ВЫКЛ';

  @override
  String get toggleSemanticsLabel => 'Нагадванні';

  @override
  String get remindersDisabled => 'Нагадванні выключаны';

  @override
  String nextReminderToday(String time) {
    return 'Наступнае ў $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Наступнае заўтра ў $time';
  }

  @override
  String nextReminderOnDay(String dayName, String time) {
    return 'Наступнае ў $dayName ў $time';
  }

  @override
  String get todayLabel => 'СЁННЯ';

  @override
  String goalProgressText(int goal) {
    return 'з $goal разминак';
  }

  @override
  String get recordMovement => 'Запiсаць разминку';

  @override
  String get movementRecorded => 'Запiсана! Таймер скiнуты';

  @override
  String get permissionRequired => 'Дазвольце апавяшчэнні ў наладах';

  @override
  String get workHoursLabel => 'ПРАЦОЎНЫЯ ГАДЗІНЫ';

  @override
  String get timeChipStart => 'Пачатак';

  @override
  String get timeChipEnd => 'Канец';

  @override
  String get settingsLabel => 'НАЛАДЫ';

  @override
  String get settingWorkDays => 'Працоўныя дні';

  @override
  String get settingDailyGoal => 'Мэта на дзень';

  @override
  String get settingInterval => 'Iнтэрвал нагадванняў';

  @override
  String get settingNotificationStyle => 'Стыль апавяшчэнняў';

  @override
  String get settingTestNotification => 'Тэст апавяшчэння';

  @override
  String get testNotificationSent => 'Тэставае апавяшчэнне адпраўлена';

  @override
  String get workDaysMonFri => 'Пн-Пт';

  @override
  String get workDaysMonSat => 'Пн-Сб';

  @override
  String get workDaysMonSun => 'Пн-Нд';

  @override
  String get workDaysMonFriSun => 'Пн-Пт, Нд';

  @override
  String get saturday => 'Субота';

  @override
  String get sunday => 'Нядзеля';

  @override
  String nMovements(int count) {
    return '$count разминак';
  }

  @override
  String nMinutes(int count) {
    return '$count хвiл';
  }

  @override
  String get genderNeutralShort => 'Нейтральны';

  @override
  String get genderMaleShort => 'Мужчынскі';

  @override
  String get genderFemaleShort => 'Жаночы';

  @override
  String get genderNeutralFull => 'Нейтральнае';

  @override
  String get genderMaleFull => 'Мужчынскі род';

  @override
  String get genderFemaleFull => 'Жаночы род';

  @override
  String get genderNeutralExample => 'Без руху X хвіл.';

  @override
  String get genderMaleExample => 'Ты не рухаўся X хвіл.';

  @override
  String get genderFemaleExample => 'Ты не рухалася X хвіл.';

  @override
  String get done => 'Гатова';

  @override
  String get retry => 'Паўтарыць';

  @override
  String get statsLoadError => 'Не атрымалася загрузiць статыстыку';

  @override
  String get metricMovements => 'Разминак';

  @override
  String get metricSedentary => 'Час сядзення';

  @override
  String get metricReaction => 'Рэакцыя';

  @override
  String get thisWeek => 'ГЭТЫ ТЫДЗЕНЬ';

  @override
  String get noData => 'Няма даных';

  @override
  String get goalLine => 'мэта';

  @override
  String get totalMovements => 'Усяго разминак';

  @override
  String get avgReaction => 'Ср. рэакцыя';

  @override
  String get avgSedentary => 'Ср. час сядзення';

  @override
  String get currentStreak => 'Бягучая серыя';

  @override
  String get bestStreak => 'Лепшая серыя';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дзён запар',
      many: 'дзён запар',
      few: 'дні запар',
      one: 'дзень запар',
    );
    return '$_temp0';
  }

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Аў';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чц';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Нд';

  @override
  String durationSeconds(int count) {
    return '$countс';
  }

  @override
  String durationMinutes(int count) {
    return '$countхв';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursг $minutesхв';
  }

  @override
  String durationHours(int hours) {
    return '$hoursг';
  }

  @override
  String get intervalSliderMin => '15 хвiл';

  @override
  String get intervalSliderMax => '2 г';

  @override
  String get notificationTitle => 'Час устаць! ⏰';

  @override
  String get notificationBody => 'Пара размяцца і пахадзiць 🚶';

  @override
  String get notificationSnooze => 'Праз 10 хвілін';

  @override
  String get notificationAlreadyMoved => 'Ужо рухаўся';

  @override
  String get settingLanguage => 'Мова';

  @override
  String get languageSystem => 'Сістэмная';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get languageBe => 'Беларуская';
}
