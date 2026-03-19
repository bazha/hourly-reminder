import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/time_utils.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.prefs,
    required this.onToggleReminders,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onToggleSaturday,
    required this.onToggleSunday,
    required this.onGenderChanged,
  });

  final UserPreferences prefs;
  final ValueChanged<bool> onToggleReminders;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;
  final ValueChanged<bool> onToggleSaturday;
  final ValueChanged<bool> onToggleSunday;
  final ValueChanged<NotificationGender> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRemindersToggle(colors),
            const Divider(height: 30),
            _buildTimeSliders(colors),
            const Divider(height: 30),
            _buildWeekendToggles(colors),
            const Divider(height: 30),
            _buildGenderSection(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersToggle(AppColors colors) {
    return Row(
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
              prefs.isEnabled ? 'Включены' : 'Выключены',
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        Switch(
          value: prefs.isEnabled,
          onChanged: onToggleReminders,
          activeColor: AppColors.startColor,
        ),
      ],
    );
  }

  Widget _buildTimeSliders(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                value: prefs.startTime,
                min: 0,
                max: 23.5,
                divisions: 47, // 24 часа * 2 - 1
                label: TimeUtils.formatHourMinute(prefs.startHour, prefs.startMinute),
                onChanged: onStartChanged,
                activeColor: AppColors.startColor,
                inactiveColor: colors.startSliderInactive,
              ),
            ),
            SizedBox(
              width: 65,
              child: Text(
                TimeUtils.formatHourMinute(prefs.startHour, prefs.startMinute),
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
                value: prefs.endTime,
                min: 0,
                max: 23.5,
                divisions: 47,
                label: TimeUtils.formatHourMinute(prefs.endHour, prefs.endMinute),
                onChanged: onEndChanged,
                activeColor: AppColors.endColor,
                inactiveColor: colors.endSliderInactive,
              ),
            ),
            SizedBox(
              width: 65,
              child: Text(
                TimeUtils.formatHourMinute(prefs.endHour, prefs.endMinute),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekendToggles(AppColors colors) {
    return Column(
      children: [
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
              value: prefs.workOnSaturday,
              onChanged: onToggleSaturday,
              activeColor: colors.weekendSwitchActive,
            ),
          ],
        ),
        const SizedBox(height: 4),
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
              value: prefs.workOnSunday,
              onChanged: onToggleSunday,
              activeColor: colors.weekendSwitchActive,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSection(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            groupValue: prefs.notificationGender,
            onChanged: (value) => onGenderChanged(value!),
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
    );
  }
}
