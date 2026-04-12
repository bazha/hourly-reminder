import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('be'),
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминалка'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @toggleOn.
  ///
  /// In ru, this message translates to:
  /// **'ВКЛ'**
  String get toggleOn;

  /// No description provided for @toggleOff.
  ///
  /// In ru, this message translates to:
  /// **'ВЫКЛ'**
  String get toggleOff;

  /// No description provided for @toggleSemanticsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get toggleSemanticsLabel;

  /// No description provided for @remindersDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания выключены'**
  String get remindersDisabled;

  /// No description provided for @nextReminderToday.
  ///
  /// In ru, this message translates to:
  /// **'Следующее в {time}'**
  String nextReminderToday(String time);

  /// No description provided for @nextReminderTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Следующее завтра в {time}'**
  String nextReminderTomorrow(String time);

  /// No description provided for @nextReminderOnDay.
  ///
  /// In ru, this message translates to:
  /// **'Следующее в {dayName} в {time}'**
  String nextReminderOnDay(String dayName, String time);

  /// No description provided for @todayLabel.
  ///
  /// In ru, this message translates to:
  /// **'СЕГОДНЯ'**
  String get todayLabel;

  /// No description provided for @goalZeroMotivation.
  ///
  /// In ru, this message translates to:
  /// **'Самое время начать!'**
  String get goalZeroMotivation;

  /// No description provided for @goalProgressText.
  ///
  /// In ru, this message translates to:
  /// **'из {goal} разминок'**
  String goalProgressText(int goal);

  /// No description provided for @recordMovement.
  ///
  /// In ru, this message translates to:
  /// **'Записать разминку'**
  String get recordMovement;

  /// No description provided for @movementRecorded.
  ///
  /// In ru, this message translates to:
  /// **'Записано! Таймер сброшен'**
  String get movementRecorded;

  /// No description provided for @permissionRequired.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите уведомления в настройках'**
  String get permissionRequired;

  /// No description provided for @workHoursLabel.
  ///
  /// In ru, this message translates to:
  /// **'РАБОЧИЕ ЧАСЫ'**
  String get workHoursLabel;

  /// No description provided for @timeChipStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get timeChipStart;

  /// No description provided for @timeChipEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конец'**
  String get timeChipEnd;

  /// No description provided for @settingWorkDays.
  ///
  /// In ru, this message translates to:
  /// **'Рабочие дни'**
  String get settingWorkDays;

  /// No description provided for @settingDailyGoal.
  ///
  /// In ru, this message translates to:
  /// **'Дневная цель'**
  String get settingDailyGoal;

  /// No description provided for @settingInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал напоминаний'**
  String get settingInterval;

  /// No description provided for @settingNotificationStyle.
  ///
  /// In ru, this message translates to:
  /// **'Стиль уведомлений'**
  String get settingNotificationStyle;

  /// No description provided for @settingTestNotification.
  ///
  /// In ru, this message translates to:
  /// **'Тест уведомления'**
  String get settingTestNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In ru, this message translates to:
  /// **'Тестовое уведомление отправлено'**
  String get testNotificationSent;

  /// No description provided for @monday.
  ///
  /// In ru, this message translates to:
  /// **'Понедельник'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вторник'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ru, this message translates to:
  /// **'Среда'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ru, this message translates to:
  /// **'Четверг'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ru, this message translates to:
  /// **'Пятница'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ru, this message translates to:
  /// **'Суббота'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get sunday;

  /// No description provided for @nMovements.
  ///
  /// In ru, this message translates to:
  /// **'{count} разминок'**
  String nMovements(int count);

  /// No description provided for @nMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин'**
  String nMinutes(int count);

  /// No description provided for @genderNeutralShort.
  ///
  /// In ru, this message translates to:
  /// **'Нейтральный'**
  String get genderNeutralShort;

  /// No description provided for @genderMaleShort.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get genderMaleShort;

  /// No description provided for @genderFemaleShort.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get genderFemaleShort;

  /// No description provided for @genderNeutralFull.
  ///
  /// In ru, this message translates to:
  /// **'Нейтральное'**
  String get genderNeutralFull;

  /// No description provided for @genderMaleFull.
  ///
  /// In ru, this message translates to:
  /// **'Мужской род'**
  String get genderMaleFull;

  /// No description provided for @genderFemaleFull.
  ///
  /// In ru, this message translates to:
  /// **'Женский род'**
  String get genderFemaleFull;

  /// No description provided for @genderNeutralExample.
  ///
  /// In ru, this message translates to:
  /// **'Без движения X мин.'**
  String get genderNeutralExample;

  /// No description provided for @genderMaleExample.
  ///
  /// In ru, this message translates to:
  /// **'Ты не двигался X мин.'**
  String get genderMaleExample;

  /// No description provided for @genderFemaleExample.
  ///
  /// In ru, this message translates to:
  /// **'Ты не двигалась X мин.'**
  String get genderFemaleExample;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @statsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить статистику'**
  String get statsLoadError;

  /// No description provided for @metricMovements.
  ///
  /// In ru, this message translates to:
  /// **'Разминок'**
  String get metricMovements;

  /// No description provided for @metricSedentary.
  ///
  /// In ru, this message translates to:
  /// **'Время сидя'**
  String get metricSedentary;

  /// No description provided for @metricReaction.
  ///
  /// In ru, this message translates to:
  /// **'Реакция'**
  String get metricReaction;

  /// No description provided for @thisWeek.
  ///
  /// In ru, this message translates to:
  /// **'ЭТА НЕДЕЛЯ'**
  String get thisWeek;

  /// No description provided for @noData.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных'**
  String get noData;

  /// No description provided for @goalLine.
  ///
  /// In ru, this message translates to:
  /// **'цель'**
  String get goalLine;

  /// No description provided for @totalMovements.
  ///
  /// In ru, this message translates to:
  /// **'Всего разминок'**
  String get totalMovements;

  /// No description provided for @avgReaction.
  ///
  /// In ru, this message translates to:
  /// **'Ср. реакция'**
  String get avgReaction;

  /// No description provided for @avgSedentary.
  ///
  /// In ru, this message translates to:
  /// **'Ср. время сидя'**
  String get avgSedentary;

  /// No description provided for @currentStreak.
  ///
  /// In ru, this message translates to:
  /// **'Текущая серия'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая серия'**
  String get bestStreak;

  /// No description provided for @streakDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{день подряд} few{дня подряд} many{дней подряд} other{дней подряд}}'**
  String streakDays(int count);

  /// No description provided for @dayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get daySun;

  /// No description provided for @durationSeconds.
  ///
  /// In ru, this message translates to:
  /// **'{count}с'**
  String durationSeconds(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count}м'**
  String durationMinutes(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{hours}ч {minutes}м'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationHours.
  ///
  /// In ru, this message translates to:
  /// **'{hours}ч'**
  String durationHours(int hours);

  /// No description provided for @intervalSliderMin.
  ///
  /// In ru, this message translates to:
  /// **'15 мин'**
  String get intervalSliderMin;

  /// No description provided for @intervalSliderMax.
  ///
  /// In ru, this message translates to:
  /// **'2 ч'**
  String get intervalSliderMax;

  /// No description provided for @notificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время встать! ⏰'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In ru, this message translates to:
  /// **'Пора размяться и походить 🚶'**
  String get notificationBody;

  /// No description provided for @notificationSnooze.
  ///
  /// In ru, this message translates to:
  /// **'Через 10 минут'**
  String get notificationSnooze;

  /// No description provided for @notificationAlreadyMoved.
  ///
  /// In ru, this message translates to:
  /// **'Я уже двигался'**
  String get notificationAlreadyMoved;

  /// No description provided for @dayOffButton.
  ///
  /// In ru, this message translates to:
  /// **'Выходной сегодня'**
  String get dayOffButton;

  /// No description provided for @dayOffActive.
  ///
  /// In ru, this message translates to:
  /// **'Выходной включён'**
  String get dayOffActive;

  /// No description provided for @dayOffBanner.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня выходной, уведомлений не будет'**
  String get dayOffBanner;

  /// No description provided for @sectionSchedule.
  ///
  /// In ru, this message translates to:
  /// **'РАСПИСАНИЕ'**
  String get sectionSchedule;

  /// No description provided for @sectionNotifications.
  ///
  /// In ru, this message translates to:
  /// **'УВЕДОМЛЕНИЯ'**
  String get sectionNotifications;

  /// No description provided for @sectionGeneral.
  ///
  /// In ru, this message translates to:
  /// **'ОБЩЕЕ'**
  String get sectionGeneral;

  /// No description provided for @sectionAbout.
  ///
  /// In ru, this message translates to:
  /// **'О ПРИЛОЖЕНИИ'**
  String get sectionAbout;

  /// No description provided for @settingWorkHours.
  ///
  /// In ru, this message translates to:
  /// **'Рабочие часы'**
  String get settingWorkHours;

  /// No description provided for @settingTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get aboutVersion;

  /// No description provided for @aboutRateApp.
  ///
  /// In ru, this message translates to:
  /// **'Оценить приложение'**
  String get aboutRateApp;

  /// No description provided for @aboutFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get aboutFeedback;

  /// No description provided for @feedbackNoEmail.
  ///
  /// In ru, this message translates to:
  /// **'Почтовое приложение не найдено'**
  String get feedbackNoEmail;

  /// No description provided for @rateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оцените приложение'**
  String get rateTitle;

  /// No description provided for @rateMessage.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите на звезду'**
  String get rateMessage;

  /// No description provided for @rateThanks.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо за оценку!'**
  String get rateThanks;

  /// No description provided for @rateSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get rateSend;

  /// No description provided for @rateCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get rateCancel;

  /// No description provided for @activityLabel.
  ///
  /// In ru, this message translates to:
  /// **'активность'**
  String get activityLabel;

  /// No description provided for @motivationalMessage.
  ///
  /// In ru, this message translates to:
  /// **'Ваше тело скажет спасибо.'**
  String get motivationalMessage;

  /// No description provided for @settingLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системный'**
  String get languageSystem;

  /// No description provided for @languageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageBe.
  ///
  /// In ru, this message translates to:
  /// **'Беларуская'**
  String get languageBe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['be', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
