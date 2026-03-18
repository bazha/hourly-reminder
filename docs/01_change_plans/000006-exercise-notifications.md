# Change Plan: Exercise Notifications with Sedentary Duration

**Status**: Applied

## Problem

Current notifications show static text "Время встать! ⏰".
There is no context about how long the user has been sedentary,
no specific exercise to perform, and no gender-aware text.

## Goal

1. Replace notification title with gender-aware sedentary duration text
2. First notification of the working day - no exercise shown
3. Subsequent notifications - include exercise with duration in expandable notification
4. Exercises shown in round-robin order (cyclic), office exercises by default
5. "First notification" reset - based on notification shown count per day
6. Gender setting: Neutral (default) / Male / Female

---

## Notification Text

| | Neutral (default) | Male | Female |
|---|---|---|---|
| Title (known duration) | Без движения X мин. | Ты не двигался X мин. | Ты не двигалась X мин. |
| Title (unknown duration) | Пора размяться | Пора размяться | Пора размяться |
| Text (first) | Время сделать перерыв 🚶 | Время сделать перерыв 🚶 | Время сделать перерыв 🚶 |
| Text (subsequent) | Время упражнения! 💪 | Время упражнения! 💪 | Время упражнения! 💪 |
| Button 1 | Через 10 минут | Через 10 минут | Через 10 минут |
| Button 2 | Я уже двигался | Я уже двигался | Я уже двигался |

**First notification (no exercise, unknown duration):**
```
Title: Пора размяться
Text:  Время сделать перерыв 🚶
```

**First notification (no exercise, known duration):**
```
Title: Без движения 60 мин.
Text:  Время сделать перерыв 🚶
```

**Subsequent notifications (expanded):**
```
Title:    Без движения 120 мин.
Text:     Время упражнения! 💪

Expanded:
          Повороты шеи
          Медленно поворачивай голову влево-вправо
          ⏱ 30 секунд
```

---

## Exercises (hardcoded, office-friendly)
```kotlin
val officeExercises = listOf(
    Exercise("Повороты шеи",      "Медленно поворачивай голову влево-вправо",              30),
    Exercise("Растяжка плеч",     "Потяни руку через грудь, держи 15 сек",                 30),
    Exercise("Растяжка запястий", "Вращай запястья по 10 раз в каждую сторону",            30),
    Exercise("Подъём на носки",   "Встань и поднимись на носки 15 раз",                    30),
    Exercise("Повороты корпуса",  "Сидя, повернись влево-вправо 10 раз",                   30),
    Exercise("Растяжка спины",    "Потянись руками вверх, держи 15 сек",                   30),
    Exercise("Сжатие плеч",       "Сведи лопатки вместе, держи 5 сек, повтори 10 раз",    30),
    Exercise("Наклоны головы",    "Наклони голову к плечу, держи 10 сек",                  20),
)
```

---

## SharedPreferences Keys

### New keys
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `flutter.exercise_index` | Int | `0` | Index of the next exercise to show |
| `flutter.notifications_shown_date` | String | `null` | Date of last notification shown "yyyy-MM-dd" |
| `flutter.notifications_shown_count` | Int | `0` | Number of notifications shown on that date |
| `flutter.notification_gender` | String | `"neutral"` | `"neutral"` / `"male"` / `"female"` |

### Existing keys used (no changes)
| Key | Description |
|-----|-------------|
| `flutter.movement_sedentary_start_millis` | Used to calculate sedentary minutes |

---

## Design Decisions

### Sedentary time reset on first notification of the day
`movement_sedentary_start_millis` is only set by `AlreadyMovedReceiver`. Without a reset,
the first morning notification would show stale duration from the previous day (e.g. 960 min).
Fix: when `isFirstNotificationToday()` is true, reset `movement_sedentary_start_millis` to
current time in `NotificationHelper.showReminder()`. The first notification of the day will
always show the fallback title ("Пора размяться") since sedentary tracking starts fresh.

### Unknown sedentary duration - hide minutes
When `movement_sedentary_start_millis` is 0 (fresh install, or just reset), show a generic
title "Пора размяться" instead of "Без движения 0 мин." This avoids confusing text.

### Snooze re-fires increment notification count
When `SnoozeReceiver` fires `showReminder()` again, it counts as a new notification. This means:
- A snoozed first-of-day notification will show an exercise on the re-fire.
- The exercise index advances on each snooze re-fire.
This is acceptable because the user has been sedentary even longer after snoozing.

---

## Affected Files

### New files (Kotlin)
- `android/app/src/main/kotlin/.../Exercise.kt` - data class
- `android/app/src/main/kotlin/.../ExerciseRepository.kt` - exercise list, round-robin logic, notification count tracking

### Modified files (Kotlin)
- `android/app/src/main/kotlin/.../NotificationHelper.kt`
  - Calculate sedentaryMinutes from `movement_sedentary_start_millis`
  - On first notification of the day: reset `movement_sedentary_start_millis` to now
  - When sedentary start is 0 or freshly reset: use fallback title "Пора размяться"
  - Read gender from `flutter.notification_gender`
  - Build gender-aware title (only when duration is known)
  - Check `isFirstNotificationToday()` to decide whether to show exercise
  - Record notification shown via `recordNotificationShown()`
  - Add `BigTextStyle` for exercise details on non-first notifications

### Modified files (Dart)
- `lib/models/user_preferences.dart`
  - Add `notificationGender` field (enum: `neutral` / `male` / `female`)
- `lib/services/storage_service.dart`
  - Add `notification_gender` key to load/save/sync getter
- `lib/screens/home_screen.dart`
  - Add `RadioListTile` group for gender selection below weekend toggles

### No changes needed
- `AlreadyMovedReceiver.kt` - gender/exercise logic is in `NotificationHelper`
- `ReminderReceiver.kt` - sedentary reset handled in `NotificationHelper`
- `SnoozeReceiver.kt` - calls `showReminder()` as before, which now increments count

---

## Implementation Steps

### Step 1 - Exercise.kt (Kotlin)
```kotlin
data class Exercise(
    val name: String,
    val description: String,
    val durationSeconds: Int,
)
```

### Step 2 - ExerciseRepository.kt (Kotlin)
```kotlin
object ExerciseRepository {

    private val exercises = listOf(
        Exercise("Повороты шеи",      "Медленно поворачивай голову влево-вправо",           30),
        Exercise("Растяжка плеч",     "Потяни руку через грудь, держи 15 сек",              30),
        Exercise("Растяжка запястий", "Вращай запястья по 10 раз в каждую сторону",         30),
        Exercise("Подъём на носки",   "Встань и поднимись на носки 15 раз",                 30),
        Exercise("Повороты корпуса",  "Сидя, повернись влево-вправо 10 раз",                30),
        Exercise("Растяжка спины",    "Потянись руками вверх, держи 15 сек",                30),
        Exercise("Сжатие плеч",       "Сведи лопатки вместе, держи 5 сек, повтори 10 раз", 30),
        Exercise("Наклоны головы",    "Наклони голову к плечу, держи 10 сек",               20),
    )

    fun isFirstNotificationToday(prefs: SharedPreferences): Boolean {
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val today = LocalDate.now().toString()
        if (savedDate != today) return true
        return prefs.getInt("flutter.notifications_shown_count", 0) == 0
    }

    fun recordNotificationShown(prefs: SharedPreferences) {
        val today = LocalDate.now().toString()
        val savedDate = prefs.getString("flutter.notifications_shown_date", null)
        val currentCount = if (savedDate == today) {
            prefs.getInt("flutter.notifications_shown_count", 0)
        } else {
            0 // new day - reset count
        }
        prefs.edit()
            .putString("flutter.notifications_shown_date", today)
            .putInt("flutter.notifications_shown_count", currentCount + 1)
            .apply()
    }

    fun getNextExercise(prefs: SharedPreferences): Exercise {
        val index = prefs.getInt("flutter.exercise_index", 0)
        val exercise = exercises[index % exercises.size]
        prefs.edit()
            .putInt("flutter.exercise_index", (index + 1) % exercises.size)
            .apply()
        return exercise
    }

    fun buildTitle(prefs: SharedPreferences, minutes: Long): String {
        // Unknown duration - generic fallback
        if (minutes <= 0L) return "Пора размяться"

        val gender = prefs.getString("flutter.notification_gender", "neutral")
        return when (gender) {
            "male"   -> "Ты не двигался $minutes мин."
            "female" -> "Ты не двигалась $minutes мин."
            else     -> "Без движения $minutes мин."
        }
    }
}
```

### Step 3 - NotificationHelper.kt
```kotlin
fun showReminder(context: Context) {
    ensureChannel(context)
    val prefs = context.getSharedPreferences(
        "FlutterSharedPreferences", Context.MODE_PRIVATE
    )

    val isFirst = ExerciseRepository.isFirstNotificationToday(prefs)

    // On first notification of the day, reset sedentary start to now.
    // This prevents stale overnight duration from showing.
    if (isFirst) {
        prefs.edit()
            .putLong("flutter.movement_sedentary_start_millis", System.currentTimeMillis())
            .apply()
    }

    val startMillis = prefs.getLong(
        "flutter.movement_sedentary_start_millis", 0L
    )
    val minutes = if (startMillis > 0L) {
        (System.currentTimeMillis() - startMillis) / 60_000L
    } else 0L

    val contentTitle = ExerciseRepository.buildTitle(prefs, minutes)

    // Snooze PendingIntent
    val snoozePendingIntent = PendingIntent.getBroadcast(
        context, 0,
        Intent(context, SnoozeReceiver::class.java).apply {
            action = SnoozeReceiver.ACTION_SNOOZE
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // Already moved PendingIntent
    val alreadyMovedPendingIntent = PendingIntent.getBroadcast(
        context, 1,
        Intent(context, AlreadyMovedReceiver::class.java).apply {
            action = AlreadyMovedReceiver.ACTION_ALREADY_MOVED
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val builder = NotificationCompat.Builder(context, CHANNEL_ID)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setContentTitle(contentTitle)
        .setContentText(
            if (isFirst) "Время сделать перерыв 🚶"
            else "Время упражнения! 💪"
        )
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setAutoCancel(true)
        .setColor(0xFF607D8B.toInt())
        .setVibrate(longArrayOf(0, 250, 250, 250))
        .addAction(0, "Через 10 минут", snoozePendingIntent)
        .addAction(0, "Я уже двигался", alreadyMovedPendingIntent)

    if (!isFirst) {
        val exercise = ExerciseRepository.getNextExercise(prefs)
        builder.setStyle(
            NotificationCompat.BigTextStyle()
                .bigText(
                    "${exercise.name}\n" +
                    "${exercise.description}\n" +
                    "⏱ ${exercise.durationSeconds} секунд"
                )
        )
    }

    // Record sent time for reaction time calculation
    prefs.edit()
        .putLong(
            "flutter.movement_last_notification_sent_millis",
            System.currentTimeMillis()
        )
        .apply()

    // Record notification shown AFTER checking isFirst
    ExerciseRepository.recordNotificationShown(prefs)

    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
        as NotificationManager
    nm.notify(NOTIFICATION_ID, builder.build())
}
```

### Step 4 - UserPreferences.dart
```dart
enum NotificationGender { neutral, male, female }

class UserPreferences {
  // ... existing fields ...
  final NotificationGender notificationGender;

  UserPreferences({
    // ... existing params ...
    this.notificationGender = NotificationGender.neutral,
  });

  UserPreferences copyWith({
    // ... existing params ...
    NotificationGender? notificationGender,
  }) {
    return UserPreferences(
      // ... existing fields ...
      notificationGender: notificationGender ?? this.notificationGender,
    );
  }
}
```

### Step 5 - StorageService.dart
```dart
// In loadPreferences():
notificationGender: _genderFromString(
    _prefs.getString('notification_gender') ?? 'neutral'
),

// In savePreferences():
await _prefs.setString(
    'notification_gender', prefs.notificationGender.name
),

// Helper:
static NotificationGender _genderFromString(String value) {
  return NotificationGender.values.firstWhere(
    (e) => e.name == value,
    orElse: () => NotificationGender.neutral,
  );
}
```

### Step 6 - HomeScreen.dart
Add below the Sunday toggle:
```dart
const Divider(height: 30),

Text(
  'Обращение в уведомлениях',
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  ),
),
const SizedBox(height: 8),

...NotificationGender.values.map((gender) {
  final label = switch (gender) {
    NotificationGender.neutral => 'Нейтральное  -  Без движения X мин.',
    NotificationGender.male    => 'Мужской род  -  Ты не двигался X мин.',
    NotificationGender.female  => 'Женский род  -  Ты не двигалась X мин.',
  };
  return RadioListTile<NotificationGender>(
    value: gender,
    groupValue: _prefs.notificationGender,
    onChanged: (value) => _updateGender(value!),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color: colors.textSecondary,
      ),
    ),
    activeColor: AppColors.primary,
    contentPadding: EdgeInsets.zero,
    dense: true,
  );
}),
```

Add handler:
```dart
Future<void> _updateGender(NotificationGender gender) async {
  setState(() {
    _prefs = _prefs.copyWith(notificationGender: gender);
  });
  await StorageService.savePreferences(_prefs);
}
```

---

## Testing Checklist

- [ ] First notification of the day - title "Пора размяться", no exercise, "Время сделать перерыв 🚶"
- [ ] First notification resets `movement_sedentary_start_millis` to now
- [ ] Second notification same day - shows sedentary minutes, exercise in expanded view
- [ ] Exercises appear in order across notifications
- [ ] After 8 exercises - cycle restarts from the beginning
- [ ] After midnight - resets to first notification (no exercise)
- [ ] Snooze re-fire increments notification count, advances exercise
- [ ] Snoozed first-of-day notification shows exercise on re-fire
- [ ] Fresh install (sedentaryStartMillis = 0) - title "Пора размяться", not "0 мин."
- [ ] Neutral gender title shows "Без движения X мин." (when duration known)
- [ ] Male gender title shows "Ты не двигался X мин."
- [ ] Female gender title shows "Ты не двигалась X мин."
- [ ] Gender change in UI - reflected in next notification immediately
- [ ] "Snooze" and "I already moved" buttons work as before
- [ ] `flutter analyze` - 0 issues
- [ ] `flutter test` - all tests pass

---

## Unit Tests

### New Dart tests - `test/models/user_preferences_test.dart`
- `notificationGender` defaults to `neutral`
- `copyWith` overrides `notificationGender`
- Equality includes `notificationGender`

### New Dart tests - `test/services/storage_service_test.dart`
- Persists `notificationGender` correctly for all three values
- Unknown string value falls back to `neutral`

### Kotlin side
Manual testing against checklist is sufficient for this version.

---

## Rollback Plan

Revert changes in `NotificationHelper.kt`, delete `Exercise.kt`
and `ExerciseRepository.kt`. Revert `UserPreferences`, `StorageService`,
`HomeScreen` to previous versions.
New SharedPreferences keys are safely ignored by the previous version.

---

## Notes

- `LocalDate` requires API 26+. Core library desugaring already enabled - no issues.
- Exercise index is not reset at midnight intentionally - user continues
  from where they left off across days.
- Exercise categories (active, standing) - separate future feature,
  added via settings toggle.
- Notification button text "Я уже двигался" stays gender-neutral for now.
  Can be updated when i18n is added.
- First notification of the day always shows "Пора размяться" because
  sedentary start is reset to now at that point (0 minutes elapsed).

---

## Estimated Scope

- 2 new Kotlin files (~70 lines)
- 1 modified Kotlin file (~50 lines of changes)
- 3 modified Dart files (~60 lines of changes)
