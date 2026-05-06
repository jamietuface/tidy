# Tidy — Technical Architecture

## Stack
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.9 |
| Language | Dart 3.x |
| State | Riverpod 2.x |
| Navigation | go_router 14.x |
| Local storage | shared_preferences |
| Photos | photo_manager (Flutter) |
| Subscriptions | in_app_purchase (StoreKit 2) |
| AI (Phase 2) | Core ML via flutter_mlkit |
| Analytics | (TBD — PostHog or Mixpanel) |
| Crash reporting | (TBD — Sentry) |

## Project Structure
```
lib/
├── main.dart                  # App entry, router setup
├── theme/
│   └── app_theme.dart         # AppColors, AppTheme, TidyThemeExtension
├── screens/
│   ├── home_screen.dart       # Bottom tab nav (Photos / Apps)
│   ├── swipe_screen.dart      # Photo swipe + AI groups
│   ├── subscriptions_screen.dart # App spend tracker
│   ├── paywall_screen.dart    # Subscription upsell
│   └── onboarding_screen.dart # 3-screen onboarding
├── widgets/
│   ├── tidy_card.dart         # Reusable card container
│   └── section_header.dart    # Section label with optional action
├── models/
│   ├── photo_item.dart        # Photo model (asset, group, keep/delete state)
│   └── app_item.dart          # Installed app model (name, cost, last used)
├── services/
│   ├── photo_service.dart     # Photo library access + grouping
│   ├── app_service.dart       # App usage + subscription data
│   └── subscription_service.dart # StoreKit 2 purchases
└── providers/
    ├── photo_provider.dart    # Riverpod photo state
    └── subscription_provider.dart # Pro status state
```

## Data Flow

### Photo Swipe
```
PhotoService.loadPhotos()
  → groups by AI category
  → streams to PhotoProvider
  → SwipeScreen reads provider
  → user swipes → PhotoProvider updates state
  → on commit → PhotoService.deletePhoto() / markKept()
```

### App Tracker
```
AppService.loadInstalledApps()  [Screen Time API - requires entitlement]
  → fetches last open date + bundle ID
  → matches to known subscription prices (local DB)
  → streams to AppProvider
  → SubscriptionsScreen reads provider
```

### Paywall
```
SubscriptionService.getProducts()  [StoreKit 2]
  → fetches monthly + annual products
  → PaywallScreen displays prices
  → user taps → SubscriptionService.purchase()
  → SubscriptionProvider updates isPro = true
```

## iOS Permissions Required
```xml
<!-- Info.plist -->
NSPhotoLibraryUsageDescription
NSPhotoLibraryAddUsageDescription
<!-- Screen Time API requires special Apple entitlement -->
```

## Key Design Decisions

### Why Flutter over Swift/UIKit?
- Single codebase for iOS + Android (Phase 2 Android)
- Faster iteration with hot reload
- Riverpod gives clean state management

### Why Riverpod over Bloc?
- Less boilerplate for a single-developer project
- Works well with go_router
- Auto-dispose prevents memory leaks

### Why go_router?
- Declarative routing that composes well with Riverpod
- Built-in deep link support (needed for referral links)

## Performance Targets
- App launch: < 1.5 seconds cold start
- Swipe animation: 60fps minimum, 120fps on ProMotion
- Photo loading: < 300ms per thumbnail
- AI grouping: < 5 seconds for 1,000 photos (on-device)
