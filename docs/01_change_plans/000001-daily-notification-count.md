# Change Plan: Daily Notification Count Display

## Problem
Users have no way to know how many reminders they will receive per day given
their configured work-hour window.

## Approach

### Logic layer — `UserPreferences.dailyNotificationCount`
Pure getter: `endHour >= startHour ? (endHour - startHour + 1) : 0`

Examples: 9–18 → 10, 12–12 → 1, invalid (start > end) → 0.

### Tests (written first — TDD)
New group in `test/models/user_preferences_test.dart`:
- 9–18 → 10, 12–12 → 1, 0–23 → 24, 6–14 → 9, start > end → 0

### UI
Below the "Включены / Выключены" subtitle in the reminders Switch row:
`~X уведомлений в рабочий день` (grey, fontSize 13).
