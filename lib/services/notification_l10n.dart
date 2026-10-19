import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'storage_service.dart';

/// Resolves AppLocalizations for notification text using the app_locale
/// preference. Falls back to system locale, then to Russian.
Future<AppLocalizations> resolveNotificationLocalizations(
    SharedPreferences prefs) async {
  final appLocale = prefs.getString(StorageService.appLocaleKey);
  final locale = appLocale != null
      ? ui.Locale(appLocale)
      : ui.PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales;
  final match = supported.firstWhere(
    (l) => l.languageCode == locale.languageCode,
    orElse: () => const ui.Locale('ru'),
  );
  return AppLocalizations.delegate.load(match);
}
