import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/time_utils.dart';

class ReminderToggleCard extends StatelessWidget {
  const ReminderToggleCard({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Напоминания',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnabled ? 'Включены' : 'Выключены',
                  style: AppTypography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeTrackColor: AppColors.startColor,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.prefs,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final UserPreferences prefs;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Расписание',
              style: AppTypography.cardTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Начало рабочего дня',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: prefs.startTime,
                    min: 0,
                    max: 23.5,
                    divisions: 47,
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
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Конец рабочего дня',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
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
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionsCard extends StatelessWidget {
  const OptionsCard({
    super.key,
    required this.prefs,
    required this.onToggleSaturday,
    required this.onToggleSunday,
    required this.onGenderChanged,
    required this.onGoalChanged,
  });

  final UserPreferences prefs;
  final ValueChanged<bool> onToggleSaturday;
  final ValueChanged<bool> onToggleSunday;
  final ValueChanged<NotificationGender> onGenderChanged;
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки',
              style: AppTypography.cardTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeekendRow('Суббота', prefs.workOnSaturday, onToggleSaturday, colors),
            const SizedBox(height: 4),
            _buildWeekendRow('Воскресенье', prefs.workOnSunday, onToggleSunday, colors),
            Divider(height: 24, color: colors.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Цель на день',
                  style: AppTypography.body.copyWith(color: colors.textSecondary),
                ),
                Text(
                  '${prefs.dailyGoal} разминок',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider(
              value: prefs.dailyGoal.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              label: '${prefs.dailyGoal}',
              onChanged: (v) => onGoalChanged(v.round()),
              activeColor: AppColors.primary,
              inactiveColor: colors.sliderInactiveTrack,
            ),
            Divider(height: 24, color: colors.divider),
            Text(
              'Обращение в уведомлениях',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            RadioGroup<NotificationGender>(
              groupValue: prefs.notificationGender,
              onChanged: (value) { if (value != null) onGenderChanged(value); },
              child: Column(
                children: NotificationGender.values.map((gender) {
                  final label = switch (gender) {
                    NotificationGender.neutral => 'Нейтральное  -  Без движения X мин.',
                    NotificationGender.male    => 'Мужской род  -  Ты не двигался X мин.',
                    NotificationGender.female  => 'Женский род  -  Ты не двигалась X мин.',
                  };
                  return RadioListTile<NotificationGender>(
                    value: gender,
                    toggleable: false,
                    title: Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekendRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    AppColors colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: colors.weekendSwitchActive,
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }
}
