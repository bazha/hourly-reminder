# TASK

Implement semi-adaptive logic for the "I already moved" notification action in a Flutter mobile app.

---

# FUNCTIONAL BEHAVIOR

When user presses "I already moved":

1. Calculate reactionTime = now - notificationSentTime
2. Calculate sedentaryDuration = now - sedentaryStartTime
3. Persist MovementEvent
4. Compute nextInterval using semi-adaptive rule
5. Schedule next notification at now + nextInterval
6. Update sedentaryStartTime = now

---

# SEMI-ADAPTIVE RULE

If reactionTime <= 3 minutes:
    return 30 minutes

Else:
    return 45 minutes

This logic MUST exist as a pure function inside domain layer.

No side effects.
No Flutter imports.

---

# ARCHITECTURE (STRICT)

Use 4 layers:

## 1. Domain (pure Dart only)
Allowed:
- Entities
- Value objects
- Pure services

Forbidden:
- Flutter imports
- Local storage
- Notification plugins
- DateTime.now() inside pure functions

---

## 2. Application
- UseCase: ConfirmMovementUseCase
- Orchestrates flow
- Inject dependencies via constructor
- No direct plugin usage

---

## 3. Infrastructure
- MovementRepository (local persistence)
- NotificationScheduler (flutter_local_notifications)
- WorkingHoursPolicy

Must implement interfaces defined in domain/application.

---

## 4. Presentation
- Calls ConfirmMovementUseCase only
- No business logic
- No duration calculations
- No scheduling logic

---

# TECHNICAL CONSTRAINTS

- Null safety required
- No global singletons
- No static mutable state
- No external state management frameworks
- No backend
- Must survive app restart (persist sedentaryStartTime)
- Must respect working hours
- Must not schedule outside working window

---

# DATA MODEL

MovementEvent:
- id (String)
- timestamp (DateTime)
- sedentaryDuration (Duration)
- reactionTime (Duration)
- source (enum: notification, manual)

---

# REQUIRED FILE STRUCTURE

Provide folder structure:

```
lib/
├── core/
│   ├── extensions/
│   ├── utils/
│   ├── errors/        # Either/Failure types
│   └── constants/
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/        # JSON serializable
│       │   └── repositories/  # impl
│       ├── domain/
│       │   ├── entities/      # pure Dart
│       │   ├── repositories/  # abstract
│       │   └── usecases/
│       └── presentation/
│           ├── providers/     # Riverpod
│           ├── screens/
│           └── widgets/
├── shared/
│   └── widgets/
└── main.dart

```
---

# OUTPUT FORMAT (STRICT)

1. Show folder structure
2. Then show each file separately
3. Each file must be in its own code block
4. No explanatory text between files
5. After all files, provide:
   - Unit tests for IntervalCalculator
   - Short architecture explanation (max 10 bullet points)

---

# NON-GOALS

- No analytics
- No gamification
- No DI frameworks
- No Bloc/Riverpod
- No unnecessary abstractions
- No additional adaptive logic

---

# QUALITY REQUIREMENTS

- Deterministic
- Testable
- Clean separation of concerns
- Easy to extend adaptive rule later
- Production-ready code
- Minimal but complete implementation
