# HomeScreen Widget Extraction

Branch: `refactor/homescreen-widget-extraction`

Change plan: `docs/01_change_plans/000007-homescreen-widget-extraction.md`

---

## What changed

`lib/screens/home_screen.dart` had a 345-line `build()` method. Extracted three widget classes into separate files under `lib/screens/widgets/`. No logic changes.

### `lib/screens/widgets/work_hours_card.dart` — `WorkHoursCard`

The work hours clock card. Takes `UserPreferences` and start/end time callbacks. Renders the `WorkHoursClock` widget and the color legend row below it.

### `lib/screens/widgets/settings_card.dart` — `SettingsCard`

The settings card. Takes `UserPreferences` and all update/toggle callbacks. Internally split into four private builder methods:

- `_buildRemindersToggle` - the enable/disable switch row
- `_buildTimeSliders` - start and end time sliders with time labels
- `_buildWeekendToggles` - Saturday and Sunday switches
- `_buildGenderSection` - gender radio list

### `lib/screens/widgets/test_notification_button.dart` — `TestNotificationButton`

The test notification button. Uses `context.mounted` (correct pattern for `StatelessWidget`, replaces the `mounted` check that only works inside `State`).

---

## Result

`home_screen.dart`: 452 lines -> 155 lines. All `_toggle*` and `_update*` methods stay on `_HomeScreenState` unchanged.

158 tests pass. `flutter analyze` shows no new issues.
