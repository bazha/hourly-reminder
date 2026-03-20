# 000011 - Next Reminder Indicator, Manual Movement, Daily Goal

## Overview

Three features that improve the app's daily utility:
1. **Next reminder indicator** on home screen - shows when the next reminder fires
2. **Manual "I moved" button** - log movement without waiting for a notification
3. **Daily movement goal** with progress - gives users a target to aim for

---

## Feature 1: Next Reminder Indicator

### Problem

Users have no way to know when the next reminder will fire. The app shows work hours and an on/off toggle, but nothing about the upcoming alarm. This creates "is it working?" doubt.

### Solution

Display a text line below the status pill on the home screen showing the next reminder time or a contextual message.

Examples:
- "Следующее напоминание в 15:00" (Next reminder at 15:00)
- "Следующее напоминание завтра в 9:00" (Next reminder tomorrow at 9:00)
- "Нерабочее время" (Outside work hours) - when past end time today
- "Напоминания выключены" (Reminders off) - when disabled

### Implementation

**Reuse existing pure function**: `AlarmService.nextNotificationTime()` already computes exactly this. It accepts preferences and current time, returns a `DateTime?`. No native code needed.

#### Files to modify

**`lib/screens/home_screen.dart`**
- Import `AlarmService`
- After the `_StatusPill`, add a `_NextReminderText` widget
- Pass `_prefs` and current time to compute next reminder via `AlarmService.nextNotificationTime()`
- Use a periodic timer (every 60 seconds) or rebuild on preference change to keep it fresh

**`lib/core/utils/time_utils.dart`** (minor addition)
- Add a `formatNextReminder(DateTime? next, DateTime now)` function that returns the appropriate Russian string ("в 15:00", "завтра в 9:00", etc.)

#### New widget (inside home_screen.dart, private)

```dart
class _NextReminderText extends StatelessWidget {
  final UserPreferences prefs;

  Widget build(context) {
    final now = DateTime.now();
    final next = AlarmService.nextNotificationTime(
      now: now,
      isEnabled: prefs.isEnabled,
      startHour: prefs.startHour,
      startMinute: prefs.startMinute,
      endHour: prefs.endHour,
      endMinute: prefs.endMinute,
      workOnSaturday: prefs.workOnSaturday,
      workOnSunday: prefs.workOnSunday,
    );
    final text = TimeUtils.formatNextReminder(next, now);
    // Render as small muted text
  }
}
```

#### Tests to add

- `test/core/utils/time_utils_test.dart`: test `formatNextReminder` for same-day, next-day, disabled cases

---

## Feature 2: Manual "I Moved" Button

### Problem

Users can only log movement by tapping the notification action. If they stretch on their own initiative, there's no way to record it. This underreports actual movement and makes stats inaccurate.

### Solution

A button on the home screen that records a manual movement event and resets the sedentary timer. Follows the existing `ConfirmMovementUseCase` pattern but with `MovementSource.manual` and zero reaction time.

### Implementation

#### Files to modify

**`lib/features/movement/domain/usecases/confirm_movement_use_case.dart`**
- Add optional `source` parameter to `execute()`:
```dart
Future<Duration> execute({MovementSource source = MovementSource.notification}) async {
  // ... existing logic ...
  final event = MovementEvent(
    id: _generateId(),
    timestamp: now,
    sedentaryDuration: sedentaryDuration,
    reactionTime: source == MovementSource.manual ? Duration.zero : reactionTime,
    source: source,
  );
  // ... rest unchanged ...
}
```

**`lib/screens/home_screen.dart`**
- Add `MovementLocalDatasource` and `MovementRepositoryImpl` dependencies (created in `main.dart`, passed via MainShell)
- Add `_recordManualMovement()` method that creates a `ConfirmMovementUseCase` and calls `execute(source: MovementSource.manual)`
- Add a manual movement button between the status pill and the work hours card

**`lib/screens/main_shell.dart`**
- Pass `SharedPreferences` instance (or the datasource) to `HomeScreen`

**`lib/main.dart`**
- Pass `SharedPreferences` instance through to `MainShell` so `HomeScreen` can create the use case

#### New widget (inside home_screen.dart or separate file)

A teal-outlined button: "Я подвигался!" with a checkmark icon. On tap:
1. Call `_recordManualMovement()`
2. Show a snackbar: "Записано! Сидячий таймер сброшен"
3. Update the next reminder indicator (sedentary reset changes adaptive timing)

#### Tests to add

- `test/features/movement/domain/usecases/confirm_movement_use_case_test.dart`: test `execute(source: MovementSource.manual)` saves event with manual source and zero reaction time
- Widget test: button tap triggers use case

---

## Feature 3: Daily Movement Goal

### Problem

The stats screen shows how many times the user moved today, but there's no target. Users don't know if 3 movements is good or bad. A configurable daily goal provides motivation and a clear "am I on track?" signal.

### Solution

Add a `dailyGoal` field to `UserPreferences` (default: 8). Show goal progress on the home screen as a compact progress indicator, and on the stats screen in the today summary card.

### Implementation

#### Model changes

**`lib/models/user_preferences.dart`**
- Add field: `final int dailyGoal;`
- Default: `this.dailyGoal = 8`
- Update `copyWith()`, `operator ==`, `hashCode`

**`lib/services/storage_service.dart`**
- `loadPreferences()`: add `dailyGoal: _prefs.getInt('daily_goal') ?? 8`
- `savePreferences()`: add `await _prefs.setInt('daily_goal', prefs.dailyGoal)`
- Add sync getter: `int get dailyGoal => _prefs.getInt('daily_goal') ?? 8;`

#### Stats changes

**`lib/features/movement_stats/domain/entities/movement_stats.dart`**
- Add `final int dailyGoal;` to `MovementStats`
- Update constructor, equality, hashCode

**`lib/features/movement_stats/domain/usecases/get_movement_stats_use_case.dart`**
- Accept `dailyGoal` parameter, pass through to `MovementStats`

**`lib/features/movement_stats/data/repositories/movement_stats_repository_impl.dart`**
- Read `dailyGoal` from preferences, pass to use case

#### UI changes

**`lib/screens/home_screen.dart`**
- Add a `_GoalProgress` widget between the status pill / next reminder and the work hours card
- Shows: circular progress indicator or simple bar with "3/8 разминок сегодня"
- Needs today's movement count: load from `MovementLocalDatasource.getEvents()` filtered by today's date, or pass from stats repository

**`lib/features/movement_stats/presentation/widgets/today_summary_card.dart`**
- Add goal context to the movement count tile: "5/8" instead of just "5"
- Optional: color the number green when goal is met

**`lib/screens/widgets/settings_card.dart`** (OptionsCard)
- Add a goal slider or stepper: "Цель на день: 8 разминок" (Daily goal: 8 movements)
- Range: 1-15, step 1

#### Tests to update

- `test/models/user_preferences_test.dart`: add dailyGoal to defaults, copyWith, equality tests
- `test/services/storage_service_test.dart`: verify dailyGoal is loaded/saved
- `test/features/movement_stats/domain/usecases/get_movement_stats_use_case_test.dart`: verify dailyGoal is passed through
- `test/features/movement_stats/data/repositories/movement_stats_repository_impl_test.dart`: verify dailyGoal from preferences

---

## Implementation Order

### Phase 1: Next Reminder Indicator
1. Add `TimeUtils.formatNextReminder()` + tests
2. Add `_NextReminderText` widget to `home_screen.dart`
3. Verify visually

### Phase 2: Daily Goal (model + settings)
4. Add `dailyGoal` to `UserPreferences` + tests
5. Add `dailyGoal` to `StorageService` + tests
6. Add goal slider to `OptionsCard`
7. Add `dailyGoal` to `MovementStats` entity + use case + repository + tests

### Phase 3: Manual Movement
8. Add `source` parameter to `ConfirmMovementUseCase.execute()` + tests
9. Pass dependencies through `MainShell` to `HomeScreen`
10. Add manual movement button to home screen

### Phase 4: Goal Progress UI
11. Add `_GoalProgress` widget to home screen (needs today's count + goal)
12. Update `TodaySummaryCard` to show goal context
13. Run full test suite + flutter analyze

---

## Verification

1. `flutter analyze` - zero new warnings
2. `flutter test` - all tests pass
3. Next reminder text updates when toggling reminders or changing work hours
4. Manual movement button records event, resets sedentary timer, shows in stats
5. Daily goal persists across app restarts
6. Goal progress reflects actual movement count for today
7. Stats screen shows goal context (e.g., "5/8")
