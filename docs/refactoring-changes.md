# Refactoring Changes

| File | What changed |
|---|---|
| `lib/models/user_preferences.dart` | Fixed `copyWith` to forward `startMinute`/`endMinute`; added `==`/`hashCode`; added `startTotalMinutes`, `endTotalMinutes`, `dailyNotificationCount` getters; fixed off-by-one in `dailyNotificationCount` (`<` not `<=`) |
| `lib/services/storage_service.dart` | Added `_initialized` flag + `isInitialized` getter; added `startMinute`/`endMinute` sync getters |
| `lib/services/alarm_service.dart` | Extracted `shouldSendReminder()` pure static method; added `nextNotificationTime()`; refactored `alarmCallback` to call `shouldSendReminder`; upgraded minute-precision window check; fixed midnight rollover bug in `_getNextHourStart` (Duration arithmetic instead of `hour+1`); renamed `_alarmId` → `alarmId` (public) |
| `lib/screens/home_screen.dart` | Imported `TimeUtils`; replaced 6 inline formatting expressions with `TimeUtils.formatHourMinute()` |
| `lib/widgets/work_hours_clock.dart` | Renamed `_pulse` → `_glowFactor` (all 7 occurrences) |
| `pubspec.yaml` | Fixed package name from `HourlyReminder` → `hourly_reminder` to match test imports |
| `test/widget_test.dart` | Replaced stale Flutter counter boilerplate with a real smoke test for `HourlyReminderApp` |
| `test/services/alarm_service_test.dart` | Replaced phantom WorkManager string constants test with `AlarmService.alarmId` test; updated `exactly at endHour fires` for minute-precision semantics |
