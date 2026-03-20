enum NotificationGender { neutral, male, female }

class UserPreferences {
  final bool isEnabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool workOnSaturday;
  final bool workOnSunday;
  final NotificationGender notificationGender;
  final int dailyGoal;
  final int reminderIntervalMinutes;

  UserPreferences({
    this.isEnabled = false,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
    this.workOnSaturday = false,
    this.workOnSunday = false,
    this.notificationGender = NotificationGender.neutral,
    this.dailyGoal = 8,
    this.reminderIntervalMinutes = 60,
  });

  UserPreferences copyWith({
    bool? isEnabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? workOnSaturday,
    bool? workOnSunday,
    NotificationGender? notificationGender,
    int? dailyGoal,
    int? reminderIntervalMinutes,
  }) {
    return UserPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      workOnSaturday: workOnSaturday ?? this.workOnSaturday,
      workOnSunday: workOnSunday ?? this.workOnSunday,
      notificationGender: notificationGender ?? this.notificationGender,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
    );
  }

  double get startTime => startHour + (startMinute / 60.0);
  double get endTime => endHour + (endMinute / 60.0);

  int get startTotalMinutes => startHour * 60 + startMinute;
  int get endTotalMinutes => endHour * 60 + endMinute;

  /// Number of notifications that fire in one work day based on the interval.
  int get dailyNotificationCount {
    if (endTotalMinutes < startTotalMinutes) return 0;
    return ((endTotalMinutes - startTotalMinutes) / reminderIntervalMinutes)
            .floor() +
        1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          isEnabled == other.isEnabled &&
          startHour == other.startHour &&
          startMinute == other.startMinute &&
          endHour == other.endHour &&
          endMinute == other.endMinute &&
          workOnSaturday == other.workOnSaturday &&
          workOnSunday == other.workOnSunday &&
          notificationGender == other.notificationGender &&
          dailyGoal == other.dailyGoal &&
          reminderIntervalMinutes == other.reminderIntervalMinutes;

  @override
  int get hashCode => Object.hash(
      isEnabled,
      startHour,
      startMinute,
      endHour,
      endMinute,
      workOnSaturday,
      workOnSunday,
      notificationGender,
      dailyGoal,
      reminderIntervalMinutes);
}
