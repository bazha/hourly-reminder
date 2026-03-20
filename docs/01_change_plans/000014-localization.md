# 000014 - Localization (Russian, English, Belarusian)

## Status: APPLIED

## Background

All UI strings are hardcoded in Russian. Adding English and Belarusian expands the audience. Uses Flutter's built-in `gen-l10n` with ARB files.

## Design

- Russian (ru) - default, current strings
- English (en)
- Belarusian (be)
- System locale auto-detection, fallback to Russian

## Affected Files

- `pubspec.yaml` - add `flutter_localizations`, configure `generate: true`
- `l10n.yaml` - gen-l10n config
- `lib/l10n/app_ru.arb` - Russian strings (source)
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_be.arb` - Belarusian translations
- `lib/main.dart` - localization delegates
- All 12 files with hardcoded strings

## Implementation Steps

1. Add dependency + l10n config
2. Create ARB files with all 39 strings (including plurals)
3. Run `flutter gen-l10n`
4. Wire delegates in main.dart
5. Replace all hardcoded strings
6. Run tests

## Rollback Plan

Remove l10n files, revert to hardcoded strings.
