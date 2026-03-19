# Project Context

## Current State (2026-03-19)

Active branch: `fix/critical-bugs` - just fixed 4 critical + 2 medium bugs (see `docs/fixes/2026-03-18-critical-bugs.md`). Not yet merged to `main`.

## Architecture Notes

### Two coexisting patterns

The codebase is in a gradual migration from flat services to feature-first Clean Architecture:
- Old: `lib/services/`, `lib/models/`, `lib/screens/` - static singletons, no injection
- New: `lib/features/<name>/` with domain/data/presentation layers and constructor injection

New features should follow the feature-first pattern. Domain layer must stay pure Dart (no Flutter imports).

### SharedPreferences keys

Flutter stores keys with `flutter.` prefix natively. Android native code must use `flutter.<key>` to read values written by Dart. Mismatch causes silent fallback to defaults - this was the root cause of the `getLong` vs `getInt` bug.

### Exercise system

`ExerciseRepository.kt` (Android only) tracks:
- `exercise_index` - round-robin position in exercise list
- `notifications_shown_count` - daily counter
- `last_notification_date` - date string for daily reset

Both `exercise_index` and `notifications_shown_count` must be reset together on new day detection. This was a bug in the original implementation.

## Dependencies (pubspec.yaml)

```
flutter_local_notifications: ^18.0.1  (latest: 21.0.0)
android_alarm_manager_plus: ^4.0.3    (latest: 5.0.0)
shared_preferences: ^2.3.4
permission_handler: ^11.3.1           (latest: 12.0.1)
timezone: ^0.9.4                      (latest: 0.11.0)
```

Several deps are behind. Not a blocking issue but worth noting for a maintenance pass.

## Tests

11 test files, ~1,600 lines. Coverage is good across services, domain logic, utilities, and models. Widget/integration coverage is minimal (1 file, 18 lines).

Test files map to:
- `test/services/` - alarm and storage services
- `test/models/` - user preferences
- `test/features/movement/` - domain + data layer tests
- `test/core/` - theme, time utils
- `test/widgets/` - work hours clock

## Change Plans

Completed plans in `docs/01_change_plans/`:
- Daily notification count tracking
- "I already moved" action
- System theme adaptation
- Exercise notifications
- Test refactoring
- Refactoring opportunities (partial - not all applied yet)

## Known Tech Debt

- `lib/screens/home_screen.dart` is large and handles too much. The refactoring change plan exists but hasn't been acted on.
- `StorageService` and `AlarmService` now use constructor injection. `NotificationService` remains static (platform-bridging glue code). Full Clean Architecture migration was evaluated and deemed not worth it for this app size.
- No Riverpod/Bloc - StatefulWidget + SharedPreferences for all state. Fine for current app size.
- iOS support exists but is less tested than Android. Exercise notifications are Android-only.
