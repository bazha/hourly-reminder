# 000012 - UI Redesign v2: Linear-Inspired Material Design 3

## Status: APPLIED

## Background

The current UI (PR #10 redesign) replaced glassmorphism with flat cards but still has UX problems:
- Duplicate time controls (clock widget + sliders control the same values)
- Poor accessibility (small clock handles, color-only status indicators, low contrast muted text)
- Cramped statistics layout with no visual hierarchy between metrics
- No empty/first-run state
- Settings scattered without logical grouping
- No notification interaction design

## Design System

**Stitch Project:** `2035193582421078607` (view at stitch.withgoogle.com)

**Style:** Linear/Raycast app aesthetic - ultra-clean, monochrome with purposeful accent color, no visual noise. Material Design 3 foundations.

### Color Tokens

#### Dark Theme
| Token | Value | Usage |
|-------|-------|-------|
| background | `#111318` | Page background |
| surface | `#1A1D24` | Cards, elevated surfaces |
| border | `#25282F` | 1px card borders, dividers |
| textPrimary | `#ECEEF1` | Headings, primary content |
| textSecondary | `#7D8590` | Labels, descriptions |
| textMuted | `#484F58` | Section labels, hints |
| accent/teal | `#4EAAA0` | Primary actions, progress, positive |
| danger/coral | `#E57373` | End time, sedentary metrics |
| warning/amber | `#F5A623` | Reaction time, current time |

#### Light Theme
| Token | Value | Usage |
|-------|-------|-------|
| background | `#F8F9FA` | Page background |
| surface | `#FFFFFF` | Cards |
| border | `#E2E5E9` | Card borders, dividers |
| textPrimary | `#1B1F23` | Headings |
| textSecondary | `#656D76` | Labels |
| textMuted | `#8B949E` | Section labels |
| accent/teal | `#3D9A8F` | (darker for AA contrast on light bg) |
| danger/coral | `#D94F4F` | (darker for contrast) |
| warning/amber | `#D4890E` | (darker for contrast) |

### Typography Scale
| Name | Size | Weight | Usage |
|------|------|--------|-------|
| heading | 22px | 600 | Page titles |
| sectionLabel | 11px | 600, uppercase, 1.5px tracking | Section headers |
| cardTitle | 16px | 600 | Card titles |
| body | 15px | 400 | Default text |
| bodyMedium | 15px | 500 | Emphasized text |
| label | 13px | 400 | Small labels |
| statLarge | 48px | 700 | Hero numbers |
| statMedium | 24px | 700 | Metric numbers |
| statSmall | 36px | 700 | Streak numbers |

### Spacing
- Page padding: 24px horizontal
- Section gaps: 32px vertical
- Card internal padding: 20px
- Card border-radius: 12px
- Interactive element minimum: 48x48dp

## Screen Inventory

### Screens Generated (Stitch)

| # | Screen | ID | Theme |
|---|--------|----|-------|
| 1 | Home v1 | `5556e9db6f6a4031acd60d9c6158212e` | Dark |
| 2 | Home v1 | `7aca89dcdbae4796bf73f0720fc5be89` | Light |
| 3 | Stats v1 | `aa738950bde64e24aa919e8504bba7fd` | Dark |
| 4 | Stats v1 | `7190d3e7e66e45a5b8df905dd047120a` | Light |
| 5 | **Home v2 (recommended)** | `dd9b3a704c754f1288b6cacab4fb9895` | Dark |
| 6 | **Home v2** | `eb88d3ec17f249eaa9bdac8d358eaa37` | Light |
| 7 | **Stats v2 (recommended)** | `79b2afbca79440cb96fcbbd23462471e` | Dark |

### Variants Generated

| # | Variant | ID | Description |
|---|---------|-----|-------------|
| V1 | Circular progress | `473424b2d5e444ac8a607c35a4b4ac92` | Clock above, ring progress indicator |
| V2 | Inline settings + violet | `619066f389ef467eb1cd3cede307d281` | Settings as chips, violet accent |
| V3 | Dashboard grid + amber | `816a1e9067e746f392ed62a8c8affd16` | Multi-column grid, amber accent |

## UX Audit: Current Issues

### 1. Duplicate Time Controls (Critical)
**Problem:** WorkHoursCard (clock widget) and ScheduleCard (sliders) both control start/end work times. Cognitive load: "which one do I use?"
**Fix:** Remove ScheduleCard sliders. Keep the clock as the sole time control. Add tappable time chips below the clock that open system time picker as an alternative input method.

### 2. Accessibility Gaps (Critical)
**Problem:**
- Clock handles are ~20px (below 48dp minimum)
- Status pill uses green/gray color only (no text/icon differentiation)
- Muted text `#5A6070` on `#15181E` bg = ~3.2:1 contrast (fails AA 4.5:1)
- Bar chart empty bars at 15% opacity are invisible to low-vision users
- No semantic labels on custom-painted clock

**Fix:**
- Replace status pill with text-labeled toggle ("ВКЛ"/"ВЫКЛ")
- Increase muted text to `#7D8590` on `#111318` = 4.6:1 (passes AA)
- Empty chart bars use `#25282F` (visible, clearly empty)
- Add `Semantics` widgets to clock and chart
- All interactive elements minimum 48x48dp

### 3. Settings Organization (Medium)
**Problem:** ReminderToggleCard, ScheduleCard, OptionsCard are separate cards with mixed concerns. Weekend toggles, gender selection, and daily goal are lumped together in "Options."
**Fix:** Group into a single settings list with clear rows:
- "Рабочие дни" (consolidates Saturday/Sunday toggles into one row showing "Пн-Пт")
- "Дневная цель" (shows current value, taps to edit)
- "Стиль уведомлений" (replaces gender radio buttons)
- "Тест уведомления" (moved from standalone button)

### 4. Statistics Visual Hierarchy (Medium)
**Problem:** TodaySummaryCard crams 3 equal-width tiles. Values vary in width ("5/8" vs "3ч 20м"). No icons to differentiate metrics.
**Fix:** Three separate metric cards with:
- Color-coded 2px bottom accent line
- Small category icon (top-left)
- Clear label hierarchy
- Consistent card sizing

### 5. No Empty State (Low)
**Problem:** First-time users see a half-loaded screen with zero values. No guidance on what to do.
**Fix:** Dedicated first-run screen with:
- Welcome message + minimal illustration
- Quick setup card (work hours, days, goal)
- Single CTA "Включить напоминания"
- Ghost progress card at low opacity

### 6. Weekly Chart Goal Line (Low)
**Problem:** No visual reference for whether daily counts meet the goal.
**Fix:** Add dashed horizontal line at goal level with "цель" label.

## Implementation Plan

### Affected Files

**Theme:**
- `lib/core/theme/app_colors.dart` - Update color tokens
- `lib/core/theme/app_typography.dart` - Update type scale

**Home Screen:**
- `lib/screens/home_screen.dart` - Restructure layout
- `lib/screens/widgets/settings_card.dart` - Replace with settings list rows
- `lib/screens/widgets/work_hours_card.dart` - Add time chips, remove legend
- `lib/screens/widgets/test_notification_button.dart` - Remove (integrate into settings list)
- `lib/widgets/work_hours_clock.dart` - Update colors, add semantics

**Stats Screen:**
- `lib/features/movement_stats/presentation/stats_screen.dart` - Update layout
- `lib/features/movement_stats/presentation/widgets/today_summary_card.dart` - Split into 3 cards
- `lib/features/movement_stats/presentation/widgets/weekly_chart.dart` - Add goal line, fix empty bars
- `lib/features/movement_stats/presentation/widgets/streak_card.dart` - Update typography

**Navigation:**
- `lib/screens/main_shell.dart` - Update nav bar styling

### Steps

1. **Update design tokens** (app_colors.dart, app_typography.dart)
   - New color palette per token table above
   - New typography scale
   - Ensure WCAG AA contrast for all text/bg combinations

2. **Redesign HomeScreen layout**
   - Remove ScheduleCard (duplicate time control)
   - Add time chips below clock (tappable, open time picker)
   - Replace status pill with labeled toggle
   - Replace OptionsCard with settings list rows
   - Move test notification into settings list
   - Add "Записать разминку" ghost button below progress

3. **Redesign StatsScreen layout**
   - Split TodaySummaryCard into 3 separate metric cards with icons
   - Add goal line to weekly chart
   - Fix empty bar visibility
   - Update streak card typography

4. **Add empty/first-run state**
   - Detect first launch (no preferences set)
   - Show welcome + quick setup UI
   - CTA enables reminders and transitions to normal home

5. **Accessibility pass**
   - Add Semantics to clock, chart, toggle
   - Verify 48dp touch targets on all interactive elements
   - Test with TalkBack/VoiceOver
   - Verify contrast ratios with accessibility scanner

6. **Update navigation bar**
   - Match new color tokens
   - Adjust height to 64px

### Testing Checklist
- [ ] All existing tests pass with new theme tokens
- [ ] Clock interaction still works (drag handles)
- [ ] Settings changes persist through SharedPreferences
- [ ] Dark/light theme switching works
- [ ] WCAG AA contrast verification (automated)
- [ ] Screen reader announces all interactive elements
- [ ] First-run flow activates on fresh install
- [ ] Stats load correctly with new card layout
- [ ] Navigation between tabs preserves state

### Rollback Plan
Revert to current theme tokens and screen layouts. No architectural changes, just visual.

## Benefits
- Reduced cognitive load (one time control instead of two)
- WCAG 2.1 AA compliance
- Modern, professional aesthetic matching current design trends
- Better first-time user experience
- Modular settings pattern scales to future options
