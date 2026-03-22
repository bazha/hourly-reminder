enum NotificationGender { neutral, male, female }

class UserPreferences {
  final bool isEnabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool workOnSaturday;
  final bool workOnSunday;
  final bool workOnMonday;
  final bool workOnTuesday;
  final bool workOnWednesday;
  final bool workOnThursday;
  final bool workOnFriday;
  final NotificationGender notificationGender;
  final int dailyGoal;
  final int reminderIntervalMinutes;

  UserPreferences({
    this.isEnabled = false,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
    this.workOnMonday = true,
    this.workOnTuesday = true,
    this.workOnWednesday = true,
    this.workOnThursday = true,
    this.workOnFriday = true,
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
    bool? workOnMonday,
    bool? workOnTuesday,
    bool? workOnWednesday,
    bool? workOnThursday,
    bool? workOnFriday,
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
      workOnMonday: workOnMonday ?? this.workOnMonday,
      workOnTuesday: workOnTuesday ?? this.workOnTuesday,
      workOnWednesday: workOnWednesday ?? this.workOnWednesday,
      workOnThursday: workOnThursday ?? this.workOnThursday,
      workOnFriday: workOnFriday ?? this.workOnFriday,
      workOnSaturday: workOnSaturday ?? this.workOnSaturday,
      workOnSunday: workOnSunday ?? this.workOnSunday,
      notificationGender: notificationGender ?? this.notificationGender,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
    );
  }

  /// Whether a given weekday is a work day (1=Mon, 7=Sun).
  bool isWorkDay(int weekday) {
    return switch (weekday) {
      1 => workOnMonday,
      2 => workOnTuesday,
      3 => workOnWednesday,
      4 => workOnThursday,
      5 => workOnFriday,
      6 => workOnSaturday,
      7 => workOnSunday,
      _ => false,
    };
  }

  Set<int> get workDaySet => {
    for (int d = 1; d <= 7; d++)
      if (isWorkDay(d)) d,
  };

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
          workOnMonday == other.workOnMonday &&
          workOnTuesday == other.workOnTuesday &&
          workOnWednesday == other.workOnWednesday &&
          workOnThursday == other.workOnThursday &&
          workOnFriday == other.workOnFriday &&
          workOnSaturday == other.workOnSaturday &&
          workOnSunday == other.workOnSunday &&
          notificationGender == other.notificationGender &&
          dailyGoal == other.dailyGoal &&
          reminderIntervalMinutes == other.reminderIntervalMinutes;

  @override
  int get hashCode => Object.hash(
      isEnabled, startHour, startMinute, endHour, endMinute,
      workOnMonday, workOnTuesday, workOnWednesday, workOnThursday,
      workOnFriday, workOnSaturday, workOnSunday,
      notificationGender, dailyGoal, reminderIntervalMinutes);
}
