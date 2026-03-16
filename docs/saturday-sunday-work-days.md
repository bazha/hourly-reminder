# Saturday / Sunday as Independent Work Days

## Summary

Replaced the single "exclude weekends" toggle with two independent booleans — **workOnSaturday** and **workOnSunday** — so users can configure each weekend day separately.

Default: both `false` (no reminders on Saturday or Sunday), preserving the existing behaviour.

---

## Changes

| File | What changed |
|---|---|
| `lib/models/user_preferences.dart` | Replaced `excludeWeekends` with `workOnSaturday` + `workOnSunday` fields; both default `false` |
| `lib/services/storage_service.dart` | New keys `work_on_saturday` / `work_on_sunday`; two new sync getters; removed `exclude_weekends` |
| `lib/services/alarm_service.dart` | `shouldSendReminder` and `nextNotificationTime` accept the two new params; `alarmCallback` passes them from `StorageService` |
| `lib/screens/home_screen.dart` | Two separate `Switch` rows replace the single weekend toggle |
| `test/services/alarm_service_test.dart` | Weekend tests rewritten as a 2×2 grid; `nextNotificationTime` weekend tests added |
| `test/models/user_preferences_test.dart` | `copyWith` + equality tests updated for both new fields |
| `test/services/storage_service_test.dart` | Persist + sync-getter tests updated for both new keys |

---

## Logic

### `shouldSendReminder`

```dart
if (day == 6 && !workOnSaturday) return false;  // Saturday off
if (day == 7 && !workOnSunday)   return false;  // Sunday off
```

### `nextNotificationTime` — day validity

```dart
bool _isDayValid(int weekday) =>
    (weekday != 6 && weekday != 7) ||   // weekday: always valid
    (weekday == 6 && workOnSaturday) ||
    (weekday == 7 && workOnSunday);
```

---

## Behaviour Matrix

| workOnSaturday | workOnSunday | Mon–Fri | Sat | Sun |
|:-:|:-:|:-:|:-:|:-:|
| false | false | ✓ | ✗ | ✗ |
| true  | false | ✓ | ✓ | ✗ |
| false | true  | ✓ | ✗ | ✓ |
| true  | true  | ✓ | ✓ | ✓ |

---

## Storage Keys

| Key | Type | Default |
|---|---|---|
| `work_on_saturday` | bool | `false` |
| `work_on_sunday` | bool | `false` |

The old key `exclude_weekends` is no longer written or read. Users upgrading from an older build will see both days default to `false` (off), which matches the previous default of excluding weekends.
