import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/movement_stats/domain/repositories/movement_stats_repository.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import '../features/movement_stats/presentation/stats_screen.dart';

class MainShell extends StatefulWidget {
  final StorageService storageService;
  final AlarmService alarmService;
  final MovementStatsRepository statsRepository;

  const MainShell({
    super.key,
    required this.storageService,
    required this.alarmService,
    required this.statsRepository,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

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
          ),
          StatsScreen(repository: widget.statsRepository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: colors.navBarBg,
        indicatorColor: colors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: colors.navBarUnselected),
            selectedIcon: Icon(Icons.home_rounded, color: colors.navBarSelected),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: colors.navBarUnselected),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: colors.navBarSelected),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}
