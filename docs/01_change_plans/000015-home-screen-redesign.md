# Change Plan: Home Screen Redesign

## Goal

Redesign the home screen with a circular progress ring hero, quick stats row, warmer light theme, and more color accents. Based on Stitch mockups (project `2035193582421078607`).

## Design Reference

- Light: warm cream `#F5F0E8` bg, white cards with warm shadows, amber/sage/coral accents
- Dark: deep `#111318` bg, dark cards, same accent colors on dark surfaces
- Hero: large circular progress ring (Apple Fitness style) showing daily goal progress
- Quick stats: streak days (amber) + activity % (sage green) side by side
- Work hours: large `09:00 — 18:00` display with colored dots
- Action button: filled teal pill (not outlined)

## Files Changed

### `lib/core/theme/app_colors.dart`
- Add `ringTrack`, `streakColor`, `activityColor` tokens
- Update light theme: warm cream bg `#F5F0E8`, warm card border, warm shadows
- Keep dark theme mostly as-is, just add new tokens

### `lib/screens/home_screen.dart`
- Replace `_GoalProgress` (linear bar in card) with `_GoalRing` (circular CustomPaint)
- Add `_QuickStats` row (streak + activity) - needs stats from `MovementStatsRepository`
- Restyle `_ManualMoveButton` as filled pill
- Restyle `_NextReminderBanner` (no changes needed, already subtle)
- Add `statsRepository` data loading for streak/activity

### `lib/screens/widgets/work_hours_card.dart`
- Replace clock widget with large time display card (`09:00 — 18:00`)
- Keep time chips with colored dots below

### New: `lib/screens/widgets/goal_ring_painter.dart`
- CustomPainter for the circular arc with rounded caps

## Not Changed
- Settings screen, stats screen, navigation, native code
- No new dependencies
- No l10n changes (reuse existing strings)

## Risks
- CustomPainter performance: minimal (single ring, no animation for now)
- Stats loading: already have `statsRepository` in HomeScreen, just need to call `getStats()`
