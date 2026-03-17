# Change Plan: "I Already Moved" Notification Action

**Status**: Applied

## Problem

Users receive hourly movement reminders but have no way to tell the app they already moved. This leads to unnecessary reminders. We need a notification action button "I already moved" that uses a semi-adaptive rule to adjust the next reminder interval based on reaction time.

## Architecture

4-layer feature-first structure under `lib/features/movement/`:

```
lib/features/movement/
├── domain/
│   ├── entities/
│   │   └── movement_event.dart          # MovementEvent entity
│   ├── repositories/
│   │   └── movement_repository.dart     # Abstract repository interface
│   └── usecases/
│       ├── interval_calculator.dart      # Pure function: semi-adaptive rule
│       └── confirm_movement_use_case.dart
├── data/
│   ├── models/
│   │   └── movement_event_model.dart    # JSON serializable model
│   ├── datasources/
│   │   └── movement_local_datasource.dart
│   └── repositories/
│       └── movement_repository_impl.dart
└── presentation/
    └── movement_action_handler.dart     # Wires notification action to use case
```

### Layer responsibilities

**Domain (pure Dart, no Flutter imports):**
- `MovementEvent` - entity with id, timestamp, sedentaryDuration, reactionTime, source
- `MovementSource` - enum: notification, manual
- `IntervalCalculator.compute(reactionTime)` - pure function returning Duration
  - reactionTime <= 3min returns 30min
  - reactionTime > 3min returns 45min
- `MovementRepository` - abstract interface for persistence + sedentary tracking

**Application (use case):**
- `ConfirmMovementUseCase` - injected with MovementRepository and a scheduling callback
  - Calculates reactionTime = now - notificationSentTime
  - Calculates sedentaryDuration = now - sedentaryStartTime
  - Persists MovementEvent
  - Computes nextInterval via IntervalCalculator
  - Delegates scheduling of next notification
  - Resets sedentaryStartTime = now

**Data (infrastructure):**
- `MovementEventModel` - JSON serializable, converts to/from entity
- `MovementLocalDatasource` - SharedPreferences: stores sedentaryStartTime, lastNotificationSentTime, event log
- `MovementRepositoryImpl` - implements MovementRepository using datasource

**Presentation:**
- `MovementActionHandler` - static method called from notification action callback
  - Instantiates dependencies and calls use case
  - Bridges to existing AlarmService/NotificationService for scheduling

## Changes to existing files

1. **`lib/services/notification_service.dart`** - Add "I already moved" action button to notifications (both Android and iOS). Add action callback that routes to `MovementActionHandler`.

2. **`lib/services/storage_service.dart`** - Add keys for `sedentaryStartTime` and `lastNotificationSentTime`. Add getters/setters.

3. **`lib/main.dart`** - Initialize sedentaryStartTime on first launch. Wire notification action response handler.

## New files

1. `lib/features/movement/domain/entities/movement_event.dart`
2. `lib/features/movement/domain/repositories/movement_repository.dart`
3. `lib/features/movement/domain/usecases/interval_calculator.dart`
4. `lib/features/movement/domain/usecases/confirm_movement_use_case.dart`
5. `lib/features/movement/data/models/movement_event_model.dart`
6. `lib/features/movement/data/datasources/movement_local_datasource.dart`
7. `lib/features/movement/data/repositories/movement_repository_impl.dart`
8. `lib/features/movement/presentation/movement_action_handler.dart`

## Tests

1. `test/features/movement/domain/usecases/interval_calculator_test.dart` - Unit tests for pure function:
   - reactionTime 0s returns 30min
   - reactionTime 2min returns 30min
   - reactionTime exactly 3min returns 30min
   - reactionTime 3min01s returns 45min
   - reactionTime 10min returns 45min
   - reactionTime 1h returns 45min

2. `test/features/movement/domain/usecases/confirm_movement_use_case_test.dart` - Unit tests with mocked repository:
   - Persists correct MovementEvent
   - Returns 30min interval for fast reaction
   - Returns 45min interval for slow reaction
   - Resets sedentary start time

3. `test/features/movement/data/models/movement_event_model_test.dart` - JSON round-trip tests

4. `test/features/movement/domain/entities/movement_event_test.dart` - Entity creation tests

## Working hours constraint

The use case must respect working hours. If `now + nextInterval` falls outside the work window, the notification should be scheduled at the next work window start instead. This delegates to existing `AlarmService.nextNotificationTime()` logic.

## Rollback plan

All new code lives in `lib/features/movement/` and `test/features/movement/`. Removing the feature directory and reverting the 3 modified files restores the previous state.

## Estimated scope

- 8 new files (feature code)
- 4 new test files
- 3 modified existing files
- ~400-500 lines of new code + tests
