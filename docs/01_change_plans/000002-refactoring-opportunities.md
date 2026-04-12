# Code Quality Analysis — Hourly Reminder

> Generated: 2026-02-19
> Scope: all files under `lib/` and `test/`
> Baseline: `flutter analyze` → 0 issues, `flutter test` → 56 tests passing
> **Status update 2026-03-24:** 13 of 16 items fixed by home screen redesign (PR #26) and subsequent work. Only R5 remains open (low priority). See details below.

---

## Summary

| Category | Count |
|---|---|
| Dead / unused code | 3 |
| Duplicate logic / repeated blocks | 4 |
| Magic constants (no names) | 3 groups (17 sites) |
| Refactoring opportunities | 6 |

---

## 1. Dead / Unused Code

### D1 — `_buildAppBar()` wrapper method in `_HomeScreenState`
**File:** `lib/screens/home_screen.dart:142`

```dart
PreferredSizeWidget _buildAppBar() => const _AppBar();
```

This single-line method exists solely to forward to `const _AppBar()`. It provides no
abstraction and is called three times. The method can be deleted and callers can use
`const _AppBar()` directly.

**Fix:** Delete method; replace three call-sites with `appBar: const _AppBar()`.

---

### D2 — `cardTheme` in `HourlyReminderApp` is always overridden
**File:** `lib/main.dart:78-83`

```dart
cardTheme: CardThemeData(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),   // ← never used
  ),
),
```

Every `Card` in `HomeScreen` overrides the shape inline with `borderRadius: 24`. The
theme's `radius: 12` and `elevation: 2` values are dead — the inline declarations always
win.

**Fix:** Either remove `cardTheme` from the theme (cards define their own style) or
move the shared `elevation` and `radius: 24` into the theme and delete the inline
overrides (see R4 below — they can be combined).

---

### D3 — `TimeUtils.formatHour` is a redundant wrapper
**File:** `lib/core/utils/time_utils.dart:19`

```dart
static String formatHour(int hour) => '$hour:00';
```

This is functionally identical to calling `formatTime(hour.toDouble())` for any whole
hour. Both functions exist in the same class and callers in `home_screen.dart` use them
for the same purpose (displaying hour labels). Having two functions for the same output
creates confusion about which one to use.

**Fix:** Remove `formatHour`; replace 6 call-sites in `home_screen.dart` with
`TimeUtils.formatTime(_prefs.startHour.toDouble())` / `...endHour.toDouble()`.
Alternatively, keep `formatHour` but make it delegate: `=> formatTime(hour.toDouble())`.

---

## 2. Duplicate Logic / Repeated Code Blocks

### Dup1 — `savePreferences + reschedule` block duplicated twice
**Files:** `lib/screens/home_screen.dart:105-107` and `120-122`

```dart
// in _updateTime (lines 105-107):
await StorageService.savePreferences(_prefs);
if (!mounted) return;
if (_prefs.isEnabled) await AlarmService.scheduleHourlyAlarm();

// in _toggleWeekends (lines 120-122): identical
await StorageService.savePreferences(_prefs);
if (!mounted) return;
if (_prefs.isEnabled) await AlarmService.scheduleHourlyAlarm();
```

**Fix:** Extract to a private method `_saveAndReschedule()` and call it from both places.

```dart
Future<void> _saveAndReschedule() async {
  await StorageService.savePreferences(_prefs);
  if (!mounted) return;
  if (_prefs.isEnabled) await AlarmService.scheduleHourlyAlarm();
}
```

---

### Dup2 — `enableVibration`/`playSound` duplicated in `NotificationService`
**File:** `lib/services/notification_service.dart:44-45` and `86-87`

```dart
// AndroidNotificationChannel (initialize):
enableVibration: true,
playSound: true,

// AndroidNotificationDetails (showHourlyNotification): identical
enableVibration: true,
playSound: true,
```

The channel-level settings are authoritative on Android; the per-notification settings
are redundant when the channel already defines them. On older Android versions (< 8.0)
the per-notification values matter, so removing them is technically a behavior change —
but the intent is clearly to always vibrate + play sound. If both must stay, add a
comment explaining why.

**Fix (option A — minimal):** Add a comment `// mirrors channel settings for pre-O devices`.  
**Fix (option B — DRY):** Add `static const _vibrateAndSound = true;` constants and
reference them in both places.

---

### Dup3 — Slider `max: 23.5, divisions: 47` repeated twice
**File:** `lib/screens/home_screen.dart:319-320` and `364-365`

```dart
max: 23.5,
divisions: 47,
```

Appears for both the start-hour and end-hour sliders with no explanation of the values.
`47` is `(23.5 / 0.5)` — one division per 30-minute increment.

**Fix:** Introduce two private constants at the top of the `_HomeScreenState` class:

```dart
static const double _kSliderMax = 23.5;
static const int _kSliderDivisions = 47;
```

---

### Dup4 — Inline text-style patterns repeated throughout settings card
**File:** `lib/screens/home_screen.dart` (multiple locations)

The same three `TextStyle` patterns appear many times across the settings card with no
shared definition:

| Style | Sites |
|---|---|
| `fontSize:16, fontWeight:w500, color:Colors.grey[800]` | 1 |
| `fontSize:15, fontWeight:w500, color:Colors.grey[700]` | 2 |
| `fontSize:13, color:Colors.grey[600]` | 3 |

**Fix:** Define them as local constants or as part of an `AppTextStyles` class:

```dart
static const _titleStyle    = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
static const _subtitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
static const _captionStyle  = TextStyle(fontSize: 13);
```

Retrieve grey shades from `Theme.of(context).colorScheme` or keep as constants using
literal `Color(0xFF...)` (aligned with the App Colors fix below).

---

## 3. Magic Constants (No Names)

### M1 — App colors scattered across 17 sites in 2 files

The app's three semantic colours appear as raw hex literals with no names:

| Colour | Hex | Occurrences |
|---|---|---|
| Blue-grey (accent / AppBar / weekends switch / center dot) | `0xFF90A4AE` | 4 |
| Green (start hand, start slider, start legend dot) | `0xFF66BB6A` | 7 |
| Green active (start hand dragging) | `0xFF4CAF50` | 1 |
| Red (end hand, end slider, end legend dot) | `0xFFEF5350` | 6 |
| Red active (end hand dragging) | `0xFFE53935` | 1 |
| Green track bg | `0xFFE8F5E9` | 2 |
| Red track bg | `0xFFFFEBEE` | 1 |

**Files affected:** `lib/screens/home_screen.dart`, `lib/widgets/work_hours_clock.dart`

**Fix:** Create `lib/core/theme/app_colors.dart`:

```dart
abstract final class AppColors {
  static const accent   = Color(0xFF90A4AE);
  static const start    = Color(0xFF66BB6A);
  static const startActive = Color(0xFF4CAF50);
  static const startTrack  = Color(0xFFE8F5E9);
  static const end      = Color(0xFFEF5350);
  static const endActive   = Color(0xFFE53935);
  static const endTrack    = Color(0xFFFFEBEE);
}
```

Replace all raw literals with named references.

---

### M2 — Clock painter geometry magic numbers

**File:** `lib/widgets/work_hours_clock.dart` (inside `MinimalistClockPainter.paint` and `_drawHand`)

| Number | Meaning |
|---|---|
| `20` | Arc inset from clock edge for the work-sector fill |
| `15` | Tick mark outer inset |
| `45` | Hand inset (how far from edge the hand tip ends) |
| `8` | Center dot radius |

These raw offsets make it impossible to understand relative geometry without doing the
math manually. A change to clock size or visual layout requires hunting down all four.

**Fix:** Named constants at the top of `MinimalistClockPainter`:

```dart
static const double _kArcInset     = 20;
static const double _kTickInset    = 15;
static const double _kHandInset    = 45;
static const double _kCenterRadius =  8;
```

---

### M3 — Slider bounds / hand half-steps have no explanation

**Files:** `home_screen.dart`, `work_hours_clock.dart`

`23.5` (max hour) and `0.5` step size appear in comments but have no constant definition.
The fact that `divisions = 47 = (23.5 / 0.5)` is silent; it's easy to change one without
the other.

Already partially covered by **Dup3** — extract `_kSliderMax` and `_kSliderDivisions`.

---

## 4. Refactoring Opportunities

### R1 — `_draggingHand: String?` should be an enum
**File:** `lib/widgets/work_hours_clock.dart`

```dart
String? _draggingHand;          // null | 'start' | 'end'
```

Magic string literals compared in 5 places. A typo would silently break drag behavior.

**Fix:**

```dart
enum _ClockHand { start, end }
_ClockHand? _draggingHand;
```

Replace all `== 'start'` / `== 'end'` comparisons with `== _ClockHand.start` etc.

---

### R2 — `MinimalistClockPainter` constructor missing `const`
**File:** `lib/widgets/work_hours_clock.dart:154`

```dart
MinimalistClockPainter({           // ← no const
  required this.startTime,
  required this.endTime,
  this.draggingHand,
});
```

All fields are `final` and const-compatible. Without `const`, Flutter cannot short-circuit
`CustomPaint` rebuilds that pass identical values.

**Fix:** Add `const` to the constructor. Update the call-site in `WorkHoursClock.build`:

```dart
child: CustomPaint(
  painter: MinimalistClockPainter(   // can now be const when values are const
    startTime: widget.startTime,
    ...
  ),
),
```

---

### R3 — `GestureDetector` inline closures are verbose no-op wrappers
**File:** `lib/widgets/work_hours_clock.dart:41-46`

```dart
onPanStart: (details) {
  _handlePanStart(details.localPosition);
},
onPanUpdate: (details) {
  _handlePanUpdate(details.localPosition);
},
```

Both closures only extract `localPosition` before delegating. They can be simplified by
changing the handler signatures to accept the `Details` type directly:

```dart
void _handlePanStart(DragStartDetails details) =>
    _selectHand(details.localPosition);

void _handlePanUpdate(DragUpdateDetails details) =>
    _moveDraggedHand(details.localPosition);
```

Then `onPanStart: _handlePanStart, onPanUpdate: _handlePanUpdate` (method tear-offs).

---

### R4 — `HomeScreen.build()` settings card could be a `StatelessWidget`
**File:** `lib/screens/home_screen.dart:254-415`

The entire settings `Card` (~160 lines inline) takes `_prefs` data and two callbacks.
It has no internal state. Per project convention, reusable UI should be `StatelessWidget`,
not an inline helper method.

**Fix:** Extract to `_SettingsCard extends StatelessWidget` (private, same file), passing
`UserPreferences prefs`, `ValueChanged<bool> onToggleReminders`, etc. as constructor
parameters.

Similarly the clock `Card` (lines 183-252) can become `_WorkHoursCard`.

---

### R5 — `AlarmService.shouldSendReminder` takes flat params instead of model
**File:** `lib/services/alarm_service.dart:21-32`

```dart
static bool shouldSendReminder({
  required DateTime now,
  required bool isEnabled,
  required int startHour,
  required int endHour,
  required bool excludeWeekends,
}) { ... }
```

The call-site in `alarmCallback` manually unpacks `StorageService` into four separate
arguments. There is no `UserPreferences` object available in the isolate (no async load
done), so flat params make sense there — but the signature is verbose and the test
helper (`shouldSend`) exists just to wrap the call.

**Fix (optional, low priority):** Add an overload / factory that accepts `UserPreferences`:

```dart
static bool shouldSendReminderForPrefs(DateTime now, UserPreferences prefs) =>
    shouldSendReminder(
      now: now,
      isEnabled: prefs.isEnabled,
      startHour: prefs.startHour,
      endHour: prefs.endHour,
      excludeWeekends: prefs.excludeWeekends,
    );
```

Keep the flat-param version for the isolate callback.

---

### R6 — Russian section-divider comments inconsistent with codebase style
**File:** `lib/widgets/work_hours_clock.dart`

```dart
// ========== ИНТЕРАКТИВНЫЙ ВИДЖЕТ ЧАСОВ ========== 
// ========== ОБРАБОТКА НАЧАЛА КАСАНИЯ ========== 
// ========== РИСОВАЛЬЩИК ЧАСОВ ========== 
```

The rest of the codebase uses concise English doc-comments or no section headers at all.
These dividers provide no additional information beyond what the class/method names
already communicate and are inconsistent in language.

**Fix:** Remove all `// ===...===` dividers. Keep single-line comments only where the
logic is non-obvious.

---

## Proposed Fix Order

| Priority | ID | Effort | Impact | Status |
|---|---|---|---|---|
| 🔴 High | M1 — `AppColors` | Medium | Eliminates 17 duplicated literals; enables global theme changes | DONE (PR #26) |
| 🔴 High | R1 — `_ClockHand` enum | Small | Removes typo-prone magic strings | DONE (widget removed) |
| 🔴 High | Dup1 — `_saveAndReschedule()` | Small | Removes duplicated async block | DONE |
| 🟡 Medium | D1 — remove `_buildAppBar()` | Tiny | Cleanup | DONE (PR #26) |
| 🟡 Medium | D2 — fix dead `cardTheme` | Small | Resolve theme vs inline conflict | DONE (PR #26) |
| 🟡 Medium | D3 — remove `formatHour` | Small | Single formatting function | DONE |
| 🟡 Medium | Dup3 + M3 — slider constants | Tiny | Self-documenting slider config | DONE (sliders removed) |
| 🟡 Medium | M2 — painter geometry constants | Small | Self-documenting painter | DONE (widget removed) |
| 🟡 Medium | R2 — `const` painter constructor | Tiny | Performance | DONE (widget removed) |
| 🟢 Low | R4 — extract card widgets | Medium | Cleaner `build()`, reusability | DONE (PR #26) |
| 🟢 Low | Dup2 — notification channel comment | Tiny | Clarity | DONE (native pipeline) |
| 🟢 Low | Dup4 — text style constants | Small | Reduce repetition | DONE (AppTypography) |
| 🟢 Low | R3 — GestureDetector tear-offs | Small | Cleaner callbacks | DONE (widget removed) |
| 🟢 Low | R5 — `shouldSendReminderForPrefs` | Small | Convenience overload | OPEN |
| 🟢 Low | R6 — remove Russian dividers | Tiny | Style consistency | DONE (widget removed) |
