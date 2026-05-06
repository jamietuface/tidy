# Tidy — Setup Guide

Everything you need to go from zero to running the app on your iPhone.

---

## Prerequisites (one-time)

### 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Then add to PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Flutter + GitHub CLI
```bash
/opt/homebrew/bin/brew install --cask flutter && /opt/homebrew/bin/brew install gh
```

### 3. Add Flutter to PATH permanently
```bash
echo 'export PATH="/opt/homebrew/share/flutter/bin:/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 4. CocoaPods
```bash
/opt/homebrew/bin/brew install cocoapods
```

### 5. Xcode
- Download from the Mac App Store
- Open Xcode once to finish installation
- Accept the license: `sudo xcodebuild -license accept`
- Set command line tools:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  ```

### 6. Node.js (for Notion MCP)
```bash
/opt/homebrew/bin/brew install node
```

### 7. GitHub CLI login
```bash
gh auth login
```
Choose: GitHub.com → HTTPS → Login with web browser

---

## Clone & Run the Project

### 1. Clone the repo
```bash
cd ~/Desktop
gh repo clone jamietuface/tidy
cd tidy
```

### 2. Install Flutter dependencies
```bash
flutter pub get
```

### 3. Install iOS pods
```bash
cd ios && pod install && cd ..
```

### 4. Run on your iPhone 15
Plug in your iPhone via USB, tap **Trust** on the phone, then:
```bash
flutter devices        # confirm your iPhone appears
flutter run -d iPhone  # run on it
```

**First time only — set up signing in Xcode:**
```bash
open ios/Runner.xcworkspace
```
In Xcode: Runner → Signing & Capabilities → set **Team** to your Apple ID. Then retry `flutter run`.

### 5. Run on simulator (iPhone 17 Pro — iOS 26)
```bash
xcrun simctl boot "iPhone 17 Pro"
flutter run -d "iPhone 17 Pro"
```

---

## Daily Development

### Start a session
```bash
cd ~/Desktop/Tidy
flutter pub get        # if pubspec.yaml changed
flutter run -d iPhone  # hot reload active while running
```

### Hot reload vs hot restart
- **Hot reload** — press `r` in the terminal (keeps app state)
- **Hot restart** — press `R` in the terminal (resets state)
- **Quit** — press `q`

### Run static analysis
```bash
dart analyze lib/
```

### Format code
```bash
dart format lib/
```

### Run tests
```bash
flutter test
```

---

## Push Changes to GitHub

```bash
cd ~/Desktop/Tidy
git add .
git commit -m "Your change description"
git push
```

---

## Notion Auto-Documentation

Every code change gets logged to the Tidy Notion workspace automatically.

**Manual log:**
```bash
~/.tidy/notion-log.sh "What you changed" "More detail here"
```

**Notion workspace:** https://notion.so/d563af77025c4dc3a9ee5968e1d99771

**To set up Notion MCP (full integration):**
1. Go to notion.so/profile/integrations
2. Create integration named `Tidy`
3. Copy the `secret_...` token
4. Run:
   ```bash
   claude mcp add notion-tidy -- npx -y @notionhq/notion-mcp-server
   ```
5. Set env var `NOTION_TOKEN=secret_...` when prompted

---

## Project Structure

```
~/Desktop/Tidy/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app/
│   │   ├── tidy_app.dart            # MaterialApp.router
│   │   ├── router.dart              # GoRouter config
│   │   └── shell.dart               # Bottom tab shell
│   ├── core/
│   │   ├── theme/                   # TidyColors, TidySpacing, TidyTypography etc.
│   │   └── constants/               # App constants
│   ├── features/
│   │   └── onboarding/              # Onboarding screens
│   ├── screens/
│   │   ├── home_screen.dart         # Tab nav (Photos + Apps)
│   │   ├── swipe_screen.dart        # Photo swipe + AI groups
│   │   ├── subscriptions_screen.dart # App spend tracker
│   │   └── paywall_screen.dart      # Pro subscription
│   └── shared/widgets/              # TidyCard, SectionHeader etc.
├── ios/                             # Xcode iOS project
├── android/                         # Android project
├── docs/
│   ├── SETUP.md                     # ← you are here
│   ├── PATTERNS.md                  # Coding conventions
│   ├── FEATURES.md                  # Feature status tracker
│   ├── design-system.md             # Visual tokens
│   ├── architecture.md              # Tech stack + data flow
│   ├── business-plan.md             # Business model + GTM
│   ├── marketing.md                 # App Store copy + social
│   └── roadmap.md                   # v1 → v3 milestones
├── CLAUDE.md                        # Instructions for Claude Code
└── README.md                        # Quick start
```

---

## Key Commands Cheat Sheet

| Task | Command |
|------|---------|
| Run on iPhone | `flutter run -d iPhone` |
| Run on simulator | `flutter run -d "iPhone 17 Pro"` |
| Hot reload | Press `r` while flutter run is active |
| Analyse code | `dart analyze lib/` |
| Format code | `dart format lib/` |
| Push to GitHub | `git add . && git commit -m "msg" && git push` |
| Log to Notion | `~/.tidy/notion-log.sh "title" "detail"` |
| Open in Xcode | `open ios/Runner.xcworkspace` |
| Update packages | `flutter pub get` |
| Regenerate code | `dart run build_runner build` |
| Open Claude Code | Type `jamie` in terminal |
