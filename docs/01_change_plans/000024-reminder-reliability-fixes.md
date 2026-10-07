# 000024 - Reminder Reliability Fixes

## Status: APPLIED (manual device testing pending)

## Background

Items 1-5 from the repository audit on 2026-10-07. Each problem is marked:
- **reproduced**: confirmed by running code (scratch scripts, `TZ=Europe/Berlin`);
- **code reading**: found by reading, not run.

1. **Disabling or day off does not stop everything** (code reading). `ReminderScheduler.cancel()` cancels only request code 100. The snooze alarm (200) and the settling alarm (150) survive. `SnoozeReceiver` shows the snoozed notification without checking `is_enabled` or the day off. `ReminderReceiver` reschedules the chain on line 19, before the `is_enabled` check on line 24, so a surviving alarm brings the chain back while reminders are off. On iOS `IosReminderScheduler.cancel()` touches ids 100-159 only, so the snooze (id 2) survives.
2. **Day arithmetic breaks on DST switches** (reproduced). The code steps through days with `Duration(days: 1)` and builds times with `midnight.add(Duration(minutes: n))`. On a DST switch day this lands on 23:00 or 01:00, or shifts the time by an hour. Results under `TZ=Europe/Berlin`:
   - Stats, 8 work days in a row with movements across 2026-10-25: current streak 3 instead of 8, best 5 instead of 8, 5 weekly bars show 0.
   - `nextNotificationTime` on Sunday 2026-03-29 with work hours 9-18: 11:00 instead of 10:00. Kotlin uses `Calendar.set` and gets 10:00, so the two pipelines disagree.
   - `formatNextReminder` on Sunday 2026-03-29 evening: Monday is 23 hours away, `inDays` is 0, so the banner says "today" for tomorrow's reminder.

   Minsk has no DST, which is why the existing tests pass.
3. **`saveEvent` can drop an event written by the other side** (code reading). `MovementLocalDatasource.saveEvent()` reads the list from the Dart cache without `reload()`, appends and writes the whole list back. `getEvents()` already reloads, with a comment explaining why. Scenario: app in the foreground, the user taps "Уже размялся" on a heads-up notification (Kotlin appends an event), then taps the manual button in the app. Dart writes its stale list and the event from the notification is lost. Same on iOS, where the action runs in a background engine.
4. **iOS reminders stop silently** (code reading). The queue holds 60 reminders. At a 15-minute interval and 9-18 hours that is about 36 a day, so the queue lasts less than 2 work days. It is refilled only when the app opens or on "Уже размялся". Snooze and ignored notifications do not refill it. The user gets no signal when it runs out.
5. **Work hours that fit no reminder are accepted silently** (reproduced). `pickTime()` and the interval picker do not check that `start + interval <= end`. With 18:00-09:00, or 9:00-10:00 at 120 minutes, `nextNotificationTime()` returns `null`. The toggle stays on, the banner says "Напоминания выключены", nothing arrives.

The five batches are independent. Each can be implemented, committed and reverted on its own.

## Batch 1: Disabling and day off stop everything

### Decisions

- A snoozed notification is **not** checked against work hours. The user asked to be reminded in 10 minutes, so it shows even if work ended in between. It **is** checked against `is_enabled` and the day off.
- Android checks at fire time (receivers run code). iOS runs no code when a notification fires, so it checks when the snooze is requested, and cancels a pending snooze when reminders are turned off or the day off is turned on.
- `IosReminderScheduler.cancel()` keeps its current meaning (reminders only, snooze kept), because the existing test `cancel keeps a pending snooze` covers it. A new `cancelSnooze()` is called next to it where needed.

### Android

| File | Change |
|------|--------|
| `android/.../PrefsExt.kt` | Add `fun SharedPreferences.isDayOffToday(): Boolean = getString(PrefsKeys.DAY_OFF_DATE, null) == LocalDate.now().toString()`. `LocalDate` is already used in `ExerciseRepository` (desugaring is on). It also replaces `String.format` without `Locale`, which could produce non-ASCII digits |
| `android/.../ReminderScheduler.kt` | Make the PendingIntent builders shared: `hourlyPendingIntent(context)` (code 100) and new `settlingPendingIntent(context)` (code 150). `cancel()` cancels hourly, settling and snooze (`SnoozeReceiver.snoozePendingIntent`). Schedule and cancel must use the same builders, otherwise `AlarmManager.cancel` does not match |
| `android/.../ReminderReceiver.kt` | Read `is_enabled` first and return before `scheduleNextHourlyAlarm()` when it is off, so the chain ends. Replace the inline day-off code with `isDayOffToday()`. `scheduleSettlingAlarm` uses `ReminderScheduler.settlingPendingIntent` |
| `android/.../SnoozeReceiver.kt` | Move the snooze PendingIntent into `companion fun snoozePendingIntent(context)`. In `ACTION_SHOW_SNOOZED`, return without showing when `is_enabled` is false or `isDayOffToday()` |
| `android/.../AlreadyMovedReceiver.kt` | Replace the inline day-off code with `isDayOffToday()`. Still record the event when reminders are off, but skip scheduling. `scheduleNextReminder` uses `ReminderScheduler.hourlyPendingIntent` |

### iOS (Dart)

| File | Change |
|------|--------|
| `lib/services/ios_reminder_scheduler.dart` | Add `static const snoozeId = 2` and `Future<void> cancelSnooze()` |
| `lib/services/notification_service.dart` | Use `IosReminderScheduler.snoozeId` instead of the private `_snoozeNotificationId`. `_snoozeForIos()`: reload prefs, then skip scheduling when reminders are off or today is the day off. Otherwise a snooze tapped on an old notification in Notification Center after the day off was turned on would still fire, and nothing would cancel it |
| `lib/services/alarm_service.dart` | `cancelAlarm()` on iOS: `cancel()` then `cancelSnooze()` inside `_serializeIos`. `_scheduleIos()`: when reminders are off, also `cancelSnooze()`. When `storage.isDayOff`, call `cancelSnooze()` before scheduling |

## Batch 2: Calendar-day arithmetic

Rule: step through days and build wall-clock times with the `DateTime` constructor, which normalizes overflow (`DateTime(y, m, d - 1)`, `DateTime(y, m, d, 0, 600)`). Use `Duration` only for real elapsed time.

Checked during the audit under `TZ=Europe/Berlin`:
- Stats: a patched copy of the real use case gave streak 8 and all bars on midnight dates with correct counts.
- `nextNotificationTime`: a reimplementation with the same branches and `DateTime(y, m, d, 0, minutes)` gave 10:00. The real function was not patched, so the new unit tests are the real check.

| File | Change |
|------|--------|
| `lib/features/movement_stats/domain/usecases/get_movement_stats_use_case.dart` | Add private `_previousDay(d)` / `_nextDay(d)` built with `DateTime(d.year, d.month, d.day - 1)` and `d.day + 1`. Replace all 10 `subtract/add(const Duration(days: 1))` calls (lines 101-194) |
| `lib/services/alarm_service.dart` | In `nextNotificationTime`: add `_atMinute(day, minuteOfDay) => DateTime(day.year, day.month, day.day, 0, minuteOfDay)` and use it for all 4 `.add(Duration(minutes: ...))` sites. Build the next-day candidate as `DateTime(now.year, now.month, now.day + i)` instead of adding `Duration(days: 1)` |
| `lib/core/utils/time_utils.dart` | `formatNextReminder`: compute the day difference on UTC dates: `DateTime.utc(next.year, next.month, next.day).difference(DateTime.utc(now.year, now.month, now.day)).inDays` |

Kotlin already uses `Calendar` and needs no change.

## Batch 3: Reload before saving an event

| File | Change |
|------|--------|
| `lib/features/movement/data/datasources/movement_local_datasource.dart` | `saveEvent()`: `await _prefs.reload()` before reading the list. Extend the comment in `getEvents()` to cover both methods |

This narrows the race to a few milliseconds but does not close it: two processes still do read-modify-write on one key. Closing it fully needs one owner of the event storage (see Out of scope).

## Batch 4: iOS "reminders paused" notification

### Design

- `AlarmService._scheduleIos()` asks for `maxReminders + 1` times.
- `IosReminderScheduler.schedule(times)` schedules the first 60 as reminders, as today. If there is a 61st time, it schedules one more notification at that time with id `pausedId = 3`:
  - title `notificationPausedTitle`, body `notificationPausedBody`;
  - no category (no action buttons);
  - payload = its scheduled time, so `_isUpToDate` can compare it.
- If there is no 61st time, a pending paused notification is cancelled. It is cancelled **only if it is pending**, so the existing test `overwrites in place and cancels only leftover reminders` (expects `cancelledIds == [102]`) stays valid.
- `cancel()` also cancels the paused notification if pending.
- `_isUpToDate` also compares the paused notification (present or absent, payload, text).
- Every refill moves the paused notification forward, so a user who opens the app now and then never sees it.
- iOS limit: 60 reminders + test (1) + snooze (2) + paused (3) = 63 of 64.
- `pendingTimes()` reads ids 100-159 only, so the refill anchor ignores id 3.
- A tap on the paused notification opens the app, and `main()` refills the queue.

Texts:

| Key | ru | be | en |
|-----|----|----|----|
| `notificationPausedTitle` | Напоминания на паузе | Нагадванні на паўзе | Reminders paused |
| `notificationPausedBody` | Откройте приложение, чтобы напоминания продолжились | Адкрыйце праграму, каб нагадванні працягваліся | Open the app to keep getting reminders |

| File | Change |
|------|--------|
| `lib/services/ios_reminder_scheduler.dart` | `pausedId`, paused notification in `schedule()`, `_isUpToDate()`, `cancel()` as above |
| `lib/services/alarm_service.dart` | `_scheduleIos()` passes `limit: IosReminderScheduler.maxReminders + 1` |
| `lib/l10n/app_ru.arb`, `app_be.arb`, `app_en.arb` | Two new keys |
| `lib/l10n/app_localizations*.dart` | Regenerate with `flutter gen-l10n` (generated files are tracked) |
| `.claude/context.md` | iOS section and Known Tech Debt: the queue still runs out, but the user is told |

Android needs nothing: its alarm chain reschedules itself.

## Batch 5: Warn when work hours fit no reminder

### Design

- One rule, the same one `nextNotificationTime` and Kotlin already use: at least one reminder fits if `start + interval <= end`. It covers end before start, end equal to start, and an interval longer than the window.
- **Decision (needs approval): warn and save, do not reject.** Start and end are edited one at a time, so rejecting would trap valid edits:
  - hours 9-18, target 20-23: setting start to 20:00 first gives 20-18 and would be rejected, the user has to change the end first;
  - hours 9-18, target 5-8: setting end to 8:00 first gives 9-8, same problem in reverse.
  So every change is saved. If the result fits no reminder, a SnackBar with `noReminderFits` is shown.
- While reminders are on and the settings fit no reminder, the home banner shows `noReminderFits` (warning icon) instead of "Напоминания выключены". This also covers settings that are already stored invalid.
- Alternative: reject the change. Simpler state, but it needs a hint about the editing order and still traps the user without one.

| Key | ru | be | en |
|-----|----|----|----|
| `noReminderFits` | Напоминания не помещаются в рабочие часы | Нагадванні не змяшчаюцца ў працоўныя гадзіны | No reminder fits into your work hours |

| File | Change |
|------|--------|
| `lib/models/user_preferences.dart` | `bool get hasReminderWindow => startHour * 60 + startMinute + reminderIntervalMinutes <= endHour * 60 + endMinute;` |
| `lib/screens/widgets/settings_card.dart` | `void showNoReminderFitsSnackBar(BuildContext context)` next to `pickTime` |
| `lib/screens/home_screen.dart` | `_updateTime`: save as today, then if `!updated.hasReminderWindow`, show the SnackBar. `_NextReminderBanner`: if `prefs.isEnabled && !prefs.hasReminderWindow`, show `noReminderFits` |
| `lib/screens/settings_screen.dart` | Same check after saving in `_updateTime` and `_updateInterval`. The interval sheet commits once on its button and closes, so one SnackBar per change |
| `lib/l10n/*.arb` + generated files | One new key |

## Out of scope

- Night shifts (work hours that cross midnight).
- Kotlin unit tests. The project has no Android test setup, and adding test dependencies needs a separate discussion (same as 000023).
- Teaching `ReminderScheduler.nextValidAlarmTime()` to skip the day off (Android still wakes up for silent alarms on that day).
- `AlreadyMovedReceiver` dropping the movement event on the day off (current behavior is kept).
- One owner for movement event storage (SQLite or native-only writes) to close the race in Batch 3 fully.
- Background App Refresh on iOS.
- Release blockers: debug signing, `USE_EXACT_ALARM`, the unused battery permission and channel. Separate plan.
- The test notification writing real stats data.

## Implementation Steps

1. Batch 2 (pure Dart, fastest feedback): tests first, check they fail under `TZ=Europe/Berlin`, then fix.
2. Batch 3: test first, then the one-line fix.
3. Batch 1: Kotlin changes, then the iOS `cancelSnooze()` with its test.
4. Batch 5: model getter with tests, then the screens and texts.
5. Batch 4: scheduler changes with tests, texts, `context.md`.
6. Run `flutter analyze`, then `flutter test`, `TZ=Europe/Berlin flutter test` and `TZ=America/New_York flutter test`.
7. `flutter build apk --debug`.
8. Update `.claude/context.md` (DST rule, TZ test command) and the README if behavior described there changes.
9. Write the completion report `000024-reminder-reliability-fixes-report.md`.

## Tests

The DST tests (Batch 2) only fail under a time zone with DST. In Minsk they pass before and after the fix. Run the suite under `TZ=Europe/Berlin` as part of every batch. The `TZ` variable works with `flutter test` on macOS.

Baseline, checked on 2026-10-07 before any change: the current 86 tests pass under `TZ=Europe/Berlin` and `TZ=America/New_York`. So "existing tests pass unchanged" is achievable in all three zones.

Suggestion, needs your approval: add `TZ=Europe/Berlin flutter test` to the build commands in `.claude/CLAUDE.md`.

### Unit (new)

`test/features/movement_stats/domain/usecases/get_movement_stats_use_case_test.dart`, group `DST switch`:
- [x] Streak across the fall-back switch (2026-10-19..2026-10-28, Mon-Fri): current and best are 8
- [x] Streak across the spring-forward switch (2026-03-23..2026-04-01): current and best are 8
- [x] Weekly stats across a switch: every date is a midnight, counts match the events

`test/services/alarm_service_test.dart`:
- [x] `nextNotificationTime` at 07:00 on 2026-03-29 and 2026-10-25 (Sunday as a work day, hours 9-18) returns 10:00
- [x] `upcomingNotificationTimes` over a week that contains a switch: every time is inside 10:00-18:00 local, no 11:00-19:00 drift
- [x] `upcomingNotificationTimes` with `limit: 61` returns 61 times (Batch 4 relies on it)

`test/core/utils/time_utils_test.dart`:
- [x] `formatNextReminder` with now = 2026-03-29 20:00 and next = 2026-03-30 10:00 returns the "tomorrow" text

`test/features/movement/data/datasources/movement_local_datasource_test.dart` (new file):
- [x] An event written behind the Dart cache is kept: save A, then `SharedPreferences.setMockInitialValues` with [A, B] (the old `prefs` instance keeps its stale cache, the store now has B, like a native write), then save C. `getEvents()` returns A, B, C. Without the fix it returns A, C

`test/services/ios_reminder_scheduler_test.dart`:
- [x] `cancelSnooze()` removes id 2 and keeps reminders
- [x] 61 times: ids 100-159 are reminders, id 3 is pending with the 61st time as payload and the paused text
- [x] Then 30 times: id 3 is cancelled
- [x] Rescheduling the same 61 times is a no-op (`scheduledIds` empty)
- [x] `cancel()` removes id 3 and still keeps the snooze

`test/models/user_preferences_test.dart`:
- [x] `hasReminderWindow`: defaults true. Start 18:00 / end 09:00 false. 9:00-10:00 with 120 min false. 9:00-10:00 with 60 min true (boundary)

All existing tests must pass unchanged.

### Manual, Android device or emulator

- [ ] Snooze, then turn reminders off: nothing after 10 minutes
- [ ] Snooze, then turn on the day off: nothing after 10 minutes
- [ ] Turn reminders off: `adb shell dumpsys alarm | grep hourly_reminder` shows no pending alarms
- [ ] Turn reminders on again: the next alarm is scheduled
- [ ] Regular chain, snooze and "Уже размялся" still work with reminders on
- [ ] Set end before start, or interval longer than the window: value saved, SnackBar shown, home banner shows the warning
- [ ] Move hours from 9-18 to 20-23 by changing start first, then end: both changes saved, the warning disappears after the second one

### Manual, iOS simulator or device

- [ ] Snooze, then turn reminders off: id 2 is not pending, nothing arrives
- [ ] Snooze, then turn on the day off: same
- [ ] Turn on the day off, then tap Snooze on an older notification still in Notification Center: no snooze is scheduled (id 2 not pending)
- [ ] Interval 15 min: id 3 is pending at the 61st slot. Open the app later: id 3 moves forward
- [ ] Tap the paused notification: the app opens and the queue is refilled
- [ ] Same work hours checks as on Android

## Rollback Plan

Each batch is a separate commit and can be reverted on its own.

Batch 4: after a rollback, a paused notification (id 3) may stay pending on devices, because the old build never cancels it. The user would see one stale "Напоминания на паузе" message. If that matters, the rollback build should cancel id 3 once at startup.

## Benefits and Estimated Time

- Turning reminders off or taking a day off stops all notifications on both platforms.
- Stats and reminder times are correct for users in time zones with DST. Dart and Kotlin agree again.
- Movement events are not lost in the common foreground case.
- iOS users are told when reminders are about to stop, instead of losing them silently.
- Work hours that fit no reminder are explained on screen instead of looking like "reminders disabled".

Estimated time:

| Batch | Time |
|-------|------|
| 1. Disabling and day off | 0.5 day + manual testing on both platforms |
| 2. Calendar arithmetic | 2-3 hours |
| 3. Reload before save | 30 minutes |
| 4. iOS paused notification | 3-4 hours |
| 5. Work hours check | 2-3 hours |

Total: about 2 days including manual testing.
