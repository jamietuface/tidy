# Tidy — Feature Inventory

> Status snapshot. Update on every feature add, change, or removal.

## Status Legend
- 🟢 Done — ships and is wired in
- 🟡 In progress — partially built, some flows missing
- 🔵 Placeholder — file exists, contents are stubs
- ⚪ Not started

## Feature Modules

| Feature | Status | Notes |
|---------|--------|-------|
| `app/` shell + navigation | 🟢 Done | GoRouter + bottom tab nav (Photos / Apps) |
| `shared/theme/` design system | 🟢 Done | AppColors, AppTheme, TidyThemeExtension |
| `screens/onboarding_screen` | 🟡 In progress | 3-screen UI complete. No real permission flow yet. |
| `screens/swipe_screen` | 🟡 In progress | UI complete with AI group tiles + CTA. No real photo loading yet. |
| `screens/subscriptions_screen` | 🟡 In progress | UI complete with mock data. No real Screen Time API yet. |
| `screens/paywall_screen` | 🟡 In progress | Monthly + annual UI. No StoreKit wired yet. |
| `widgets/tidy_card` | 🟢 Done | Reusable card with dark mode support |
| `widgets/section_header` | 🟢 Done | Uppercase section label |
| Photo library access | ⚪ Not started | photo_manager integration, permission flow |
| Real swipe gesture physics | ⚪ Not started | Drag gesture + spring animation + haptics |
| AI photo grouping (heuristic) | ⚪ Not started | Phase 1: perceptual hash, screenshot detection, age filter |
| AI photo grouping (ML) | ⚪ Not started | Phase 2: Core ML blur detection |
| App usage data | ⚪ Not started | Screen Time API (FamilyControls entitlement) |
| StoreKit 2 subscriptions | ⚪ Not started | in_app_purchase, receipt validation |
| Firebase Auth | ⚪ Not started | Anonymous auth on launch, upgrade to email/Apple |
| Firestore sync | ⚪ Not started | Swipe history, preferences |
| Share results card | ⚪ Not started | "I freed 2.3GB with Tidy" viral card |
| Home screen widget | ⚪ Not started | Storage freed today |
| Referral system | ⚪ Not started | 1 month free per conversion |

## What Ships When

- **v1.0 (now):** UI scaffolding — all screens, Apple design system, navigation
- **v1.1:** Real photos — photo_manager, permissions, swipe physics, haptics
- **v1.2:** AI grouping — heuristic groups (duplicates, screenshots, old, blurry-ish)
- **v1.3:** Payments — StoreKit 2, paywall live, Pro tier enforced
- **v1.4:** App tracker live — Screen Time API or heuristic app list
- **v2.0:** Firebase auth + sync, referrals, share card, Android
- **v3.0:** Core ML blur model, full AI grouping, families, Mac app
