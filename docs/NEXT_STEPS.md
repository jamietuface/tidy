# Next Steps — Resume Plan

> **For Claude (next session):** Read this file FIRST, before touching code. The list below is the agreed work queue from the user's last session. Work top-to-bottom. After each item: hot reload, dart analyze lib/ (zero issues bar), log to Notion Dev Log (`3594a228-bde2-81dd-aedf-c63699ae2154`), and append the prompt that triggered it to the Prompts page (`35a4a228-bde2-81ef-bd17-d371b05c0fb6`).
>
> User is non-technical and doesn't know how to hot restart — if a change requires hot restart (new providers, new state fields, new packages), tell them clearly and offer the `pkill -f flutter_tools && cd ~/Desktop/Tidy && flutter run` command.

---

## State at end of last session (2026-05-09)

- Stages 1–4 from the staged plan all shipped ✅
  - Stage 1: Subscribe button writes `users/{uid}/plan = 'pro'` in Firestore (mock — no real purchase)
  - Stage 2: AddSubscriptionSheet wired (manual entry; iOS doesn't allow auto-detect of other apps' usage)
  - Stage 3: SwipeScreen redesigned with metallic dark Tidy Pro aesthetic (black + radial halos + glass cards + glossy gradient CTA)
  - Stage 4: Swipe stats persistence verified live
- Side fix: Paywall success state (green checkmark celebration) + PRO pill in AppBar
- All committed and pushed to `origin/main`

---

## Agreed work queue (user picked **A through G**, all 7)

### A — Real StoreKit purchase
Replace the mock `UserRepository.setPlan('pro')` call with the real `in_app_purchase` flow.

- Create products in App Store Connect:
  - `tidy_pro_monthly` (£3.99 auto-renewable)
  - `tidy_pro_annual` (£23.99 auto-renewable)
- Wire `in_app_purchase` package (already in pubspec) in `PaywallScreen._subscribe()`:
  - `InAppPurchase.instance.queryProductDetails({productIds})`
  - `InAppPurchase.instance.buyNonConsumable(PurchaseParam(productDetails: ...))`
  - Listen on `InAppPurchase.instance.purchaseStream` for status changes
  - On `purchased` / `restored`: call `setPlan('pro', billing: ...)` then complete the purchase
- Server-side receipt verification deferred (Apple recommends Cloud Function later)
- Apple Sandbox testing setup: tester account in App Store Connect → Settings → Sandbox testers

### B — Apps tab metallic dark redesign
Subscriptions screen still uses the old light/system theme — looks inconsistent next to the new SwipeScreen.

Apply the same vocabulary as `lib/screens/swipe_screen.dart`:
- Black background + radial halos
- Glass card panels (white 6% bg, white 10% border, top sheen, radius 18)
- Section headers in white-50% caps
- Spend Summary card → big gradient pill (007AFF→5856D6) with blue glow
- Cancel tip card → glass with orange icon badge

Files: `lib/screens/subscriptions_screen.dart` (rewrite while preserving stream + add-button + empty-state CTA + currency picker)

### C — Bottom nav metallic dark
Currently `home_screen.dart` `_FrostedNavBar` uses BackdropFilter blur (frosted glass). Update to match the dashboard:
- Black bg with faint top border (white 8%, 0.5pt)
- Selected icon: gradient color (007AFF→5856D6)
- Unselected: white 35%
- Drop the BackdropFilter blur — the SwipeScreen behind is already opaque black

File: `lib/screens/home_screen.dart` (`_FrostedNavBar` widget)

### D — Edit / delete subscriptions
Long-press on a subscription row in `subscriptions_screen.dart` → CupertinoActionSheet with:
- Edit (re-opens AddSubscriptionSheet pre-populated)
- Delete (confirm via `showTidyConfirmDialog`, calls `SubscriptionsRepository.delete`)

Refactor `AddSubscriptionSheet` to take an optional `Subscription? editing` arg; if non-null, pre-fill fields and call `update()` instead of `add()`. Add `update(uid, id, ...)` to `SubscriptionsRepository`.

### E — Settings screen
The `slider_horizontal_3` icon in SwipeScreen AppBar is dead. Build `lib/screens/settings_screen.dart`:
- Section: Account
  - Email (read-only, from FirebaseAuth)
  - Plan (Free / Pro)
  - Sign out (red, confirms via `showTidyConfirmDialog`)
- Section: Appearance
  - Theme override (System / Light / Dark) — store in `users/{uid}/settings/appearance.themeMode`
- Section: Notifications
  - Subscription renewal reminders toggle (writes to settings doc, integrates with `notification_service.dart`)
- Section: Legal
  - Privacy Policy (open in browser)
  - Terms of Service (open in browser)
- Use the metallic-dark glass card vocabulary

Add `/settings` route in `lib/app/router.dart`. Wire the slider icon to `context.push('/settings')`.

### F — Photo library writeback (delete from iOS Photos)
When user deletes via swipe, photo currently stays in their library — only the decision is in Firestore. Implement actual deletion:

- Use `PhotoManager.editor.deleteWithIds([assetId])` — iOS shows native confirmation
- Approach: batch confirmation. Don't delete one-at-a-time. After the deck completes, show a summary screen: "X photos to delete — Confirm" → calls `deleteWithIds(allDeletedIds)`. iOS shows ONE system dialog covering all of them.
- Create `lib/features/swipe/photo_deletion_service.dart` wrapping the editor
- Update `_DoneState` / `_Completion` widgets to show a "Delete X photos" button if `state.deleted.isNotEmpty`
- Handle: iOS user cancels → keep decisions in Firestore but don't delete
- After successful delete, mark Firestore decisions with `deletedFromLibrary: true` so we don't try again

### G — Improve AI classifier accuracy
Currently only `Old` reliably triggers (date check). Blurry/Duplicate rarely match.

Improvements in `lib/features/ai/photo_classifier.dart`:
- **Blurry**: relax threshold from 80 → 60, increase sample to 100×100 for better signal. Test against live photos.
- **Screenshots**: Apple iOS now uses logical-size aspect ratios. Add 19.5:9 + 19:9 as the primary heuristic; exact-size match becomes a bonus.
- **Duplicates**: MD5-of-first-4KB is too strict. Add **perceptual hash** (dHash 8×8): downsample to 9×8 grayscale, compute Hamming distance between rows. Group photos with Hamming ≤ 5 as duplicates. Heavier compute — may need a tighter classify budget.
- Bump `_classifyBudget` from 200 → 500 if perf allows
- Add a "Re-scan" button somewhere (Settings? home pull-to-refresh?) that invalidates `groupCountsProvider`

---

## How to resume

When the user opens a new session and says anything like "resume", "continue", "let's keep going", or just pastes a new prompt:

1. Read `CLAUDE.md` (mandatory, says so at top)
2. Read this file (`docs/NEXT_STEPS.md`)
3. Read the most recent Notion Dev Log entry to see exactly what shipped last
4. Verify simulator state if Flutter is running: `pgrep -fl "flutter_tools.*run"`
5. Pick up at the next un-shipped item from the queue above (start with **A**)
6. If the user says something different, do that — but flag if it's tangential to the queue and ask if they want to defer A–G
7. After each item: commit (one commit per item, conventional message), push, log to Notion

## Don't forget

- `cd ~/Desktop/Tidy` before any Flutter command (user is sometimes in `~`)
- Hot reload via `pgrep -f "flutter_tools.*run" | head -1 | xargs kill -USR1` (USR1 = `r`, USR2 isn't hot restart — only the keyboard `R` triggers hot restart)
- Notion Dev Log page: `3594a228-bde2-81dd-aedf-c63699ae2154`
- Notion Prompts page: `35a4a228-bde2-81ef-bd17-d371b05c0fb6`
- Firebase project: `tidy-73cc3` (798629895187)
- iPhone 15 simulator id: `A531C85A-18B1-4553-AA8F-5CF185DFD47E` (gone in iOS 26 sim list — user is now on iPhone 17 by default in Xcode but the picker offered 17 / 17 Pro / 17 Pro Max / 17e / Air; iPhone 15 came back later in the session)
