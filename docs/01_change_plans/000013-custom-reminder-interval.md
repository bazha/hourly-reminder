# 000013 - Custom Reminder Interval

## Status: APPLIED

## Background

The reminder interval is hardcoded to 1 hour (next full hour). Users in different work environments need different cadences: a developer might want every 30 min, someone in frequent meetings every 2 hours. There's no way to customize this without changing code.

The interval affects 3 flows:
1. **Hourly base flow** - `ReminderScheduler` schedules next full hour
2. **Adaptive flow** - `AlreadyMovedReceiver` / `IntervalCalculator` reschedules 30 or 45 min after user confirms movement
3. **Snooze flow** - 10-minute delay (unchanged by this feature)

## Design

Add a `reminderIntervalMinutes` field to `UserPreferences` (default: 60, range: 15-120, step: 15).

The scheduler changes from "next full hour" to "now + interval minutes, clamped to work hours." The adaptive intervals scale proportionally: fast reaction = interval * 0.5, slow reaction = interval * 0.75.

### User-facing

New settings row: "Интервал напоминаний" showing current value (e.g. "60 мин"). Taps open a bottom sheet with a slider (15-120 min, 15-min steps). The "next reminder" banner updates accordingly.

### Scheduling logic change

**Before:** Always schedule at next :00 (full hour).
**After:** Schedule at `lastNotificationTime + intervalMinutes`, rounded to nearest minute, clamped within work hours. If the computed time is in the past or outside work hours, jump to `workStart + firstNotificationDelay` on the next work day.

### Adaptive interval scaling

The current adaptive intervals (30/45 min) were designed for a 60-min base. They should scale with the user's chosen interval:

| Base interval | Fast reaction (<=3min) | Slow reaction (>3min) |
|--------------|----------------------|---------------------|
| 30 min | 15 min | 22 min |
| 45 min | 22 min | 34 min |
| 60 min (current) | 30 min | 45 min |
| 90 min | 45 min | 67 min |
| 120 min | 60 min | 90 min |

Formula: `fast = interval * 0.5`, `slow = interval * 0.75`

## Affected Files

### Dart

| File | Change |
|------|--------|
| `lib/models/user_preferences.dart` | Add `reminderIntervalMinutes` field (int, default 60) |
| `lib/services/storage_service.dart` | Save/load new pref key `reminder_interval_minutes` |
| `lib/services/alarm_service.dart` | `nextNotificationTime()` uses interval instead of fixed 60 min; `scheduleHourlyAlarm()` passes interval to native |
| `lib/features/movement/domain/usecases/interval_calculator.dart` | Accept base interval param, compute proportional fast/slow |
| `lib/features/movement/domain/usecases/confirm_movement_use_case.dart` | Pass base interval to IntervalCalculator |
| `lib/screens/widgets/settings_card.dart` | Add "Интервал напоминаний" row + bottom sheet slider |
| `lib/screens/home_screen.dart` | Wire new setting callback, pass to SettingsSection |
| `lib/services/notification_service.dart` | iOS snooze: no change (10 min stays fixed) |

### Android (Kotlin)

| File | Change |
|------|--------|
| `ReminderScheduler.kt` | Read interval from SharedPreferences instead of `+1 HOUR`; schedule at `now + interval` |
| `ReminderReceiver.kt` | Use interval-based scheduling instead of hourly |
| `AlreadyMovedReceiver.kt` | Read base interval from prefs, compute proportional fast/slow intervals |
| `MainActivity.kt` | No change (already passes through to ReminderScheduler) |
| `SnoozeReceiver.kt` | No change (10-min snooze is independent) |
| `BootReceiver.kt` | No change (re-registers alarm, ReminderScheduler will read new interval) |

### SharedPreferences

New key: `flutter.reminder_interval_minutes` (int, default 60)

Read by: Dart StorageService, Android ReminderScheduler, Android ReminderReceiver, Android AlreadyMovedReceiver

## Implementation Steps

### Step 1: Data model + storage

- Add `reminderIntervalMinutes` to `UserPreferences` (default 60, copyWith, equality)
- Add save/load in `StorageService` with key `reminder_interval_minutes`
- Add sync getter `getReminderIntervalMinutes()` for native access pattern

### Step 2: Dart scheduling logic

- Update `AlarmService.nextNotificationTime()`:
  - Accept `intervalMinutes` parameter
  - Compute next time as `now + intervalMinutes` (instead of next full hour)
  - Clamp within work hours window
  - Preserve first notification delay (45 min after work start)
- Update `AlarmService.scheduleHourlyAlarm()` to pass interval to native channel

### Step 3: IntervalCalculator + ConfirmMovementUseCase

- `IntervalCalculator.compute()`: accept `baseIntervalMinutes` parameter
  - Fast: `baseInterval * 0.5`
  - Slow: `baseInterval * 0.75`
  - Minimum: 10 minutes (floor)
- `ConfirmMovementUseCase`: read interval from prefs, pass to calculator

### Step 4: Android native scheduling

- `ReminderScheduler`: read `flutter.reminder_interval_minutes` from SharedPreferences, schedule `now + interval` instead of next hour
- `ReminderReceiver`: use interval-based next-alarm scheduling
- `AlreadyMovedReceiver`: read base interval, compute proportional values

### Step 5: UI

- Add "Интервал напоминаний" row to `SettingsSection` (between "Дневная цель" and "Стиль уведомлений")
- Bottom sheet with slider: 15-120 min, 15-min steps, shows current value
- Update `HomeScreen` to wire `_updateInterval` callback
- `_NextReminderBanner` already reads from `AlarmService.nextNotificationTime()` - just pass the interval

### Step 6: Tests

- Unit tests for `IntervalCalculator` with different base intervals
- Unit tests for `AlarmService.nextNotificationTime()` with custom intervals
- Unit tests for `UserPreferences` new field
- Unit tests for `StorageService` save/load

## Testing Checklist

- [ ] Default 60 min behaves identically to current behavior
- [ ] Setting 30 min interval schedules reminders every 30 min
- [ ] Setting 120 min interval schedules reminders every 2 hours
- [ ] Adaptive intervals scale: 30 min base -> 15/22 min adaptive
- [ ] First notification delay (45 min) still works regardless of interval
- [ ] Work hours boundaries respected (no notification outside window)
- [ ] Android native reads interval from SharedPreferences correctly
- [ ] "Already moved" action uses scaled interval
- [ ] Snooze (10 min) unchanged
- [ ] Boot receiver re-registers with correct interval
- [ ] Settings bottom sheet slider works (15-120 range)
- [ ] Next reminder banner shows correct time
- [ ] `dailyNotificationCount` adjusts for new interval
- [ ] All existing tests pass

## Rollback Plan

Remove `reminderIntervalMinutes` field and revert to hardcoded 60-min scheduling. The SharedPreferences key is ignored if not present (default fallback).

## Benefits

- Users control their reminder frequency
- No more "too frequent" or "not enough" complaints
- Adaptive scheduling stays proportional
- Zero breaking changes (default 60 min = current behavior)
