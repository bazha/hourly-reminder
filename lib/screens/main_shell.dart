import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../features/movement/domain/repositories/movement_repository.dart';
import '../features/movement_stats/domain/repositories/movement_stats_repository.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../features/movement_stats/presentation/stats_screen.dart';

class MainShell extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;
  final MovementRepository movementRepository;

  const MainShell({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
    required this.movementRepository,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _navigationChannel =
      MethodChannel('com.bazhanau.hourly_reminder/navigation');

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialTab();
    _listenForNavigationEvents();
    NotificationService.tabNotifier.addListener(_onTabNotification);
  }

  @override
  void dispose() {
    NotificationService.tabNotifier.removeListener(_onTabNotification);
    super.dispose();
  }

  /// Cold start: check if launched from a notification tap.
  Future<void> _checkInitialTab() async {
    try {
      final tab =
          await _navigationChannel.invokeMethod<int>('getAndClearInitialTab');
      if (tab != null && tab != 0 && mounted) {
        setState(() => _currentIndex = tab);
      }
    } on MissingPluginException {
      // iOS or platform without the native channel - ignore
    }
  }

  /// Warm start: listen for Android method channel calls when
  /// the app is already running and a notification is tapped.
  void _listenForNavigationEvents() {
    _navigationChannel.setMethodCallHandler((call) async {
      if (call.method == 'navigateToTab' && mounted) {
        final tab = call.arguments as int;
        setState(() => _currentIndex = tab);
      }
    });
  }

  /// iOS: notification body tap fires the ValueNotifier.
  void _onTabNotification() {
    if (mounted) {
      setState(() => _currentIndex = NotificationService.tabNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            storageService: widget.storageService,
            alarmService: widget.alarmService,
            statsRepository: widget.statsRepository,
            movementRepository: widget.movementRepository,
            isActive: _currentIndex == 0,
          ),
          StatsScreen(
            repository: widget.statsRepository,
            isActive: _currentIndex == 1,
          ),
          SettingsScreen(
            storageService: widget.storageService,
            alarmService: widget.alarmService,
            isActive: _currentIndex == 2,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: colors.navBarBg,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: colors.navBarUnselected),
              selectedIcon:
                  Icon(Icons.home_rounded, color: colors.navBarSelected),
              label: AppLocalizations.of(context)!.navHome,
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined,
                  color: colors.navBarUnselected),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: colors.navBarSelected),
              label: AppLocalizations.of(context)!.navStats,
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.settings_outlined, color: colors.navBarUnselected),
              selectedIcon:
                  Icon(Icons.settings_rounded, color: colors.navBarSelected),
              label: AppLocalizations.of(context)!.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
