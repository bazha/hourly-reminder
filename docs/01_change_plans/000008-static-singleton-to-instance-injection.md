# 000008 - Convert Static Singletons to Instance Classes with Constructor Injection

## Background

Tech debt item #2 from `.claude/context.md`:
> Flat services pattern still used for most of the app. Only `movement` feature uses Clean Architecture.

After analysis, a full Clean Architecture migration is not worth it for this small app. The flat services are well-designed (68-138 lines), well-tested (125+ tests), and have clear responsibilities.

The actual problem is the **static singleton pattern**: `StorageService` holds `static late SharedPreferences _prefs` requiring `initialize()` before use, `MovementActionHandler` must check `isInitialized`, and tests rely on global `SharedPreferences.setMockInitialValues()`.

## Changes

Convert `StorageService` and `AlarmService` from static singletons to instance classes with constructor injection. Keep `NotificationService` static (complex platform init, no benefit from converting).

## Affected files

- `lib/services/storage_service.dart` - Convert to instance class
- `lib/services/alarm_service.dart` - Convert to instance class
- `lib/main.dart` - Create instances, pass through widget tree
- `lib/screens/home_screen.dart` - Accept services via constructor
- `lib/features/movement/presentation/movement_action_handler.dart` - Accept services, remove `isInitialized` check
- `lib/services/notification_service.dart` - Update to use passed instances
- `test/services/storage_service_test.dart` - Instance-based testing
- `test/services/alarm_service_test.dart` - Minimal changes (pure functions stay static)

## Implementation steps

1. Convert `StorageService`: remove `static`/`late`/`_initialized`/`initialize()`, add `final SharedPreferences _prefs` constructor param
2. Convert `AlarmService`: remove `static` from non-pure methods, keep pure functions (`shouldSendReminder`, `nextNotificationTime`) static
3. Wire in `main.dart`: create instances after `SharedPreferences.getInstance()`, pass to `HourlyReminderApp`
4. Update `HomeScreen` to receive services via constructor
5. Update `MovementActionHandler` to accept `AlarmService`, remove `isInitialized` check
6. Update `NotificationService` to use passed instances where it references `StorageService`/`AlarmService`
7. Update all tests

## What stays the same

- `NotificationService` stays static
- `UserPreferences` stays in `lib/models/`
- No new folders, interfaces, or use case classes
- Folder structure unchanged

## Testing

- `flutter analyze` - zero issues
- `flutter test` - all existing tests pass
- `flutter build apk --debug` - builds
- Manual: toggle reminders, change hours, verify notifications
