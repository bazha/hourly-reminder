import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/user_preferences.dart';
import '../widgets/work_hours_clock.dart';
import '../core/utils/time_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserPreferences _prefs = UserPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await StorageService.loadPreferences();
    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminders(bool value) async {
    if (value) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешите уведомления в настройках')),
          );
        }
        return;
      }
      await AlarmService.scheduleHourlyAlarm();
    } else {
      await AlarmService.cancelAlarm();
    }

    setState(() {
      _prefs = _prefs.copyWith(isEnabled: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  // Обновить время начала (в формате double: 9.5 = 9:30)
  Future<void> _updateStartTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(startHour: hour, startMinute: minute);
    });
    await StorageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await AlarmService.scheduleHourlyAlarm();
    }
  }

  // Обновить время окончания
  Future<void> _updateEndTime(double time) async {
    final hour = time.floor();
    final minute = ((time - hour) * 60).round();

    setState(() {
      _prefs = _prefs.copyWith(endHour: hour, endMinute: minute);
    });
    await StorageService.savePreferences(_prefs);
    if (_prefs.isEnabled) {
      await AlarmService.scheduleHourlyAlarm();
    }
  }

  Future<void> _toggleSaturday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSaturday: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  Future<void> _toggleSunday(bool value) async {
    setState(() {
      _prefs = _prefs.copyWith(workOnSunday: value);
    });
    await StorageService.savePreferences(_prefs);
  }

  Future<void> _updateGender(NotificationGender gender) async {
    setState(() {
      _prefs = _prefs.copyWith(notificationGender: gender);
    });
    await StorageService.savePreferences(_prefs);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Напоминалка',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.appBarFg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: colors.cardBg,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Рабочее время',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    WorkHoursClock(
                      startTime: _prefs.startTime,
                      endTime: _prefs.endTime,
                      size: 250,
                      onStartTimeChanged: (time) => _updateStartTime(time),
                      onEndTimeChanged: (time) => _updateEndTime(time),
                    ),

                    const SizedBox(height: 24),

                    // Легенда
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.startColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Начало: ${TimeUtils.formatHourMinute(_prefs.startHour, _prefs.startMinute)}',
                          style: const TextStyle(
                            color: AppColors.startColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.endColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Конец: ${TimeUtils.formatHourMinute(_prefs.endHour, _prefs.endMinute)}',
                          style: const TextStyle(
                            color: AppColors.endColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========== НАСТРОЙКИ ==========

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: colors.cardBg,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Переключатель напоминаний
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Напоминания',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              _prefs.isEnabled ? 'Включены' : 'Выключены',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _prefs.isEnabled,
                          onChanged: _toggleReminders,
                          activeColor: AppColors.startColor,
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    // Слайдер начала (с шагом 0.5)
                    Text(
                      'Начало рабочего дня',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _prefs.startTime,
                            min: 0,
                            max: 23.5,
                            divisions: 47, // 24 часа * 2 - 1
                            label: TimeUtils.formatHourMinute(_prefs.startHour, _prefs.startMinute),
                            onChanged: (value) => _updateStartTime(value),
                            activeColor: AppColors.startColor,
                            inactiveColor: colors.startSliderInactive,
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          child: Text(
                            TimeUtils.formatHourMinute(_prefs.startHour, _prefs.startMinute),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Слайдер окончания (с шагом 0.5)
                    Text(
                      'Конец рабочего дня',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _prefs.endTime,
                            min: 0,
                            max: 23.5,
                            divisions: 47,
                            label: TimeUtils.formatHourMinute(_prefs.endHour, _prefs.endMinute),
                            onChanged: (value) => _updateEndTime(value),
                            activeColor: AppColors.endColor,
                            inactiveColor: colors.endSliderInactive,
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          child: Text(
                            TimeUtils.formatHourMinute(_prefs.endHour, _prefs.endMinute),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    // Суббота
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Суббота',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        Switch(
                          value: _prefs.workOnSaturday,
                          onChanged: _toggleSaturday,
                          activeColor: colors.weekendSwitchActive,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Воскресенье
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Воскресенье',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        Switch(
                          value: _prefs.workOnSunday,
                          onChanged: _toggleSunday,
                          activeColor: colors.weekendSwitchActive,
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    Text(
                      'Обращение в уведомлениях',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...NotificationGender.values.map((gender) {
                      final label = switch (gender) {
                        NotificationGender.neutral => 'Нейтральное  -  Без движения X мин.',
                        NotificationGender.male    => 'Мужской род  -  Ты не двигался X мин.',
                        NotificationGender.female  => 'Женский род  -  Ты не двигалась X мин.',
                      };
                      return RadioListTile<NotificationGender>(
                        value: gender,
                        groupValue: _prefs.notificationGender,
                        onChanged: (value) => _updateGender(value!),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка теста
            ElevatedButton.icon(
              onPressed: () async {
                await NotificationService.showHourlyNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Тестовое уведомление отправлено'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.startColor,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_outlined, size: 20),
              label: const Text('Тест уведомления'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.appBarBg,
                foregroundColor: colors.appBarFg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
