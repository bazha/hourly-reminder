class UserPreferences {
  final bool isEnabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool workOnSaturday;
  final bool workOnSunday;

  UserPreferences({
    this.isEnabled = false,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
    this.workOnSaturday = false,
    this.workOnSunday = false,
  });

  UserPreferences copyWith({
    bool? isEnabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? workOnSaturday,
    bool? workOnSunday,
  }) {
    return UserPreferences(
      isEnabled:       isEnabled       ?? this.isEnabled,
      startHour:       startHour       ?? this.startHour,
      startMinute:     startMinute     ?? this.startMinute,
      endHour:         endHour         ?? this.endHour,
      endMinute:       endMinute       ?? this.endMinute,
      workOnSaturday:  workOnSaturday  ?? this.workOnSaturday,
      workOnSunday:    workOnSunday    ?? this.workOnSunday,
    );
  }

  double get startTime => startHour + (startMinute / 60.0);
  double get endTime   => endHour   + (endMinute   / 60.0);

  int get startTotalMinutes => startHour * 60 + startMinute;
  int get endTotalMinutes   => endHour   * 60 + endMinute;

  /// Number of hourly notifications that fire in one work day.
  int get dailyNotificationCount {
    if (endTotalMinutes < startTotalMinutes) return 0;
    return ((endTotalMinutes - startTotalMinutes) / 60).floor() + 1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          isEnabled       == other.isEnabled &&
          startHour       == other.startHour &&
          startMinute     == other.startMinute &&
          endHour         == other.endHour &&
          endMinute       == other.endMinute &&
          workOnSaturday  == other.workOnSaturday &&
          workOnSunday    == other.workOnSunday;

  @override
  int get hashCode => Object.hash(
      isEnabled, startHour, startMinute, endHour, endMinute,
      workOnSaturday, workOnSunday);
}
