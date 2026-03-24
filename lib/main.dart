import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_colors.dart';
import 'l10n/app_localizations.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/main_shell.dart';
import 'features/movement/data/datasources/movement_local_datasource.dart';
import 'features/movement/data/repositories/movement_repository_impl.dart';
import 'features/movement/domain/repositories/movement_repository.dart';
import 'features/movement_stats/data/repositories/movement_stats_repository_impl.dart';
import 'features/movement_stats/domain/repositories/movement_stats_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final alarmService = AlarmService();

  // Initialize sedentary start time on first launch.
  final datasource = MovementLocalDatasource(prefs);
  if (datasource.getSedentaryStartTime() == null) {
    await datasource.setSedentaryStartTime(DateTime.now());
  }

  final movementRepository = MovementRepositoryImpl(datasource);
  final statsRepository = MovementStatsRepositoryImpl(
    movementRepository: movementRepository,
    storageService: storageService,
  );

  runApp(HourlyReminderApp(
    storageService: storageService,
    alarmService: alarmService,
    statsRepository: statsRepository,
    movementRepository: movementRepository,
  ));
}

class HourlyReminderApp extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;
  final MovementRepository movementRepository;

  const HourlyReminderApp({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
    required this.movementRepository,
  });

  static void setLocale(BuildContext context, Locale? locale) {
    final state = context.findAncestorStateOfType<_HourlyReminderAppState>();
    state?._setLocale(locale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_HourlyReminderAppState>();
    state?._setThemeMode(mode);
  }

  static ThemeMode getThemeMode(BuildContext context) {
    final state = context.findAncestorStateOfType<_HourlyReminderAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }

  @override
  State<HourlyReminderApp> createState() => _HourlyReminderAppState();
}

class _HourlyReminderAppState extends State<HourlyReminderApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final code = prefs.getString('app_locale');
    final theme = prefs.getString('app_theme_mode');
    setState(() {
      if (code != null) _locale = Locale(code);
      _themeMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    });
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    SharedPreferences.getInstance().then((prefs) {
      if (locale == null) {
        prefs.remove('app_locale');
      } else {
        prefs.setString('app_locale', locale.languageCode);
      }
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    SharedPreferences.getInstance().then((prefs) {
      if (mode == ThemeMode.system) {
        prefs.remove('app_theme_mode');
      } else {
        prefs.setString('app_theme_mode', mode.name);
      }
    });
  }

  static ThemeData _buildTheme(Brightness brightness, AppColors colors) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      useMaterial3: true,
      extensions: [colors],
      scaffoldBackgroundColor: colors.bg,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.cardBorder),
        ),
        color: colors.cardBg,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colors.switchInactiveThumb;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return colors.switchInactiveTrack;
        }),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: colors.sliderThumb,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.navBarBg,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.navBarSelected,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colors.navBarUnselected,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly Reminder',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light, AppColors.light),
      darkTheme: _buildTheme(Brightness.dark, AppColors.dark),
      home: MainShell(
        storageService: widget.storageService,
        alarmService: widget.alarmService,
        statsRepository: widget.statsRepository,
        movementRepository: widget.movementRepository,
      ),
    );
  }
}
