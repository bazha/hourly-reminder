# 000007 - HomeScreen Widget Extraction

## Problem

`lib/screens/home_screen.dart` is 452 lines. The `build()` method is 345 lines, making it hard to read and navigate. This was flagged in change plan 000002 but never acted on.

## Goal

Extract the three major UI sections of `_HomeScreenState.build()` into private `StatelessWidget` classes within the same file. No logic changes - purely structural.

## Sections Extracted

### `_WorkHoursCard`
The work hours clock card (clock widget + legend row). Takes `UserPreferences` and two time-changed callbacks.

### `_SettingsCard`
The settings card with all toggles, sliders, and radio buttons. Takes `UserPreferences` and all update callbacks. Has three private builder methods internally:
- `_buildRemindersToggle`
- `_buildTimeSliders`
- `_buildWeekendToggles`
- `_buildGenderSection`

### `_TestNotificationButton`
The test notification button. Stateless, calls `NotificationService.showHourlyNotification()` directly. Uses `context.mounted` instead of `mounted` (correct pattern for StatelessWidget).

## Result

`_HomeScreenState.build()` is reduced from 345 lines to ~30 lines. All `_toggle*` and `_update*` methods remain on `_HomeScreenState` unchanged.

## Files Changed

- `lib/screens/home_screen.dart`

## Verification

```bash
flutter analyze   # expect 0 issues
flutter test      # expect all tests to pass
```
