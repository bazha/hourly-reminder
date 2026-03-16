# Refactoring & Code Quality Report

## Summary

| Category | Count |
|---|---|
| Bugs | 3 |
| Tests vs implementation mismatch (dead test code) | 6 |
| Duplicate code | 1 |
| Dead / misleading code | 2 |

---

## 🐛 Bugs

### 1. `UserPreferences.copyWith` silently drops `startMinute` and `endMinute`

**File:** `lib/models/user_preferences.dart:18–32`

The method signature accepts `startMinute` and `endMinute`, but they are never forwarded to the constructor:

```dart
// Current — both params silently ignored:
UserPreferences copyWith({
  bool? isEnabled,
  int? startHour,
  int? startMinute,   // ← accepted
  int? endHour,
  int? endMinute,     // ← accepted
  bool? excludeWeekends,
}) {
  return UserPreferences(
    isEnabled: isEnabled ?? this.isEnabled,
    startHour: startHour ?? this.startHour,
    endHour: endHour ?? this.endHour,          // startMinute never passed
    excludeWeekends: excludeWeekends ?? this.excludeWeekends,
    // endMinute never passed either
  );
}
```

**Fix:** pass both minute fields through:

```dart
return UserPreferences(
  isEnabled:      isEnabled      ?? this.isEnabled,
  startHour:      startHour      ?? this.startHour,
  startMinute:    startMinute    ?? this.startMinute,
  endHour:        endHour        ?? this.endHour,
  endMinute:      endMinute      ?? this.endMinute,
  excludeWeekends: excludeWeekends ?? this.excludeWeekends,
);
```

This bug means any call like `_prefs.copyWith(startMinute: minute)` in `HomeScreen._updateStartTime` stores a `UserPreferences` with `startMinute == 0`, so the minute part of the start time is always lost after the first change.

---

### 2. `AlarmService.alarmCallback` ignores minutes when checking the work window

**File:** `lib/services/alarm_service.dart:25–26`

```dart
if (hour < startHour || hour > endHour) return;
```

The callback only fetches and compares hours. `startMinute`/`endMinute` are stored in `SharedPreferences` and respected in the UI, but the alarm itself fires any time the hour falls in the range — the minute offsets have no effect.

**Fix:** Add `startMinute`/`endMinute` sync getters to `StorageService`, then compare total minutes:

```dart
// In StorageService — add two missing sync getters:
static int get startMinute => _prefs.getInt('start_minute') ?? 0;
static int get endMinute   => _prefs.getInt('end_minute')   ?? 0;

// In AlarmService.alarmCallback — replace hour-only check:
final nowMinutes   = now.hour * 60 + now.minute;
final startMinutes = startHour * 60 + StorageService.startMinute;
final endMinutes   = endHour   * 60 + StorageService.endMinute;
if (nowMinutes < startMinutes || nowMinutes > endMinutes) return;
```

---

### 3. `UserPreferences` lacks `==` and `hashCode`

**File:** `lib/models/user_preferences.dart`

The class is used as a value type throughout the app (copied with `copyWith`, compared in tests via `expect(loaded, equals(expected))`). Without `==`/`hashCode`, comparisons fall back to reference equality, so `expect(loaded, equals(expected))` in `storage_service_test.dart` always fails.

**Fix:** Add value equality (manually or via the `equatable` package):

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is UserPreferences &&
        isEnabled      == other.isEnabled &&
        startHour      == other.startHour &&
        startMinute    == other.startMinute &&
        endHour        == other.endHour &&
        endMinute      == other.endMinute &&
        excludeWeekends == other.excludeWeekends;

@override
int get hashCode => Object.hash(
    isEnabled, startHour, startMinute, endHour, endMinute, excludeWeekends);
```

---

## 🧪 Tests reference things that don't exist

The test suite is significantly ahead of the implementation. The following are referenced in tests but missing from the production code, so **the test suite currently does not compile/pass**.

### 4. `AlarmService.shouldSendReminder()` is missing

**File:** `test/services/alarm_service_test.dart:15`

Tests call `AlarmService.shouldSendReminder(now: ..., isEnabled: ..., ...)`. The actual `AlarmService` has no such method — the logic lives inline inside `alarmCallback()` and is therefore untestable.

**Fix:** Extract the condition check into a pure static method:

```dart
/// Pure function: given a moment in time and user settings, should a
/// notification be sent?  No side-effects, easy to unit-test.
static bool shouldSendReminder({
  required DateTime now,
  required bool isEnabled,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  required bool excludeWeekends,
}) {
  if (!isEnabled) return false;
  final dayOfWeek = now.weekday;
  if (excludeWeekends && (dayOfWeek == 6 || dayOfWeek == 7)) return false;
  final nowMin   = now.hour * 60 + now.minute;
  final startMin = startHour * 60 + startMinute;
  final endMin   = endHour   * 60 + endMinute;
  return nowMin >= startMin && nowMin <= endMin;
}
```

Then `alarmCallback` calls `shouldSendReminder(now: DateTime.now(), ...)` instead of duplicating the logic.

---

### 5. `AlarmService.nextNotificationTime()` is missing

**File:** `test/services/alarm_service_test.dart:253`

Tests call `AlarmService.nextNotificationTime(now: ..., ...)` and assert it returns the correct next `DateTime`. This method does not exist in `alarm_service.dart`.

**Fix:** Implement it as a pure static method:

```dart
/// Returns the DateTime of the next notification, or null if reminders
/// are disabled.  Does not schedule anything — purely a calculation.
static DateTime? nextNotificationTime({
  required DateTime now,
  required bool isEnabled,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  required bool excludeWeekends,
}) {
  if (!isEnabled) return null;
  // ... walk forward by full hours until shouldSendReminder returns true
}
```

---

### 6. `UserPreferences.dailyNotificationCount` is missing

**File:** `test/models/user_preferences_test.dart:129`

Tests assert e.g. `UserPreferences().dailyNotificationCount == 10` for a 9–18 window. No such getter exists on the model.

**Fix:** Add the computed getter:

```dart
/// Number of hourly notifications that fire in one work day.
int get dailyNotificationCount {
  final start = startHour * 60 + startMinute;
  final end   = endHour   * 60 + endMinute;
  if (end <= start) return 0;
  return ((end - start) / 60).floor() + 1;
}
```

---

### 7. `UserPreferences.startTotalMinutes` / `endTotalMinutes` are missing

**File:** `test/models/user_preferences_test.dart:188–195`

Tests assert `prefs.startTotalMinutes == 570` for `startHour: 9, startMinute: 30`. No such getter exists.

**Fix:** Add two one-liner getters:

```dart
int get startTotalMinutes => startHour * 60 + startMinute;
int get endTotalMinutes   => endHour   * 60 + endMinute;
```

These getters also replace the repeated `hour * 60 + minute` arithmetic elsewhere.

---

### 8. `StorageService.isInitialized` is missing

**File:** `test/services/storage_service_test.dart:19`

Tests call `StorageService.isInitialized`. The static class has no such flag.

**Fix:** Add a private flag and a public getter:

```dart
static bool _initialized = false;
static bool get isInitialized => _initialized;

static Future<void> initialize() async {
  _prefs = await SharedPreferences.getInstance();
  _initialized = true;
}
```

---

## 📋 Duplicate Code

### 9. Time formatting inlined in `HomeScreen` despite `TimeUtils` existing

**File:** `lib/screens/home_screen.dart` — lines 160, 178, 260, 269, 302, 311

The pattern `'${hour}:${minute.toString().padLeft(2, '0')}'` appears six times in `HomeScreen`. `TimeUtils.formatHourMinute(hour, minute)` does exactly this but is never imported by `HomeScreen`.

**Fix:** Import `TimeUtils` and replace all occurrences:

```dart
// Replace every:
'${_prefs.startHour}:${_prefs.startMinute.toString().padLeft(2, '0')}'
// with:
TimeUtils.formatHourMinute(_prefs.startHour, _prefs.startMinute)

// and similarly for endHour/endMinute.
```

---

## 💀 Dead / Misleading Code

### 10. `_pulse` constant in `_ClockPainter` implies animation that doesn't exist

**File:** `lib/widgets/work_hours_clock.dart:115`

```dart
static const _pulse = 0.7;
```

The name `_pulse` and its use in glow radii / alpha calculations (e.g. `_pulse * 0.06`, `0.35 + _pulse * 0.20`) implies this value should oscillate over time to create a breathing/pulsing glow effect. Instead it is a frozen constant — the "animation" always renders at the same fixed opacity.

**Two options:**

- **A (simple):** rename it to `_glowFactor` or `_glowIntensity` to match what it actually is.
- **B (intended):** make `WorkHoursClock` a `StatefulWidget` with a `AnimationController` (e.g. `CurvedAnimation` over a `RepeatMode.reverse` loop) and pass the animated value into `_ClockPainter` via the constructor, then call `_painter.shouldRepaint` each tick. This was likely the original intent.

---

### 11. WorkManager task-name tests assert hard-coded strings unrelated to actual code

**File:** `test/services/alarm_service_test.dart:235–248`

The test group "WorkManager task identifiers" defines local string constants and asserts they are non-empty. The actual `AlarmService` uses `android_alarm_manager_plus`, not WorkManager — these test strings have no connection to the production code. If the constants ever needed to be changed, the tests would not catch it.

**Fix:** Either delete this test group (it tests nothing), or expose the real alarm ID as a public constant:

```dart
// In AlarmService:
static const int alarmId = 0;  // expose for tests

// In tests — import and reference the real constant:
expect(AlarmService.alarmId, isA<int>());
```

---

## Quick fix priority

| # | Impact | Effort |
|---|---|---|
| 1 — `copyWith` drops minutes | High (data loss on time edit) | Trivial |
| 3 — missing `==`/`hashCode` | High (all equality tests broken) | Small |
| 2 — alarm ignores minutes | Medium (feature broken) | Small |
| 9 — duplicate formatting | Medium (maintenance) | Small |
| 4–8 — missing methods | Blocks test suite | Medium |
| 6 — `dailyNotificationCount` | Low (informational) | Trivial |
| 10 — `_pulse` naming | Low (misleading) | Trivial |
| 11 — phantom WorkManager tests | Low (noise) | Trivial |
