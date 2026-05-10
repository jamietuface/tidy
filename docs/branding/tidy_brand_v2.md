# Tidy Brand v2 — Stage 1A Foundation

Snapshot of the brand + theme foundation introduced in Stage 1A. Stage 1B redesigns
(swipe screen, dashboard, paywall, onboarding) consume these tokens and widgets.

References live in `docs/design_refs/stage_1A/` (visual references only — never bundled as raster UI).

## Personality

Premium Apple utility. Calm, real, photographic. **Not** gamified, **not** sparkly,
**not** toy-like.

## Logo

Single locked direction: **light pearl/silver layered photo-card "T"**.

- Stays light in BOTH light and dark themes.
- Constructed from layered photo-card forms — top horizontal slab + small stem,
  with a faint card peeking from behind to suggest the photo stack.
- Rendered with `CustomPainter` in `lib/shared/widgets/tidy_logo_mark.dart`.
  No SVG dependency, no raster assets.
- Badge wrapper:
  - Light: pearl gradient `#FDFEFF → #E8EFF8`, hairline `#DCE7F5`, soft shadow.
  - Dark: near-black gradient `#1B202B → #06080D`, white-alpha hairline,
    subtle blue rim glow (`#007AFF` @ 18% alpha).
- Forbidden: stars, sparkles, gamified motifs, dark logo on dark surface.

### Sizes used in app

| Context | Size |
|---|---|
| Inline (sign-in, paywall hero) | 84–112 |
| Onboarding header | 32 |
| Brand preview row | 32, 64, 96, 128 |
| Future dashboard header | 28–32 |

## Wordmark

`TIDY` — uppercase, thin (`w300`), wide tracked.

- Style helper: `TidyTypography.wordmark(fontSize, color, letterSpacing)`.
- Letter-spacing defaults to `fontSize × 0.34` so it scales correctly.
- Colour:
  - On dark surface: `TidyBrand.wordmarkOnDark` (#EAF2FF) @ 88% alpha.
  - On light surface: `TidyBrand.wordmarkOnLight` (#303846) @ 88% alpha.
- No custom font — system SF Pro on iOS, Roboto on Android.

## Lockups

`TidyBrandLockup({axis, size, showGlow, monochrome, showBadge})`.

| Size | Logo | Wordmark | Gap |
|---|---|---|---|
| small  | 32  | 18 | 10 |
| medium | 52  | 28 | 14 |
| large  | 112 | 48 | 22 |

Axes: `horizontal` (logo left, wordmark right) or `vertical` (logo above wordmark).

## Theme tokens

Two systems live alongside each other during Stage 1A:

1. **Legacy `TidyColors` ThemeExtension** — kept untouched so existing
   metallic-dark screens (settings, swipe, paywall) keep working.
2. **New `TidyBrandPalette` ThemeExtension** — what Stage 1A widgets and
   Stage 1B redesigns use. Read with `context.tidyBrand`.

### `TidyBrandPalette`

| Token | Light | Dark |
|---|---|---|
| `background` | `#F7F9FC` | `#000000` |
| `backgroundAlt` | `#FFFFFF` | `#05070B` |
| `surface` | `#FFFFFF` | `#05070B` |
| `surfaceSoft` | `#F1F5FA` | `#0B0E14` |
| `surfaceElevated` | `#FFFFFF` | `#11151D` |
| `cardBorder` | `#DCE3ED` | white @ 10% |
| `cardBorderSubtle` | `#E7ECF3` | white @ 6% |
| `textPrimary` | `#1D2430` | white @ 92% |
| `textSecondary` | `#667085` | white @ 62% |
| `textMuted` | `#98A2B3` | white @ 42% |
| `hairline` | `#DCE7F5` | white @ 16% |
| `blue` / `indigo` / `danger` / `success` | iOS system | iOS system |

### Theme-independent brand constants

`TidyBrand` static class:

| Token | Value | Use |
|---|---|---|
| `pearl` | `#F7FAFF` | Logo top-slab highlight |
| `ice` | `#EAF2FF` | Logo soft secondary |
| `silver` | `#B8C2D9` | Logo mid-tone |
| `graphite` | `#3B4454` | Wordmark base on light |
| `hairlineLight` | `#DCE7F5` | Logo edge on light surfaces |
| `hairlineDark` | white @ 16% | Logo edge on dark surfaces |

## Theme behaviour

- Default: follow system theme.
- User override in Settings → Appearance → Theme: Use System / Light / Dark.
- Persisted via `SharedPreferences` key `tidy.themeMode`.
- Controller: `tidyThemeModeControllerProvider` (StateNotifier).
- Switches immediately, no app restart.

## Stage 1A scope guard

- Did NOT redesign existing screens (swipe, dashboard, subscriptions, paywall body).
- Did NOT migrate metallic-dark hardcoded styling to brand tokens.
- DID swap brand headers to `TidyBrandLockup` in onboarding, sign-in, paywall hero.
- DID add Brand Preview screen + Settings entries (Appearance + DEV).

Stage 1B owns the screen-level redesigns that consume `TidyBrandPalette` properly.
