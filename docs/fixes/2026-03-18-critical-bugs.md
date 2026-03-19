# Bug Fixes

Branch: `fix/critical-bugs`

---

## Critical

### 1. `getLong` vs `getInt` type mismatch in ReminderReceiver

**File:** `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/ReminderReceiver.kt:35-38`

**Problem:** Flutter's `SharedPreferences.setInt()` stores values using Android's `putInt()`. The native code was reading them with `getLong()`. On Android, `getLong()` on a key stored with `putInt()` returns the default value instead of the actual stored value — so work hours always fell back to 9:00–18:00 regardless of what the user configured.

**Fix:** Changed `getLong()` to `getInt()` for all four work-hour keys (`start_hour`, `start_minute`, `end_hour`, `end_minute`).

---

### 2. Dead conditional in MovementActionHandler

**File:** `lib/features/movement/presentation/movement_action_handler.dart:41-47`

**Problem:** Both branches of an `if (isWithinWorkHours)` block called `AlarmService.scheduleHourlyAlarm()` — identical code in both paths. The check itself was computing `shouldSendReminder()` just to throw the result away. The comment in the `else` branch said "alarm scheduler will pick up on its own cycle", implying the intent was to skip scheduling outside work hours, but it didn't.

**Fix:** Removed the conditional entirely. Both original branches had the same behavior, so the code now just calls `scheduleHourlyAlarm()` unconditionally. Also removed the now-unused `shouldSendReminder()` call and its local variable.

---

### 3. `StateError` crash on unknown `MovementSource`

**File:** `lib/features/movement/data/models/movement_event_model.dart:34-36`

**Problem:** `MovementSource.values.firstWhere((s) => s.name == source)` throws `StateError` if the stored string doesn't match any enum value. This can happen on version upgrades that add/remove enum variants, or if SharedPreferences data gets corrupted.

**Fix:** Added `orElse: () => MovementSource.manual` so unknown values fall back gracefully instead of crashing.

---

### 4. Exercise index not reset on new day

**File:** `android/app/src/main/kotlin/com/bazhanau/hourly_reminder/ExerciseRepository.kt:26-38`

**Problem:** `recordNotificationShown()` correctly detected a new day and reset `notifications_shown_count` to 0, but never reset `exercise_index`. So on day 2, the first non-first notification would continue the exercise list from wherever day 1 left off, skipping exercises at the start of the list indefinitely.

**Fix:** When `recordNotificationShown()` detects a new day (`savedDate != today`), it now also writes `exercise_index = 0` to SharedPreferences in the same atomic `edit()` call.

---

## Medium

### 5. Wrong handle selected near 12:00 on clock widget

**File:** `lib/widgets/work_hours_clock.dart:63-64`

**Problem:** `_handlePanStart` determined which handle (start/end) the user was dragging by computing linear `abs()` distance between the touch point and each handle's 12-hour position. On a circular 12-hour dial, position `11.9` and position `0.1` are only `0.2` apart — but linear distance gives `11.8`. This caused the wrong handle to be selected when one handle was just before midnight and the other just after.

**Fix:** Introduced `_circularDist12(a, b)` — computes `min(|a-b| % 12, 12 - |a-b| % 12)` to get the true shortest arc distance. Used it in place of raw `abs()` in `_handlePanStart`.

---

### 6. iOS missing snooze action

**File:** `lib/services/notification_service.dart`

**Problem:** The iOS `DarwinNotificationCategory` only defined the "Я уже двигался" action. There was no snooze button on iOS, while Android had one ("Через 10 минут" via `SnoozeReceiver`). iOS users had no way to delay a notification.

**Fix:** Added a `snooze` action to the iOS category. In `_onNotificationResponse`, the snooze action triggers `_snoozeForIos()`, which uses `zonedSchedule` to fire a new notification exactly 10 minutes from now — matching Android's `SnoozeReceiver` behavior.
