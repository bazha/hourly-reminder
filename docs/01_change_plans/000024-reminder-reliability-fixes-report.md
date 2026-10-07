# 000024 - Reminder Reliability Fixes: Completion Report

## Summary

All 5 batches are implemented. The changes are not committed yet.

1. **Disabling and day off stop everything.**
   - Android: `ReminderScheduler.cancel()` cancels the hourly (100), settling (150) and snooze (200) alarms through shared PendingIntent builders. `ReminderReceiver` checks `is_enabled` before rescheduling. `SnoozeReceiver` shows nothing when reminders are off or it's the day off. `AlreadyMovedReceiver` keeps the event but skips scheduling when reminders are off.
   - iOS: `cancelSnooze()` (id 2) runs when reminders are turned off and on the day off. `_snoozeForIos` doesn't schedule a snooze when reminders are off or it's the day off.
2. **DST-safe date arithmetic.** The stats use case, `nextNotificationTime` and `formatNextReminder` use the `DateTime` constructor and UTC dates instead of `Duration`.
3. **`saveEvent` reloads prefs** before its read-modify-write.
4. **iOS "Напоминания на паузе" notice** (id 3) at the slot after the last queued reminder. A notice that already fired is removed from Notification Center on the next refill.
5. **Work hours that fit no reminder:** the change is saved, then a SnackBar warns. The home banner shows the warning instead of "Напоминания выключены".

## Verification

| Check | Result |
|---|---|
| New tests, watched failing first | Yes, each one failed for the expected reason. Batch 2 tests fail only under a DST zone: streak 3 instead of 8, 11:00 instead of 10:00, "today" instead of "tomorrow" |
| `flutter test` | 108/108 under `TZ=Europe/Berlin`, `America/New_York` and `Europe/Minsk` |
| Existing tests | Unchanged: `git diff` of the existing test files only adds lines |
| `flutter analyze`, `dart format` | Clean |
| `flutter build apk --debug` | Builds (Kotlin compiles) |
| Kotlin unit tests | None (no Android test setup, as in 000023) |
| Final review (separate agent) | "With fixes". No critical issues. The one user-visible finding (stale delivered notice) is fixed with a test |
| Manual tests on Android and iOS | **Not done.** See the checklists in the plan |

New tests: 22 (86 → 108).
- `get_movement_stats_use_case_test.dart`: 3 tests (DST switch).
- `alarm_service_test.dart`: 3 tests (DST day, DST week, 61 times).
- `time_utils_test.dart`: 1 test (tomorrow across spring-forward).
- `movement_local_datasource_test.dart` (new file): 1 test (event written behind the cache).
- `ios_reminder_scheduler_test.dart`: 6 tests (`cancelSnooze`, paused notice).
- `storage_service_test.dart`: 1 test (`remindersActiveToday`).
- `user_preferences_test.dart`: 4 tests (`hasReminderWindow`).
- `test/screens/home_screen_test.dart` (new file): 3 widget tests (warning banner, disabled banner, SnackBar after a real time-picker edit).

## Deviations from the plan

- **New `StorageService.remindersActiveToday` getter.** It makes the iOS snooze check testable, and the check reads the same everywhere.
- **The SnackBar helper is named `showNoReminderFitsWarning`** (the plan said `showNoReminderFitsSnackBar`).
- **The paused notice is rebuilt independently from the reminders.** When only the notice moves, the 60 reminders are not scheduled again.
- **Added after the final review:** a notice that has already fired is removed (`cancel(id: 3)`) before the next one is scheduled. Otherwise "Напоминания на паузе" stays in Notification Center after the user opens the app and reminders resume. The `cancel()` doc comment is corrected too: the plugin's cancel removes delivered notifications as well.
- **Widget tests added for Batch 5** (not in the plan's list).
- **No commits.** The plan suggests one commit per batch. Some hunks mix batches and have to be split by hand:
  - `ios_reminder_scheduler.dart`: the id constants, `cancel` and `cancelSnooze` mix Batches 1 and 4.
  - `.claude/context.md`: mixes Batches 1, 2 and 4.
- **`.claude/CLAUDE.md` not changed.** Adding `TZ=Europe/Berlin flutter test` there still needs approval. It is in the README and `context.md`.

## Decisions taken with the plan defaults

- Batch 5 warns and saves, it doesn't reject. Changing start and end one at a time must not get stuck.
- A snoozed reminder ignores work hours, but respects reminders being off and the day off.

## Known gaps (from the final review, not fixed)

- Tapping the paused notice opens the Stats tab. Home would fit better.
- README says the iOS queue is refilled "on every notification action". Snooze doesn't refill it. The sentence was already there.
- A manual movement right after "Уже размялся" from a heads-up notification (app in the foreground) is saved, but its sedentary duration counts from the old start time. `ConfirmMovementUseCase` reads the start before `saveEvent` reloads.
- The iOS wiring in `AlarmService` (behind `Platform.isIOS`) and the SnackBar on the Settings screen have no automated tests. The manual checklists cover them.
- Android still wakes up for silent alarms on the day off (`nextValidAlarmTime` doesn't skip it). This is out of scope in the plan.
