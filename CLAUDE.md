# Tidy — Project Instructions for Claude Code

> Flutter photo-cleaning + app-subscription tracker. Subscription-based iOS + Android app. Swipe left/right on photos (keep/delete), AI groups blurry/duplicate/old photos, app spend dashboard.

## ⚡ Notion Auto-Documentation (MANDATORY — EVERY CHANGE)

**After EVERY code change, Claude MUST log it to Notion automatically.**

Run this script after every commit:
```bash
~/.tidy/notion-log.sh "$(git log -1 --pretty='%s')" "$(git log -1 --pretty='%b')"
```

The script posts to the Tidy Changelog page in Notion. No exceptions. If the script fails, note it but still proceed — do not block on Notion.

Notion workspace: https://notion.so/d563af77025c4dc3a9ee5968e1d99771

---

## Read Documentation First

Read the relevant `/docs` files at the start of every conversation:

1. `docs/architecture.md` — codebase structure, tech stack
2. `docs/design-system.md` — visual tokens (single source of truth)
3. `docs/roadmap.md` — feature status and what ships when
4. `docs/PATTERNS.md` — coding conventions, anti-patterns
5. `docs/CHANGELOG.md` — what shipped last session

---

## Session Protocol (MANDATORY)

### Session Start
1. Read the docs above
2. Ask: "What do you want to accomplish this session?"
3. Organise work into a numbered goal list

### During Session
- 3+ independent tasks → use parallel subagents automatically
- Never modify code you haven't read first

### Session End
1. Update `docs/CHANGELOG.md`
2. Run `dart analyze lib/` — fix any new warnings
3. **Log all changes to Notion** (see above)
4. State what's next

---

## Change Batching

**One commit = one logical change.**

- BAD: "Change padding" → commit → "Make bold" → commit
- GOOD: "Restyle swipe card: padding, bold title, blue overlay" → one commit

Group into one commit: related styling on same screen, bug fix + test, new widget + integration.
Keep separate: unrelated features, different feature areas, refactors vs new functionality.

---

## Screenshot Protocol

- Screenshot after EVERY visual change
- Screenshots > descriptions, every time
- If something looks wrong, screenshot it — don't describe it in words

---

## Codebase Location

- **Source:** `/Users/jamietu/Desktop/Tidy/lib/`
- **Git root:** `/Users/jamietu/Desktop/Tidy/`
- **GitHub:** `jamietuface/tidy` (public)
- **Branch:** `main`
- **Platform:** Flutter (iOS primary, Android Phase 2)

---

## Tech Stack

- **Framework:** Flutter 3.41.9
- **Language:** Dart 3.x
- **State:** Riverpod 2.x (with codegen `@riverpod`)
- **Navigation:** go_router 14.x with `StatefulShellRoute`
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)
- **Photos:** photo_manager
- **Payments:** in_app_purchase (StoreKit 2)
- **AI (Phase 2):** Core ML / flutter_mlkit for on-device photo grouping
- **Local storage:** shared_preferences + Hive

---

## Architecture Rules

### Feature-First Structure
```
lib/
├── app/              — App config, theme, router
├── core/             — Constants, extensions, shared models, global providers
├── features/         — Feature modules (swipe/, subscriptions/, paywall/, onboarding/, auth/)
├── services/         — Firebase, photo_manager, app usage, payments
└── shared/           — Reusable widgets, design system
```

### Data Flow (Unidirectional)
```
PhotoLibrary/Firebase → Repository → Provider → Widget (ref.watch)
Widget callback → ref.read(provider.notifier).method() → Repository → Storage
```

### Layer Rules
- **Widgets** — UI only. No business logic. No direct Firebase or photo_manager calls.
- **Providers/Notifiers** — Business logic. Call repositories. Expose state via `AsyncValue`.
- **Repositories** — Data access. Abstract photo_manager + Firebase behind interfaces.
- **Models** — Immutable data classes using `freezed`. Use `copyWith()`.

---

## Dart & Flutter Coding Rules

- Files: `snake_case.dart`
- Classes/Enums: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `camelCase` (NOT SCREAMING_CASE)
- Use `const` constructors everywhere possible
- Break large `build()` into small private `Widget` classes (not helper methods)
- Never do expensive operations in `build()`
- `ref.watch()` in `build()`, `ref.read()` ONLY in callbacks
- Handle ALL three `AsyncValue` states (loading, error, data)

---

## Anti-Patterns (NEVER DO)

1. Direct Firebase or photo_manager calls in widgets
2. `setState()` for anything beyond trivial local UI state
3. Business logic in widgets
4. Mutable state in providers
5. `ref.read()` inside `build()`
6. Side effects in provider initialization
7. Helper methods returning widgets (use private widget classes)
8. Hardcoded colours, sizes, or spacing (always use `TidyColors`, `TidySpacing`)
9. Missing loading/error states for async data

---

## Visual Change Approval Gate (MANDATORY)

Any change that affects what the user SEES requires:
1. Describe the change BEFORE making it
2. Wait for explicit user approval
3. Then implement

Code-only changes (providers, error handling, data logic) can be auto-applied.

---

## BEFORE EVERY CODE CHANGE

1. **Restate as Gherkin** (Given/When/Then) so the intent is clear
2. **Correct terminology** if needed
3. **State expected outcome** in one sentence
4. Then implement (or ask if unclear)

---

## AFTER EVERY CODE CHANGE (MANDATORY CHECKLIST)

### Step 1: Hot Reload
```bash
pid=$(pgrep -f "flutter_tools.*run" | head -1); [ -n "$pid" ] && kill -USR1 "$pid" && echo "Hot reloaded" || echo "No Flutter process — skipping"
```
Never launch `flutter run` unprompted.

### Step 2: Code Quality
```bash
dart analyze lib/
```
Fix errors before committing. Fix new warnings introduced by this change.

### Step 3: Self-Review
```bash
git diff --stat && git diff
```
Check for: debug prints, hardcoded values, missing null checks, files over 600 lines.

### Step 4: Test (when applicable)
New business logic (providers, repositories, models) → write a unit test.

### Step 5: Summary
1. What changed (plain English)
2. What the user will now experience

### Step 6: Git Commit & Push
```bash
cd /Users/jamietu/Desktop/Tidy && git add -p && git commit -m "..." && git push
```

### Step 7: 🔴 LOG TO NOTION (MANDATORY)
```bash
~/.tidy/notion-log.sh "CHANGE_TITLE" "CHANGE_DESCRIPTION"
```
Every commit must be logged to Notion. No exceptions.

### Step 8: Update /docs
Update the relevant doc file if the change affects architecture, features, or patterns.

---

## Testing Strategy

### What MUST be tested
- Providers/Notifiers
- Repositories (photo grouping logic, subscription status)
- Utility functions (blur detection, duplicate hash, cost calculation)

### What does NOT need tests
- Pure UI (colors, layout)
- Simple pass-through providers
- Theme definitions

---

## Git Rules

- One logical change per commit
- Run `dart format .` before committing
- Never commit secrets (API keys, Firebase credentials)
- Always push to `main` on `jamietuface/tidy`

---

## Design System (summary — full detail in docs/design-system.md)

- Colors: always `AppColors.*` (iOS system palette, auto dark mode)
- Typography: always `theme.textTheme.*` (never hardcode sizes)
- Spacing: 8pt grid (8, 16, 24, 32)
- Radius: 12pt cards, 14pt buttons, 28pt icon containers
- Swipe: right = keep (green), left = delete (red), threshold 120pt

## The Tidy App (what we're building)

1. **Photo Swipe** — swipe right to keep, left to delete. AI groups: Blurry, Duplicates, Screenshots, Old.
2. **App Tracker** — shows installed apps, last-used date, subscription cost. Suggests cancellations.
3. **Paywall** — Pro: £3.99/mo or £23.99/yr (annual = best value). Free: 20 swipes/day.
