# Firebase setup for Tidy

The Firebase code is fully scaffolded but **the app boots without Firebase**
until you complete the steps below — `initFirebase()` catches the missing
config and logs a warning.

---

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com/>.
2. Click **Add project**, name it `tidy` (or `tidy-prod` / `tidy-dev` if you
   want separate environments).
3. Enable Google Analytics (recommended for App Store/Play funnels).

## 2. Add the iOS app

1. In the Firebase console, click **Add app → iOS**.
2. Apple bundle ID — match the one in `ios/Runner.xcodeproj`. Default is
   `com.example.tidy`; check `ios/Runner.xcodeproj/project.pbxproj` if unsure.
3. Download `GoogleService-Info.plist` and drop it in `ios/Runner/`.
4. Repeat for Android if/when targeting Android (Phase 2).

## 3. Wire it into the Dart code

Run from the project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

This regenerates `lib/firebase_options.dart` with real credentials and
updates `firebase.json`.

## 4. Pod install

After `pubspec.yaml` changed:

```bash
cd ios && pod install && cd ..
```

## 5. Enable services in the console

In the Firebase console for your project:

- **Authentication → Sign-in method → enable Apple** (and Google if you
  ship that flow). Apple requires the Service ID config from the Apple
  Developer portal.
- **Firestore → create database** in production mode (the rules in
  `firestore.rules` already lock things down).
- **Cloud Messaging → enable** (for renewal reminders + future push).
- **Remote Config → enable** (for kill-switches and A/B values).
- **Analytics → already on** if you enabled it in step 1.

## 6. Deploy security rules + indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 7. Run the app

```bash
flutter run -d A531C85A-18B1-4553-AA8F-5CF185DFD47E
```

You should see no `Firebase init skipped` log line — Firebase initialised
cleanly.

---

## Data model (Firestore collections)

All data is namespaced under `/users/{uid}`:

| Path | Purpose |
|---|---|
| `users/{uid}` | User profile, plan tier (free / pro), spend totals |
| `users/{uid}/photo_decisions/{photoId}` | Per-photo kept/deleted decisions, synced across devices |
| `users/{uid}/subscriptions/{subscriptionId}` | Tracked app subscriptions (Netflix, Spotify, etc.) |
| `users/{uid}/settings/{docId}` | Theme, sort, notification prefs |
| `users/{uid}/devices/{deviceId}` | FCM tokens per device |

Indexes are defined in `firestore.indexes.json`:

- `subscriptions` by `(status, renewsAt)` — upcoming-renewal list
- `subscriptions` by `(status, monthlyCost desc)` — most-expensive-first
- `photo_decisions` by `(decision, decidedAt desc)` — recent kept/deleted
- `photo_decisions` by `(groupType, decidedAt desc)` — per-group history
