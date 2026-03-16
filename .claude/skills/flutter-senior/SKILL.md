---
name: flutter-senior
description: >
  Expert Flutter development guidance for a senior engineer (15+ years). Use this skill
  whenever working on Flutter or Dart code, mobile architecture, platform-specific integrations,
  state management, performance tuning, CI/CD for mobile, or any cross-platform concern.
  Trigger for: widget design, Riverpod/Bloc/Cubit patterns, platform channels, FFI, isolates,
  flavors, native Android/iOS integration, app store publishing, Firebase alternatives,
  local notifications, background tasks, golden tests, and Dart package authoring.
  Always apply: production-grade, scalable solutions with trade-offs stated.
---

# Flutter Senior Developer Skill

## Developer Profile

- **Experience**: 15+ years software engineering, senior/architect level
- **Flutter**: Production apps shipped, deep platform knowledge
- **Assumes familiarity with**: Dart null safety, async/await, generics, OOP, DI patterns
- **Communication style**: Skip basics. Lead with trade-offs, production concerns, gotchas.
- **Code examples**: Full, runnable, production-quality. No toy snippets.

---

## Core Principles

1. **Null safety first** — Dart 3.x patterns, no legacy `?? throw` hacks
2. **Separation of concerns** — UI knows nothing about business logic or data sources
3. **Testability by design** — injectable dependencies, no static singletons in logic
4. **Platform-aware** — Android/iOS diverge; always flag when behavior differs
5. **Performance by default** — const constructors, sliver layouts, isolates for CPU work
6. **Minimal dependencies** — prefer dart-native solutions; justify every pub.dev package

---

## Architecture Defaults

### Preferred Stack

| Layer | Default Choice | Alternative |
|---|---|---|
| State management | Riverpod 2.x (code-gen) | Bloc/Cubit |
| DI | Riverpod providers / get_it | injectable |
| Navigation | go_router | auto_route |
| Local DB | Isar / drift | sqflite |
| Networking | dio + retrofit | http + manual |
| Local notifications | flutter_local_notifications | without Firebase |
| Background tasks | workmanager | android_alarm_manager_plus |
| Storage | flutter_secure_storage / shared_preferences | hive |

### Project Structure (feature-first)
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

## Code Style & Patterns

### Riverpod 2.x (code-gen preferred)
```dart
// Always use @riverpod annotation over manual providers
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() => _fetchInitialState();

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }
}
```

### Error handling — Result type (no exceptions in business logic)
```dart
// Use fpdart or custom Either; never throw across layer boundaries
typedef Result<T> = Either<Failure, T>;

sealed class Failure {
  const Failure(this.message);
  final String message;
}
final class NetworkFailure extends Failure { ... }
final class CacheFailure extends Failure { ... }
```

### Platform channels — always typed
```dart
// Define contract in Dart, implement natively on both platforms
abstract class BiometricService {
  Future<bool> authenticate({required String reason});
}

// platform_channel_biometric.dart
class PlatformBiometricService implements BiometricService {
  static const _channel = MethodChannel('com.yourapp/biometric');

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _channel.invokeMethod<bool>('authenticate', {'reason': reason}) ?? false;
    } on PlatformException catch (e) {
      throw BiometricFailure(e.message ?? 'Unknown platform error');
    }
  }
}
```

---

## Platform-Specific Pitfalls

### Android

- **Exact alarms (API 31+)**: Requires `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM` — request at runtime; fallback to inexact with user explanation
- **Doze mode**: `WorkManager` is Doze-safe; `AlarmManager` is NOT unless using `setAndAllowWhileIdle` + foreground service combo
- **Boot receiver**: Register `BOOT_COMPLETED` + `QUICKBOOT_POWERON` (for some OEMs); reschedule all alarms on boot
- **Notification channels** (API 26+): Create channels before posting; channel importance is user-locked after first creation
- **Foreground services** (API 34+): Must declare `foregroundServiceType` in manifest
- **AGP 8.x**: R8 full mode enabled by default; add keep rules for reflection-heavy libs (Gson, Hive adapters)

### iOS

- **64-notification limit**: `UNUserNotificationCenter` hard cap; implement LRU eviction or dynamic scheduling
- **Background fetch**: Unreliable by design (OS-controlled); never promise exact timing to users
- **Critical alerts**: Require Apple entitlement; separate permission request flow
- **Privacy manifests** (iOS 17+): Required for apps using certain APIs (UserDefaults, FileTimestamp, etc.)
- **Bitcode**: Removed in Xcode 14+; remove any remaining bitcode flags

### Both

- **Timezone scheduling**: Always store UTC + IANA timezone ID; compute local fire time at scheduling time AND after timezone changes. Listen to `tz` package for DST transitions.
- **Permission timing**: Request at the moment of need (contextual), not on app launch
- **Deep links**: Test `http` scheme (universal/app links) AND custom scheme; they have different iOS entitlement requirements

---

## Testing Strategy
```
Unit tests       → domain layer, use cases, pure Dart logic
Widget tests     → presentation layer, golden tests for UI regression  
Integration tests → critical user journeys (patrol or flutter_test driver)
```

### Golden test setup
```dart
// Use alchemist or golden_toolkit for multi-theme/locale variants
testGoldens('LoginScreen renders correctly', (tester) async {
  await tester.pumpWidgetBuilder(
    const LoginScreen(),
    wrapper: materialAppWrapper(theme: AppThemes.light),
  );
  await screenMatchesGolden(tester, 'login_screen_light');
});
```

### Mocking — prefer mockito with code-gen
```dart
@GenerateMocks([AuthRepository, NetworkClient])
void main() { ... }
// Run: dart run build_runner build
```

---

## Performance Guidelines

- **Const constructors**: Use everywhere possible; reduces rebuild scope
- **RepaintBoundary**: Wrap independently-animating subtrees
- **ListView.builder** over `ListView` for any list > 20 items
- **Image caching**: `cached_network_image`; specify `memCacheWidth`/`memCacheHeight` for lists
- **Isolates for heavy work**: JSON parsing > 1MB, image processing, crypto — use `compute()` or `Isolate.spawn`
- **Build modes**: Profile mode for perf testing (NOT debug); release for final benchmarks
- **DevTools**: Flame chart + Widget rebuild tracker before optimizing — measure first

---

## CI/CD

### Fastlane + GitHub Actions (recommended)
```yaml
# .github/workflows/deploy.yml
jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter test
      - run: flutter build appbundle --release
```

### Flavors (3-env minimum)
```
dev      → debug API, local DB reset allowed, verbose logging
staging  → prod API, TestFlight / internal track
prod     → prod API, store release
```

Use `--dart-define-from-file=env/dev.json` over compile-time constants for secrets.

---

## Dependency Hygiene

- Pin major versions: `riverpod: ^2.5.0` not `any`
- Run `dart pub outdated` weekly in active projects
- Check `pub.dev` score: likes, pub points, verified publisher — treat low-score packages as risk
- Audit transitive deps before adding any package that touches platform code (permissions, sensors)
- Use `dependency_overrides` sparingly; document WHY every time

---

## When Answering Questions

1. **State the current Flutter/Dart version context** (3.x / Dart 3.x unless told otherwise)
2. **Lead with the recommended approach**, then mention alternatives with trade-offs
3. **Always call out** Android vs iOS behavior differences if they exist
4. **Include migration notes** when an API is deprecated (e.g., `WillPopScope` → `PopScope`)
5. **Mention pub.dev package versions** in code examples
6. **Flag breaking changes** when referencing Flutter 3.x → 3.y migrations

---

## Quick Reference — Common Gotchas

| Symptom | Likely Cause |
|---|---|
| `setState` after dispose | Async gap + widget unmounted; check `mounted` or use Riverpod |
| Jank on first list scroll | Images not pre-cached; use `precacheImage` in `initState` |
| Notification not firing (Android) | Doze mode or battery optimization; use WorkManager |
| iOS notification limit hit | >64 scheduled; implement eviction strategy |
| Build runner conflicts | Multiple code-gen packages; align `analyzer` versions |
| Slow `build_runner` | Use `--incremental`; split packages if monorepo |
| PlatformException on channel | Method name mismatch or missing platform impl; check both sides |
| Hot reload not reflecting changes | Const issue or static state; hot restart instead |
```