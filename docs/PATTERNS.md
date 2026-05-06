# Tidy — Patterns & Conventions

> Ported from Vale. Updated for Tidy's photo + subscription domain.

## Riverpod

Use `@riverpod` code generation. `autoDispose` is the default.

- `Provider` — synchronous non-changing values (e.g., `photoManagerProvider`, `firestoreProvider`)
- `StreamProvider` — live data (e.g., `authStateProvider`, `photoGroupsProvider`)
- `AsyncNotifierProvider` — for complex async state with mutations (e.g., `swipeSessionProvider`)
- `ref.watch` in `build()`, `ref.read` in callbacks — never swap these
- `ref.onDispose` for cleanup of streams/listeners inside providers

## Routing

Single GoRouter in `lib/app/router.dart`. `StatefulShellRoute.indexedStack` for the Photos/Apps bottom nav.

Auth redirect reads `currentUser` synchronously (not the stream) to avoid the first-frame flash.

Never construct a `GoRouter` outside `routerProvider`.

## Theming

Every visual value comes from `lib/core/theme/`:
- Colors: `TidyColors.*` → maps to iOS system palette
- Typography: `TidyTypography.*` / `theme.textTheme.*`
- Spacing: `TidySpacing.*` (8pt grid)

Never hardcode hex, font size, padding, or duration in feature code.

## Swipe Gesture

- Right swipe → keep → green overlay → `HapticFeedback.mediumImpact()`
- Left swipe → delete → red overlay → `HapticFeedback.heavyImpact()`
- Drag threshold: 40pt for color, 120pt to commit
- Spring animation: `dampingFraction: 0.7`
- Card stack: 3 visible, scale 0.95 / 0.90 for cards behind active

## Photo Groups

AI groups are processed on-device (Phase 2). Phase 1 uses heuristic rules:
- **Blurry**: laplacian variance < threshold (Core ML in Phase 2)
- **Duplicates**: perceptual hash distance < 8
- **Screenshots**: asset mediaSubtype includes `.photoScreenshot`
- **Old**: creation date > 365 days, not in album

## App Usage Data

Requires `FamilyControls` entitlement + `DeviceActivityReport` extension (Screen Time API).
Phase 1 uses mock data. Phase 2 wires real Screen Time data.
Never show exact app names from Screen Time without user consent prompt.

## File Conventions

- Feature folder: `lib/features/{name}/` with `models/`, `providers/`, `screens/`, `widgets/`
- Services: `lib/services/` — `photo_service.dart`, `app_service.dart`, `subscription_service.dart`
- Flat structure until a module exceeds 4 files

## Error Handling

- Wrap all photo_manager and Firebase calls in try-catch with typed exceptions
- Use `AsyncValue.error` in providers — never swallow exceptions silently
- Show user-facing error states in all screens — never leave a blank view

## Bug-Derived Rules

(none yet — add here when a systemic bug is fixed)
