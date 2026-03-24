// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Напоминалка';

  @override
  String get navHome => 'Главная';

  @override
  String get navStats => 'Статистика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get toggleOn => 'ВКЛ';

  @override
  String get toggleOff => 'ВЫКЛ';

  @override
  String get toggleSemanticsLabel => 'Напоминания';

  @override
  String get remindersDisabled => 'Напоминания выключены';

  @override
  String nextReminderToday(String time) {
    return 'Следующее в $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Следующее завтра в $time';
  }

  @override
  String nextReminderOnDay(String dayName, String time) {
    return 'Следующее в $dayName в $time';
  }

  @override
  String get todayLabel => 'СЕГОДНЯ';

  @override
  String get goalZeroMotivation => 'Самое время начать!';

  @override
  String goalProgressText(int goal) {
    return 'из $goal разминок';
  }

  @override
  String get recordMovement => 'Записать разминку';

  @override
  String get movementRecorded => 'Записано! Таймер сброшен';

  @override
  String get permissionRequired => 'Разрешите уведомления в настройках';

  @override
  String get workHoursLabel => 'РАБОЧИЕ ЧАСЫ';

  @override
  String get timeChipStart => 'Начало';

  @override
  String get timeChipEnd => 'Конец';

  @override
  String get settingsLabel => 'НАСТРОЙКИ';

  @override
  String get settingWorkDays => 'Рабочие дни';

  @override
  String get settingDailyGoal => 'Дневная цель';

  @override
  String get settingInterval => 'Интервал напоминаний';

  @override
  String get settingNotificationStyle => 'Стиль уведомлений';

  @override
  String get settingTestNotification => 'Тест уведомления';

  @override
  String get testNotificationSent => 'Тестовое уведомление отправлено';

  @override
  String get workDaysMonFri => 'Пн-Пт';

  @override
  String get workDaysMonSat => 'Пн-Сб';

  @override
  String get workDaysMonSun => 'Пн-Вс';

  @override
  String get workDaysMonFriSun => 'Пн-Пт, Вс';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String nMovements(int count) {
    return '$count разминок';
  }

  @override
  String nMinutes(int count) {
    return '$count мин';
  }

  @override
  String get genderNeutralShort => 'Нейтральный';

  @override
  String get genderMaleShort => 'Мужской';

  @override
  String get genderFemaleShort => 'Женский';

  @override
  String get genderNeutralFull => 'Нейтральное';

  @override
  String get genderMaleFull => 'Мужской род';

  @override
  String get genderFemaleFull => 'Женский род';

  @override
  String get genderNeutralExample => 'Без движения X мин.';

  @override
  String get genderMaleExample => 'Ты не двигался X мин.';

  @override
  String get genderFemaleExample => 'Ты не двигалась X мин.';

  @override
  String get done => 'Готово';

  @override
  String get retry => 'Повторить';

  @override
  String get statsLoadError => 'Не удалось загрузить статистику';

  @override
  String get metricMovements => 'Разминок';

  @override
  String get metricSedentary => 'Время сидя';

  @override
  String get metricReaction => 'Реакция';

  @override
  String get thisWeek => 'ЭТА НЕДЕЛЯ';

  @override
  String get noData => 'Нет данных';

  @override
  String get goalLine => 'цель';

  @override
  String get totalMovements => 'Всего разминок';

  @override
  String get avgReaction => 'Ср. реакция';

  @override
  String get avgSedentary => 'Ср. время сидя';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get bestStreak => 'Лучшая серия';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дней подряд',
      many: 'дней подряд',
      few: 'дня подряд',
      one: 'день подряд',
    );
    return '$_temp0';
  }

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Вс';

  @override
  String durationSeconds(int count) {
    return '$countс';
  }

  @override
  String durationMinutes(int count) {
    return '$countм';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String durationHours(int hours) {
    return '$hoursч';
  }

  @override
  String get intervalSliderMin => '15 мин';

  @override
  String get intervalSliderMax => '2 ч';

  @override
  String get notificationTitle => 'Время встать! ⏰';

  @override
  String get notificationBody => 'Пора размяться и походить 🚶';

  @override
  String get notificationSnooze => 'Через 10 минут';

  @override
  String get notificationAlreadyMoved => 'Я уже двигался';

  @override
  String get dayOffButton => 'Выходной сегодня';

  @override
  String get dayOffActive => 'Выходной включён';

  @override
  String get dayOffBanner => 'Сегодня выходной, уведомлений не будет';

  @override
  String get sectionSchedule => 'РАСПИСАНИЕ';

  @override
  String get sectionNotifications => 'УВЕДОМЛЕНИЯ';

  @override
  String get sectionGeneral => 'ОБЩЕЕ';

  @override
  String get sectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get settingWorkHours => 'Рабочие часы';

  @override
  String get settingTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutRateApp => 'Оценить приложение';

  @override
  String get aboutFeedback => 'Обратная связь';

  @override
  String get feedbackNoEmail => 'Почтовое приложение не найдено';

  @override
  String get rateTitle => 'Оцените приложение';

  @override
  String get rateMessage => 'Нажмите на звезду';

  @override
  String get rateThanks => 'Спасибо за оценку!';

  @override
  String get rateSend => 'Отправить';

  @override
  String get rateCancel => 'Отмена';

  @override
  String get settingLanguage => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get languageBe => 'Беларуская';
}
